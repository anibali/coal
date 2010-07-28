module CoalTreetop
  UNARY_SYMS = {
    '-'   => :neg,
    '~'   => :bit_neg,
    '@'   => :addr,
    '*'   => :deref,
    '!'   => :not,
  }
  
  BINARY_SYMS = {
    '='   => :sto,
    '^^'  => :xor,
    '||'  => :or,
    '&&'  => :and,
    '|'   => :bit_or,
    '^'   => :bit_xor,
    '&'   => :bit_and,
    '=='  => :eq,
    '!='  => :ne,
    '<'   => :lt,
    '<='  => :lte,
    '>'   => :gt,
    '>='  => :gte,
    '<<'  => :lshift,
    '>>'  => :rshift,
    '+'   => :add,
    '-'   => :sub,
    '*'   => :mul,
    '/'   => :div,
    '%'   => :mod,
    '**'  => :pow,
    '.'   => :mbr,
  }
  
  class BinaryOpLTR < Treetop::Runtime::SyntaxNode
    def tree
      array = nil
      elements[0].elements.each do |elem|
        val = elem.elements[0].tree
        op = BINARY_SYMS[elem.elements[2].text_value]
        if array.nil?
          array = [op, val]
        else
          array = [op, array << val]
        end
      end
      array << elements[1].tree
      array
    end
  end
  
  class BinaryOpRTL < Treetop::Runtime::SyntaxNode
    def tree
      op = BINARY_SYMS[elements[2].text_value]
      [op, elements[0].tree, elements[4].tree]
    end
  end
end
