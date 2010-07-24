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
      (@functions ||= {})[name]
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
    def properties props
      # TODO: actually do something
      p props
    end
  end
  
  class SpecialFunction
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
    
    class CFunction < Coal::SpecialFunction
      def initialize(name) ; @c_name = name ; end
      
      def call_libjit f, *args
        f.call_native *(JIT::LibC[@c_name] + args)
      end
    end
  end
  
  module Math
    extend Coal::ModuleExt
    
    def self.get_function name
      if %w[acos asin atan atan2 ceil cos cosh].include? name
        MathFunction.new name
      else
        super
      end
    end
    
    class MathFunction < Coal::SpecialFunction
      def initialize(name) ; @name = name ; end
      
      def call_libjit f, *args
        f.send *([@name] + args)
      end
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
      @module.module_eval("class #{name} ; end") unless @module.const_defined? name
      clazz = @module.const_get name
      clazz.extend Coal::ClassExt
      
      yield clazz
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

