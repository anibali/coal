require 'polyglot'
require 'coal/utils'
require 'coal/parser'
require 'coal/translators/libjit'

module Coal
  def self.namespace
    @namespace
  end
  
  def self.namespace=(namespace)
    @namespace = namespace
  end
  
  module Namespace
    def self.extended(sub)
      sub.module_eval do
        @functions = {}
        @function_builders = {}
        @translator = Translators::LibJIT.new(self)
      end
    end
    
    def translate! root_node
      @translator.translate root_node
    end
    
    def load! file
      code = File.read(file)
      parser = Parser.new
      root_node = parser.parse code
      if root_node.nil?
        raise parser.failure_reason
      else
        translate! root_node
      end
    end
    
    # Accepts the function name and a block which produces the function
    def add_function! name, &block
      if @function_builders.key? name
        raise "function already defined: '#{name}'"
      end
      @function_builders[name] = block
      module_exec name do |name|
        self.class.send :define_method, name do |*args|
          @functions[name] ||= @function_builders[name].call
          @functions[name].call(*args)
        end
      end
    end
  end
  
  class Loader
    Polyglot.register("c", self)
    
    def self.load(file, opts={})
      Coal.namespace.load! file
    end
  end
end

module Cl
  extend Coal::Namespace
  
  Coal.namespace = self
end

