require 'treetop'

require 'virtmem'
require 'coal/parser'
require 'coal/power'

Module.module_eval <<END
  def namespace
    const_get(self.name.split('::')[0...-1].join('::'))
  end
END

module Coal
  module ModuleExt
    def get_class name
      (@classes ||= {})[name]
    end  
    
    def class *args, &block
      if args.empty?
        super
      else
        Coal.class *args, &block
      end
    end
    
    def get_function name
      (@functions ||= {})[name.to_s]
    end
    
    def function name, param_types, return_type, code
      method_def = "def self.#{name}(*args)
      args.map! {|arg| arg.respond_to?(:struct_pointer) ? arg.struct_pointer : arg}\n"
      if return_type.is_a? Class
        method_def << "obj = #{return_type.name}.allocate
          obj.instance_variable_set(:@struct_pointer, get_function('#{name}').call(*args))
          return obj"
      elsif return_type == :stringz
        method_def << "get_function('#{name}').call(*args).get_string(0)"
      else
        method_def << "get_function('#{name}').call(*args)"
      end
      method_def << "\nend"
      module_eval method_def
      param_types.map! do |type|
        process_type type
      end
      return_type = process_type return_type
      @uncompiled_funcs ||= []
      trans = Coal.translator_class.new
      function = trans.declare_func(param_types, return_type)
      @uncompiled_funcs << [name, function, code]
      (@functions ||= {})[name] = function
    end
    
    def process_type type
      if type.is_a? Class
        [:pointer, type.struct_type]
      elsif type == :stringz
        [:pointer, :uint8]
      else
        type
      end
    end
    
    def compile_funcs
      return if @uncompiled_funcs.nil?
      @uncompiled_funcs.each do |name, func, code|
        tree = Coal::Parser.parse code
        trans = Coal.translator_class.new
        (@functions ||= {})[name] = trans.compile_func(func, Coal::Parser.parse(code))
      end
      @uncompiled_funcs.clear
    end
  end
  
  module ClassExt
    attr_reader :struct_pointer
    
    def self.included(klass)
      klass.extend ClassMethods
    end
    
    module ClassMethods
      include ModuleExt
      
      def fields fields
        trans = Coal.translator_class.new
        @struct_type = trans.create_struct_type fields
        Cl::CLASSES[@struct_type.jit_t.address] = self
      end
      
      def struct_type
        @struct_type
      end
      
      def method name, param_types, return_type, code
        function name, ([[:pointer, @struct_type]] + param_types), return_type, code
        class_eval "def #{name} *args, &block
          self.class.#{name} @struct_pointer, *args, &block
        end"
      end
      
      def constructor param_types, code
        method 'construct', param_types, :void, code
        thing = self.name.split('::')[1..-1].join '.'
        
        trans = Coal.translator_class.new
        function = trans.declare_func(param_types, [:pointer, @struct_type])
        code = "return(#{thing}.construct(Core.malloc(#{@struct_type.size})"
        param_types.size.times {|i| code << ', ' << "arg(#{i})"}
        code << "))"
        @uncompiled_funcs << ['new', function, code]
        (@functions ||= {})['new'] = function
      end
      
      def getter *args
        args.each do |name|
          type = @struct_type.field_type(name).to_ffi_type
          method name, [], type, "return(self.#{name})"
        end
      end
      
      def setter *args
        args.each do |name|
          type = @struct_type.field_type(name).to_ffi_type
          method "set_#{name}", [type], :void, "self.#{name}=arg(1)"
        end
      end
      
      def accessor *args
        getter *args
        setter *args
      end
      
      def new *args
        obj = allocate
        obj.instance_variable_set :@struct_pointer, get_function('new').call(*args)
        obj
      end
    end
  end
end

module Cl
  CLASSES = {} unless defined? CLASSES
  
  module Core
    extend Coal::ModuleExt
    
    def self.get_function name
      if %w[puts putchar printf sprintf time rand malloc free].include? name
        CFunction.new name
      else
        super
      end
    end
    
    class CFunction
      attr_reader :name
      def initialize(name) ; @name = name ; end
    end
  end
  
  module Math
    extend Coal::ModuleExt
    
    def self.get_function name
      if %w[acos asin atan atan2 ceil cos cosh exp floor log log rint round sin
      sinh sqrt tan tanh].include? name
        MathFunction.new name
      else
        super
      end
    end
    
    class MathFunction
      attr_reader :name
      def initialize(name) ; @name = name ; end
    end
  end
end

module Coal
  def self.translator_class=(clazz)
    @translator_class = clazz
  end
  
  def self.translator_class
    @translator_class
  end
  
  def self.build_func param_types, return_type, code
    tree = Parser.parse code
    trans = translator_class.new
    trans.compile_func(trans.declare_func(param_types, return_type), tree)
  end
  
  @module = Cl
  def self.module name
    @module.module_eval("module #{name} ; end") unless @module.const_defined? name
    @module = @module.const_get name
    @module.extend Coal::ModuleExt
    
    yield @module
    
    @module.compile_funcs
    @module = @module.namespace
  end
  
  def self.class *args, &block
    if args.empty?
      super
    else
      name = args[0]
      superclass = args[1]
      unless @module.const_defined? name
        if superclass.nil?
          @module.module_eval("class #{name} ; include Coal::ClassExt ; end")
        else
          @module.module_eval("class #{name} < #{superclass.name}
            include Coal::ClassExt
          end")
        end
      end
      
      clazz = @module.const_get name
      
      unless superclass.nil?
        # Copy instance variables from the superclass
        superclass.instance_variables.each do |var|
          clazz.instance_variable_set(var, superclass.instance_variable_get(var))
        end
      end
      
      yield clazz
      
      clazz.compile_funcs
      clazz
    end
  end
  
  class Error < StandardError ; end
  class SyntaxError < Error ; end
  
  class UndeclaredVariableError < Error
    def initialize(var_name)
      super("used variable '#{var_name}' without previous declaration")
    end
  end
end

require 'coal/translators/ruby'
begin
  require 'coal/translators/libjit'
  Coal.translator_class = Coal::Translators::LibJIT
rescue
  Coal.translator_class = Coal::Translators::Ruby
end

