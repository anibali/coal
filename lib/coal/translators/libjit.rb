require 'libjit'

module Coal::Translators

class LibJIT
  def declare_func param_types, return_type
    function = nil
    JIT::Context.default.build do |c|
      function = JIT::Function.new(param_types, return_type)
    end
    function
  end
  
  def compile_func(function, tree)
    context = JIT::Context.default
    
    @function = function
    @reg = {}
    
    begin
      context.build do |c|
        @reg[:self] = expression([:arg, 0]) rescue nil
        statements(tree)
        @function.compile
      end
    rescue Exception => ex
      context.build_end
      raise ex
    end
    
    @reg = @function = nil
    
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
      when :lte
        expression(tree[1]) <= expression(tree[2])
      when :gt
        expression(tree[1]) > expression(tree[2])
      when :gte
        expression(tree[1]) >= expression(tree[2])
      when :eq
        expression(tree[1]).eq expression(tree[2])
      when :ne
        expression(tree[1]).ne expression(tree[2])
      when :and
        expression(tree[1]).and expression(tree[2])
      when :xor
        expression(tree[1]).xor expression(tree[2])
      when :or
        expression(tree[1]).or expression(tree[2])
      when :not
        expression(tree[1]).not
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
      when :cast
        expression(tree[1]).cast type(tree[2])
      when :sto
        variable(tree[1]).store expression(tree[2])
      when :msto
        ptr = variable(tree[1])
        ptr.mstore expression(tree[2]).cast(ptr.ref_type)
      when :get
        ptr = expression(tree[1])
        type = ptr.ref_type
        field = tree[2]
        ptr.mload(type.offset(field), type.field_type(field))
      when :set
        ptr = expression(tree[1])
        type = ptr.ref_type
        field = tree[2]
        field_type = type.field_type(field)
        value = expression(tree[3])
        if value.type.jit_t != field_type.jit_t
          value = value.cast field_type
        end
        ptr.mstore(value, type.offset(field))
      when :call
        other_func = nil
        args = arguments(tree[2])
        
        if @reg.has_key? tree[1][0].to_sym
          obj = @reg[tree[1][0].to_sym]
          clazz = Cl::CLASSES[obj.ref_type.jit_t.address]
          args.insert(0, @reg[:self])
          other_func = clazz.get_function(tree[1].last)
        else
          obj = Cl
          tree[1][0..-2].each do |e|
            obj = obj.const_get(e)
          end
          other_func = obj.get_function(tree[1].last)
        end
        
        case other_func
        when Cl::Core::CFunction
          @function.c.call_native(other_func.name, *args)
        when Cl::Math::MathFunction
          @function.math.send(other_func.name, *args)
        else
          raise "No such method: #{tree[1][1..-1].join '.'}" if other_func.nil?
          @function.call_other *[other_func].concat(args)
        end
      when :arg
        @function.arg(tree[1])
      when :strz
        @function.stringz(tree[1])
      else
        # Oops!
        raise "Can't translate expression: #{tree.inspect}"
      end
    else
      if tree.is_a? Integer
        @function.const(tree, (tree < 0 ? :int64 : :uint64))
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
  
  def arguments(tree)
    tree.map do |arg|
      expression(arg)
    end
  end
  
  def type(tree)
    if tree.first == :class
      tree = tree[1..-1]
      obj = Cl
      tree.each do |e|
        obj = obj.const_get(e)
      end
      JIT::Type.create(:pointer, obj.struct_type)
    elsif tree.to_s == 'stringz'
      JIT::Type.create(:pointer, :uint8)
    else
      JIT::Type.create(*tree)
    end
  end
  
  def variable(tree)
    var = @reg[tree.to_sym]
    raise Coal::UndeclaredVariableError.new(tree) if var.nil?
    return var
  end
  
  def call_c_function name, *args
    JIT::LibC.send name, *args
  end
  
  def create_struct_type(fields)
    names = []
    types = []
    
    fields.each do |field|
      names << field.first
      types << type(field[1..-1])
    end
    
    st = JIT::StructType.new *types
    st.field_names = names
    
    return st
  end
end

end

