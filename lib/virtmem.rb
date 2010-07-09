# Warning: This code is not for the faint-hearted
#
# VirtMem is a dirty, dirty hack which emulates RAM. That's right folks,
# I've made my own "virtual memory" with a string because I can't access memory
# directly with pure Ruby. Some of the heavy lifting is done with the Array#pack
# and String#unpack methods, but there's some seriously messed up stuff going
# on here. If anyone asks, Matz made me do it!

# VirtMem enables operations on virtual RAM stored in a string. It is a result
# of the negative side-effects of high-level abstraction.
module VirtMem

STACK_SIZE = 8 * 1024 * 1024 # 8 MiB
STACK_MEM = ""

# TODO: free memory

# Allocate memory from the stack
def self.stalloc(size)
  addr = STACK_MEM.size
  raise "Stack overflow!" if addr + size >= STACK_SIZE
  STACK_MEM << "\0" * size
  return addr
end

# Represents heap memory. STACK_SIZE <= heap pointer < RAM capacity
HEAP_MEM = ""

def self.malloc(size)
  addr = HEAP_MEM.size
  HEAP_MEM << "\0" * size
  return addr
end

# TODO: better use of scope to manage memory

@scope = -1

def self.narrow_scope
  @scope += 1
end

def self.widen_scope
  @scope -= 1
  STACK_MEM.replace("") if @scope < 0
end

def self.widest_scope
  widen_scope until @scope < 0
end

def self.load(ptr, type)
  ptr = ptr.to_numeric if ptr.respond_to? :to_numeric
  mem = ptr < STACK_SIZE ? STACK_MEM : HEAP_MEM
  Value.create type, type.unpack(mem[ptr...ptr + type.size])
end

def self.store(ptr, type, val)
  val = val.to_numeric if val.respond_to? :to_numeric
  mem = ptr < STACK_SIZE ? STACK_MEM : HEAP_MEM
  mem[ptr...ptr + type.size] = type.pack(val)
end

class Type
  def self.create *args
    if args.first.to_sym == :pointer
      PointerType.new self.create(*args[1..-1])
    else
      NumberType.new *args
    end
  end
end

class NumberType < Type
  attr_reader :size
  
  PACK_CHARS = {
    :int8 => 'c',
    :uint8 => 'C',
    :int16 => 's',
    :uint16 => 'S',
    :int32 => 'l',
    :uint32 => 'L',
    :int64 => 'q',
    :uint64 => 'Q',
    :intn => 'i',
    :uintn => 'I',
  }
  
  def initialize sym
    @sym = sym.to_sym
    
    @pack_char = PACK_CHARS[@sym]
    @size = [0].pack(@pack_char).size
  end
  
  def pack(num)
    [num].pack(@pack_char)
  end
  
  def unpack(str)
    str.unpack(@pack_char).first
  end
  
  def integer?
    true
  end
  
  def unsigned?
    @sym.to_s[0] == ?u
  end
  
  def signed?
    !unsigned?
  end
end

class PointerType < NumberType
  attr_reader :ref_type
  
  def initialize ref_type
    super(:uintn)
    
    @ref_type = ref_type
  end
end

class Value
  def self.create(*args)
    type = args.first
    if type.is_a? PointerType
      Pointer.new *args
    else
      Int.new *args
    end
  end
end

class Number < Value
end

class Int < Number
  def initialize type, num=nil
    num ||= 0
    @type = type
    bits = type.size * 8
    if type.signed?
      @num = (num + 2**(bits - 1)) % 2**bits - 2**(bits - 1)
    else
      @num = num % 2**bits
    end
  end

  def method_missing(name, *args, &blk)
    args.map! {|n| n.is_a?(self.class) ? n.to_numeric : n}
    ret = self.to_numeric.send(name, *args, &blk)
    ret.is_a?(Integer) ? self.class.new(@type, ret) : ret
  end
  
  def inspect
    to_numeric.inspect
  end
  
  def to_s
    to_numeric.to_s
  end
  
  def == other
    self.to_numeric == (other.is_a?(Int) ? other.to_numeric : other)
  end
  
  def eql? other
    self.to_numeric.eql?(other.is_a?(Int) ? other.to_numeric : other)
  end
  
  def store other
    @address = nil
    @num = (other.is_a?(Int) ? other.to_numeric : other)
    self
  end
  
  def to_numeric
    if @address.nil?
      @num
    else
      @num = self.address.dereference.to_numeric
    end
  end
  
  def address
    if @address.nil?
      num = self.to_numeric
      @address = VirtMem.stalloc(@type.size)
      VirtMem.store(@address, @type, num)
    end
    Pointer.new(PointerType.new(@type), @address)
  end
end

class Pointer < Int
  def initialize(type, num=nil)
    super(type, num)
    @type = type
  end
  
  def dereference(ref_type=nil)
    ref_type ||= @type.ref_type
    raise("TODO: default reference type for pointer") if ref_type.nil?
    VirtMem.load(self.to_numeric, ref_type)
  end
end

end

