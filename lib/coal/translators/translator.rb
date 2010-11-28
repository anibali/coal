require 'coal'

module Coal
  module Translators
    class Translator
      include Nodes
      
      def assert_type node, type
        unless node.is_a? type
          raise TypeError.new "expected a #{type}, but was a #{node.class}"
        end
      end
      
      def trans_err *args
        TranslationError.new *args
      end
    end
    
    class TranslationError < RuntimeError ; end
  end
end
