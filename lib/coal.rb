require 'treetop'

require 'virtmem'
require 'coal/parser'

Module.module_eval <<END
  def namespace
    const_get(self.name.split('::')[0...-1].join('::'))
  end
END

module Cl
  def get_function name
    @functions[name]
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
    @uncompiled_funcs.each do |name, func, code|
      tree = Coal::Parser.parse code
      trans = Coal.translator_class.new
      (@functions ||= {})[name] = trans.compile_func(func, Coal::Parser.parse(code))
    end
    @uncompiled_funcs.clear
  end
  
  module Core
    extend Cl
    
    def self.get_function name
      if %w[puts putchar malloc free].include? name
        CFunction.new name
      else
        super
      end
    end
    
    class CFunction
      attr_reader :c_name
      
      def initialize(name) ; @c_name = name ; end
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
    Cl.module_eval("module #{name} ; end") unless Cl.const_defined? name
    @module = Cl.const_get name
    @module.extend Cl
    
    yield @module
    
    @module.compile_funcs
    @module = @module.namespace
  end
  
  def self.function *args
    @module.function *args
  end
  
  class Error < StandardError ; end
  class SyntaxError < Error ; end
  
  class UndeclaredVariableError < Error
    def initialize(var_name)
      super("used variable '#{var_name}' without previous declaration")
    end
  end
  
  module Power
    def self.included(klass)
      klass.extend ClassMethods
    end
    
    module ClassMethods
      def defc name, param_types, return_type, code
        name = name.to_sym
        callable = Coal.build_func param_types, return_type, code
        
        if name.to_s.match /^self\.(.*)/
          name = $1.to_sym
          class_eval "(@@coal_class_methods ||= {})[name] = callable"
        else
          class_eval "(@@coal_instance_methods ||= {})[name] = callable"
        end
      end
      
      def method_missing name, *args
        name = name.to_sym
        coal_methods = class_eval("@@coal_class_methods") rescue nil
        if coal_methods and coal_methods.has_key? name
          coal_methods[name].call *args
        else
          super
        end
      end
    end
    
    def method_missing name, *args
      name = name.to_sym
      coal_methods = self.class.class_eval("@@coal_instance_methods") rescue nil
      if coal_methods and coal_methods.has_key? name
        coal_methods[name].call *args
      else
        super
      end
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

