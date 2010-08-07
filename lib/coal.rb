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
      module_eval("def self.#{name}(*args) ; get_function('#{name}').call(*args) ; end")
      @uncompiled_funcs ||= []
      trans = Coal.translator_class.new
      function = trans.declare_func(param_types, return_type)
      @uncompiled_funcs << [name, function, code]
      (@functions ||= {})[name] = function
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
    def self.included(klass)
      klass.extend ClassMethods
    end
    
    def method_missing(name, *args)
      func = self.class.get_function(name)
      if func.nil?
        super
      else
        func.call *([@struct] + args)
      end
    end
    
    module ClassMethods
      include ModuleExt
      
      def properties props
        trans = Coal.translator_class.new
        @struct_type = trans.create_struct_type props
      end
      
      def method name, param_types, return_type, code
        function name, ([[:pointer, @struct_type]] + param_types), return_type, code
      end
      
      def getter *args
        args.each do |name|
          type = @struct_type.field_type(name).to_ffi_type
          method name, [], type, "return((*arg(0)).#{name})"
        end
      end
      
      def new *args
        trans = Coal.translator_class.new
        @constructor ||= trans.compile_func(trans.declare_func([], :void), [])
        struct = trans.create_struct @constructor, @struct_type
        @constructor[*args]
        
        obj = allocate
        obj.instance_variable_set :@struct, struct
        obj
      end
    end
  end
end

module Cl
  module Core
    extend Coal::ModuleExt
    
    def self.get_function name
      if %w[puts putchar malloc free].include? name
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
      @module.module_eval("class #{name} ; include Coal::ClassExt ; end") unless @module.const_defined? name
      clazz = @module.const_get name
      
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

