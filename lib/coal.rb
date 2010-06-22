require 'treetop'

require 'virtmem'
require 'coal/parser'

module Coal
  def self.translator_class=(clazz)
    @translator_class = clazz
  end
  
  def self.translator_class
    @translator_class
  end
  
  def self.compile_func param_types, return_type, code
    tree = Parser.parse code
    trans = translator_class.new
    trans.compile_func param_types, return_type, tree
  end
  
  ############# UNTESTED
  @namespaces = {}
  @scope = @namespaces
  def self.module name
    old_scope = @scope
    @scope = @scope[name.to_s] = {}
    yield
    @scope = old_scope
  end
  
  def self.function name, param_types, return_type, code
    @scope[:functions] ||= {}
    @scope[:functions][name.to_s] = compile_func(param_types, return_type, code)
  end
  ############# END UNTESTED
  
  class Function
    attr_reader :native
  
    def initialize(native)
      @native = native
    end
    
    def call *args
      @native.call *args
    end
    
    def [] *args
      call *args
    end
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
        callable = Coal.compile_func param_types, return_type, code
        
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

