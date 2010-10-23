require 'coal/parser/nodes'
require 'coal/parser/coal_treetop'

module Coal
  module Parser
    TREETOP_PARSER = CoalTreetopParser.new
    
    # Parse Coal code into a translator-friendly tree representation.
    #
    # @return [Array] the parse tree.
    def self.parse *args
      result = TREETOP_PARSER.parse(*args)
      if result.nil?
        message = ""
        line = args.first.lines.to_a[TREETOP_PARSER.failure_line - 1].strip
        col = TREETOP_PARSER.failure_column - 1
        message << "Parsing failed on line #{TREETOP_PARSER.failure_line}\n"
        message << "  " + line + "\n  "
        message << " " * [col - 1, 0].max + (col.zero? ? "^^" : "^^^") + "\n"
        message << TREETOP_PARSER.failure_reason
        raise SyntaxError.new(message)
      end
      result.tree
    end
  end
end

