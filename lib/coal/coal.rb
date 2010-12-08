require 'polyglot'
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
      load_from_string! File.read(file)
    end
    
    def load_from_string! code
      parser = Parser.new
      
      ## Translation phase #1
      # Trigraph sequences
      hash = {
        '??='   => '#',
        '??('   => '[',
        '??/'   => '\\',
        '??]'   => ']',
        '??\''  => '^',
        '??<'   => '{',
        '??!'   => '|',
        '??>'   => '}',
        '??-'   => '~',
      }
      regexp = /(#{hash.keys.map { |tri| Regexp.escape(tri) }.join("|")})/
      code.gsub! regexp do |tri|
        hash[tri]
      end
      
      ## Translation phase #2
      code.gsub! "\\\n", ""
      
      ## Translation phases #3 and #4
      parser.root = 'preprocessing_file'
      node = parser.parse code
      if node.nil?
        raise "Preprocessor syntax error:\n#{parser.failure_reason}"
      else
        # Add a trailing newline if appropriate
        code << "\n" if code[-1] != ?\n
        # Preprocess, my pretties, preprocess!
        code = @translator.preprocess node.tree
      end
      
      ## Translation phase #7
      parser.root = 'c_file'
      node = parser.parse code
      if node.nil?
        raise "Syntax error:\n#{parser.failure_reason}"
      else
        @translator.translate node.tree
      end
    end
    
    def add_function! name, function
      name = String(name)
      raise "Function already added: '#{name}'" if @functions.key? name
      @functions[name] = function
      module_eval <<-END
        def self.#{name}(*args)
          func = @functions[#{name.inspect}]
          @translator.prepare_function func
          func.call(*args)
        end
      END
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

