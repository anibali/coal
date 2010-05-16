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
  
  class Error < StandardError ; end
  class SyntaxError < Error ; end

  class Parser < CoalTreetopParser
    def parse *args
      res = super
      if res.nil?
        raise SyntaxError.new failure_reason
      end
      res
    end
  end
  
  module Power
    def self.included(klass)
      klass.extend ClassMethods
    end
    
    module ClassMethods
      def defc name, param_types, return_type, code
        name = name.to_sym
        tree = Parser.new.parse code
        trans = Coal.translator_class.new
        callable = trans.build_callable param_types, return_type, tree
        
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

