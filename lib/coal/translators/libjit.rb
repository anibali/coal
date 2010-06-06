require 'libjit'

module Coal::Translators

class LibJIT
  def compile_func(param_types, return_type, tree)
    context = JIT::Context.default
    function = nil
    
    begin
      context.build do |c|
        c.function(param_types, return_type) do |f|
          @reg = {}
          @function = function = f
          statements(tree)
          @reg = @function = nil
        end
      end
    rescue Exception => ex
      context.build_end
      raise ex
    end
    
    function
  end
  
  def statements(tree)
    tree.each do |e|
      statement(e)
    end
  end
  
  def statement(tree)
    case tree.first
    when :break
      @function.break
    when :ret
      @function.return(expression(tree[1]))
    when :decl
      @reg[tree[2].to_sym] = @function.declare(type tree[1])
      unless tree[3].nil?
        @reg[tree[2].to_sym].store expression(tree[3])
      end
    when :if
      branch = @function.if {expression tree[1]}.do {
        statements tree[2]
      }
      unless tree[3].nil?
        branch.else {
          statements tree[3]
        }
      end
      branch.end
    when :unless
      branch = @function.unless {expression tree[1]}.do {
        statements tree[2]
      }.end
      unless tree[3].nil?
        branch.else {
          statements tree[3]
        }
      end
      branch.end
    when :while
      @function.while {expression tree[1]}.do {
        statements tree[2]
      }.end
    when :until
      @function.until {expression tree[1]}.do {
        statements tree[2]
      }.end
    else
      expression(tree)
    end
  end
  
  def expression(tree)
    if tree.is_a? Array
      case tree.first
      when :add
        expression(tree[1]) + expression(tree[2])
      when :sub
        expression(tree[1]) - expression(tree[2])
      when :mul
        expression(tree[1]) * expression(tree[2])
      when :div
        expression(tree[1]) / expression(tree[2])
      when :mod
        expression(tree[1]) % expression(tree[2])
      when :pow
        expression(tree[1]) ** expression(tree[2])
      when :bit_and
        expression(tree[1]) & expression(tree[2])
      when :bit_xor
        expression(tree[1]) ^ expression(tree[2])
      when :bit_or
        expression(tree[1]) | expression(tree[2])
      when :lshift
        expression(tree[1]) << expression(tree[2])
      when :rshift
        expression(tree[1]) >> expression(tree[2])
      when :lt
        expression(tree[1]) < expression(tree[2])
      when :lteq
        expression(tree[1]) <= expression(tree[2])
      when :gt
        expression(tree[1]) > expression(tree[2])
      when :gteq
        expression(tree[1]) >= expression(tree[2])
      when :eq
        expression(tree[1]).eq expression(tree[2])
      when :ne
        expression(tree[1]).ne expression(tree[2])
      when :bit_neg
        ~expression(tree[1])
      when :neg
        if tree[1].is_a? Fixnum
          # Small optimisation. Creates a negative constant rather than
          # creating a positive constant then negating it
          expression -tree[1]
        else
          -expression(tree[1])
        end
      when :deref
        if tree[2].nil?
          expression(tree[1]).dereference
        else
          expression(tree[1]).dereference(type(tree[2]))
        end
      when :addr
        expression(tree[1]).address
      when :sto
        variable(tree[1]).store expression(tree[2])
      when :arg
        @function.arg(tree[1])
      else
        # Oops!
        raise "Can't translate expression: #{tree.inspect}"
      end
    else
      if tree.is_a? Fixnum
        @function.const tree, :int32
      elsif [true, false].include? tree
        if tree
          @function.true
        else
          @function.false
        end
      elsif tree.is_a? String
        variable(tree)
      end
    end
  end
  
  def type(tree)
    JIT::Type.create(*tree)
  end
  
  def variable(tree)
    var = @reg[tree.to_sym]
    if var.nil?
      raise Coal::UndeclaredVariableError.new(tree)
    end
    var
  end
end

end

