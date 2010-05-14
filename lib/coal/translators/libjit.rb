require 'libjit'

module Coal::Translators

class LibJIT
  def build_callable(param_types, return_type, tree)
    context = JIT::Context.default
    function = nil
    
    context.build do |c|
      c.function(param_types, return_type) do |f|
        @reg = {}
        @function = function = f
        tree.translate(self)
        @reg = @function = nil
      end
    end
    
    function
  end
  
  def type(*args)
    JIT::Type.create *args
  end
  
  def bitshift_left(a, b)
    a << b
  end
  
  def bitshift_right(a, b)
    a >> b
  end
  
  def prefix_increment(a)
    assign(a, add(a, integer_constant(1)))
  end
  
  def prefix_decrement(a)
    assign(a, subtract(a, integer_constant(1)))
  end
  
  def add(a, b)
    a + b
  end
  
  def subtract(a, b)
    a - b
  end
  
  def multiply(a, b)
    a * b
  end
  
  def divide(a, b)
    a / b
  end
  
  def modulus(a, b)
    a % b
  end
  
  def negate(a)
    -a
  end
  
  def bitwise_not(a)
    ~a
  end
  
  def address_of(a)
    a.address
  end
  
  def dereference(a, type=nil)
    a.dereference(type)
  end
  
  def bitwise_and(a, b)
    a & b
  end
  
  def bitwise_xor(a, b)
    a ^ b
  end
  
  def bitwise_or(a, b)
    a | b
  end
  
  def assign(var, val)
    var.store val
  end
  
  def variable(var_name)
    var = @reg[var_name.to_sym]
    if var.nil?
      raise Coal::Error.new("Variable '#{var_name}' has not been declared")
    end
    var
  end
  
  def integer_constant(n)
    @function.const n, :int32
  end
  
  def declare(type, var_name)
    @reg[var_name.to_sym] = @function.declare(type)
  end
  
  def less a, b
    a < b
  end
  
  def less_or_equal a, b
    a <= b
  end
  
  def greater a, b
    a > b
  end
  
  def greater_or_equal a, b
    a >= b
  end
  
  def equal a, b
    a.eq b
  end
  
  def not_equal a, b
    a.ne b
  end
  
  def true
    @function.true
  end
  
  def false
    @function.false
  end
  
  def null
    @function.null
  end
  
  def arg(i)
    @function.arg(i.to_numeric)
  end
  
  def return(val)
    @function.return(val)
  end
  
  def while(cond, &block)
    @function.while { cond.translate(self) }.do(&block).end
  end
  
  def until(cond, &block)
    @function.until { cond.translate(self) }.do(&block).end
  end
  
  def break
    @function.break
  end
  
  def if(cond, els=nil, &block)
    if els.nil?
      @function.if { cond.translate(self) }.do(&block).end
    else
      @function.if { cond.translate(self) }.do(&block).else {
        els.translate(self)
      }.end
    end
  end
  
  def unless(cond, els=nil, &block)
    if els.nil?
      @function.unless { cond.translate(self) }.do(&block).end
    else
      @function.unless { cond.translate(self) }.do(&block).else {
        els.translate(self)
      }.end
    end
  end
end

end

