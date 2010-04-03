require 'libjit'

module Coal::Translators
class LibJIT
  def build_callable(param_types, return_type, tree)
    context = JIT::Context.new
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
  
  def type(str)
    JIT::Type.new str.to_sym
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
  
  def assign(var, val)
    var.store val
  end
  
  def variable(var_name)
    @reg[var_name.to_sym]
  end
  
  def integer_constant(n)
    @function.const :int32, n
  end
  
  def declare(type, var_name)
    @reg[var_name.to_sym] = @function.value(type)
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
    @function.const :int32, 1 #TODO: use 8-bit int
  end
  
  def false
    @function.const :int32, 0 #TODO: use 8-bit int
  end
  
  def null
    @function.const :int32, 0 #TODO: use 8-bit int
  end
  
  def arg(i)
    @function.arg(i.to_i)
  end
  
  def return(val)
    @function.return(val)
  end
  
  def while(cond)
    @function.while(proc {cond.translate(self)}) do
      yield
    end
  end
  
  def until(cond)
    @function.until(proc {cond.translate(self)}) do
      yield
    end
  end
  
  def break
    @function.break
  end
  
  def if(cond, els=nil)
    else_proc = nil
    else_proc = proc { els.translate(self) } if els
    @function.if(proc {cond.translate(self)}, else_proc) do
      yield
    end
  end
  
  def unless(cond, els=nil)
    else_proc = nil
    else_proc = proc { els.translate(self) } if els
    @function.unless(proc {cond.translate(self)}, else_proc) do
      yield
    end
  end
  
  def method_missing name, *args
    p "#{name}(#{args.join ", "})"
  end
end
end

