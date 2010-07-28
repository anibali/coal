require 'virtmem'

module Coal::Translators

class Ruby
  def declare_func param_types, return_type
    nil
  end
  
  def compile_func(function, tree)
    @code = ""
    
    statements(tree)
    
    llama = lambda do |*args|
      eval @code
    end
    
    llama
  end
  
  def statements(tree)
    @code << "VirtMem.narrow_scope;"
    tree.each do |e|
      statement(e)
    end
    @code << "VirtMem.widest_scope;"
  end
  
  def statement(tree)
    case tree.first
    when :break
      @code << "VirtMem.widen_scope;break;"
    when :ret
      @code << "__tmp_var__=#{expression(tree[1])};VirtMem.widest_scope;return(__tmp_var__);"
    when :decl
      @code << "#{tree[2]} = VirtMem::Value.create(#{type(tree[1])}"
      @code << ", #{expression(tree[3])}" unless tree[3].nil?
      @code << ");"
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
      when :lte
        "(#{expression(tree[1])} <= #{expression(tree[2])})"
      when :gt
        "(#{expression(tree[1])} > #{expression(tree[2])})"
      when :gte
        "(#{expression(tree[1])} >= #{expression(tree[2])})"
      when :eq
        "(#{expression(tree[1])} == #{expression(tree[2])})"
      when :ne
        "(#{expression(tree[1])} != #{expression(tree[2])})"
      when :and
        "(#{expression(tree[1])} && #{expression(tree[2])})"
      when :xor
        "(#{expression(tree[1])} ^ #{expression(tree[2])})"
      when :or
        "(#{expression(tree[1])} || #{expression(tree[2])})"
      when :not
        "(!#{expression(tree[1])})"
      when :bit_neg
        "(~#{expression(tree[1])})"
      when :neg
        if tree[1].is_a? Fixnum
          # Small optimisation. Creates a negative constant rather than
          # creating a positive constant then negating it
          expression -tree[1]
        else
          "(-#{expression tree[1]})"
        end
      when :deref
        if tree[2].nil?
          "#{expression(tree[1])}.dereference"
        else
          "#{expression(tree[1])}.dereference(#{type(tree[2])})"
        end
      when :addr
        "#{expression(tree[1])}.address"
      when :sto
        "(#{tree[1]}.store(#{expression tree[2]}))"
      when :call
        "#{function(tree[1])}(#{arguments tree[2]})"
      when :arg
        "args[#{tree[1]}]"
      else
        # Oops!
        raise "Can't translate expression: #{tree.inspect}"
      end
    else
      # Assume literal
      tree
    end
  end
  
  def function(tree)
    "#{modul(tree[1])}.#{tree[2]}"
  end
  
  def modul(tree)
    if tree.is_a? Array
      raise "wtf is this?: #{tree.inspect}" unless tree.first == :mbr
      "#{modul(tree[1])}::#{tree[2]}"
    else
      "Cl::#{tree}"
    end
  end
  
  def arguments(tree)
    tree.map do |arg|
      expression(arg)
    end.join ", "
  end
  
  def type(tree)
    "VirtMem::Type.create(#{[*tree].map{|e| e.inspect}.join(', ')})"
  end
end

end

