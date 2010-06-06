module Coal::Translators

class Ruby
  def compile_func(param_types, return_type, tree)
    @code = ""
    
    statements(tree)
    
    lambda do |*args|
      eval @code
    end
  end
  
  def statements(tree)
    tree.each do |e|
      statement(e)
    end
  end
  
  def statement(tree)
    case tree.first
    when :break
      @code << "break;"
    when :ret
      @code << "return(#{expression(tree[1])});"
    when :decl
      @code << "#{tree[2]} = #{tree[3].nil? ? 'nil' : expression(tree[3])};"
    when :if
      @code << "if(#{expression tree[1]});"
      statements tree[2]
      unless tree[3].nil?
        @code << "else;"
        statements tree[3]
      end
      @code << ";end;"
    when :unless
      @code << "unless(#{expression tree[1]});"
      statements tree[2]
      unless tree[3].nil?
        @code << "else;"
        statements tree[3]
      end
      @code << ";end;"
    when :while
      @code << "while(#{expression tree[1]});"
      statements tree[2]
      @code << ";end;"
    when :until
      @code << "until(#{expression tree[1]});"
      statements tree[2]
      @code << ";end;"
    else
      @code << "#{expression(tree)};"
    end
  end
  
  def expression(tree)
    if tree.is_a? Array
      case tree.first
      when :add
        "(#{expression(tree[1])} + #{expression(tree[2])})"
      when :sub
        "(#{expression(tree[1])} - #{expression(tree[2])})"
      when :mul
        "(#{expression(tree[1])} * #{expression(tree[2])})"
      when :div
        "(#{expression(tree[1])} / #{expression(tree[2])})"
      when :mod
        "(#{expression(tree[1])} % #{expression(tree[2])})"
      when :pow
        "(#{expression(tree[1])} ** #{expression(tree[2])})"
      when :bit_and
        "(#{expression(tree[1])} & #{expression(tree[2])})"
      when :bit_xor
        "(#{expression(tree[1])} ^ #{expression(tree[2])})"
      when :bit_or
        "(#{expression(tree[1])} | #{expression(tree[2])})"
      when :lshift
        "(#{expression(tree[1])} << #{expression(tree[2])})"
      when :rshift
        "(#{expression(tree[1])} >> #{expression(tree[2])})"
      when :lt
        "(#{expression(tree[1])} < #{expression(tree[2])})"
      when :lteq
        "(#{expression(tree[1])} <= #{expression(tree[2])})"
      when :gt
        "(#{expression(tree[1])} > #{expression(tree[2])})"
      when :gteq
        "(#{expression(tree[1])} >= #{expression(tree[2])})"
      when :eq
        "(#{expression(tree[1])} == #{expression(tree[2])})"
      when :ne
        "(#{expression(tree[1])} != #{expression(tree[2])})"
      when :bit_neg
        raise "TODO"
      when :neg
        if tree[1].is_a? Fixnum
          # Small optimisation. Creates a negative constant rather than
          # creating a positive constant then negating it
          expression -tree[1]
        else
          "(-#{expression tree[1]})"
        end
      when :sto
        "(#{tree[1]} = #{expression tree[2]})"
      when :arg
        "args(#{tree[1]})"
      else
        # Oops!
        raise "Can't translate expression: #{tree.inspect}"
      end
    else
      # Assume literal
      tree
    end
  end
end

end

