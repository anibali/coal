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
    end
  end
end
