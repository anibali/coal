require 'treetop'
require 'mixin'

Treetop.load File.join(File.dirname(File.expand_path(__FILE__)), 'coal.treetop')

module Coal
  def self.translator_class=(clazz)
    @translator_class = clazz
  end
  
  def self.translator_class
    @translator_class
  end
  
  class SyntaxError < StandardError ; end

  class Parser < CoalTreetopParser
    def parse *args
      res = super
      # TODO: custom Coal error class
      raise SyntaxError.new failure_reason if res.nil?
      res
    end
  end
  
  module HasCoal
    class_mixin do
      def def_coal name, param_types, return_type, code
        name = name.to_sym
        tree = Parser.new.parse code
        trans = Coal.translator_class.new
        callable = trans.build_callable param_types, return_type, tree
        
        if name.to_s.match /^self\.(.*)/
          name = $1.to_sym
          @coal_instance_methods ||= {}
          @coal_instance_methods[name] = callable
        else
          @coal_methods ||= {}
          @coal_methods[name] = callable
        end
      end

      def coal_methods
        @coal_methods
      end
      
      def coal_instance_methods
        @coal_instance_methods
      end
      
      def method_missing name, *args
        name = name.to_sym
        if @coal_instance_methods and @coal_instance_methods.has_key? name
          @coal_instance_methods[name].call *args
        else
          super
        end
      end
    end
    
    module_mixin do
      def def_coal name, param_types, return_type, code
        name = name.to_sym
        tree = Parser.new.parse code
        trans = Coal.translator_class.new
        callable = trans.build_callable param_types, return_type, tree
        
        if name.to_s.match /^self\.(.*)/
          name = $1.to_sym
          @coal_instance_methods ||= {}
          @coal_instance_methods[name] = callable
        else
          raise ArgumentError.new("method name should begin with 'self.\'")
        end
      end
      
      def coal_instance_methods
        @coal_instance_methods
      end
      
      def method_missing name, *args
        name = name.to_sym
        if @coal_instance_methods and @coal_instance_methods.has_key? name
          @coal_instance_methods[name].call *args
        else
          super
        end
      end
    end
    
    def method_missing name, *args
      name = name.to_sym
      if self.class.coal_methods and self.class.coal_methods.has_key? name
        self.class.coal_methods[name].call *args
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

