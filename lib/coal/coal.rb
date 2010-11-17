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
        clear!
      end
    end
    
    def load! file
      code = File.read(file)
      parser = Parser.new
      
      parser.root = 'preprocessing_file'
      node = parser.parse code
      if node.nil?
        raise "Preprocessor syntax error:\n#{parser.failure_reason}"
      else
        code = @translator.preprocess node
      end
      
      parser.root = 'c_file'
      node = parser.parse code
      if node.nil?
        raise "Syntax error:\n#{parser.failure_reason}"
      else
        @translator.translate node
      end
    end
    
    def add_function! name, function
      name = String(name)
      raise "function already added: '#{name}'" if @functions.key? name
      @functions[name] = function
      module_exec name do |name|
        self.class.send :define_method, name do |*args|
          func = @functions[name]
          @translator.prepare_function func
          func.call(*args)
        end
      end
    end
    
    def clear!
      if @functions
        @functions.each do |k, v|
          method(k).owner.send :remove_method, k
        end
      end
      @functions = {}
      @translator = Translators::LibJIT.new(self)
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

