require 'coal/coal_treetop'
require 'coal/node_classes'

module Coal
  class Parser < CoalTreetopParser
    def self.parse *args
      new.parse(*args).tree
    end
    
    def parse *args
      res = super
      if res.nil?
        raise SyntaxError.new failure_reason
      end
      res
    end
  end
end

