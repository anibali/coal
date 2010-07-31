require 'coal/coal_treetop'
require 'coal/node_classes'

module Coal
  class Parser < CoalTreetopParser
    def self.parse *args
      new.parse(*args).tree
    end
    
    # Parse Coal code into a translator-friendly tree representation.
    #
    # @return [Array] the parse tree.
    def parse *args
      res = super
      if res.nil?
        message = ""
        line = args.first.lines.to_a[failure_line - 1].strip
        col = failure_column - 1
        message << "Parsing failed on line #{failure_line}\n"
        message << "  " + line + "\n  "
        message << " " * [col - 1, 0].max + (col.zero? ? "^^" : "^^^") + "\n"
        message << failure_reason
        raise SyntaxError.new(message)
      end
      res
    end
  end
end

