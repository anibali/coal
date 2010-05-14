module VirtMem

MEM = ""

def self.allocate(size)
  addr = MEM.size
  MEM << "\0" * size
  return addr
end

def self.load(ptr, clazz)
  clazz.unpack MEM[ptr...ptr + clazz::SIZE]
end

def self.store(ptr, clazz, val)
  MEM[ptr...ptr + clazz::SIZE] = clazz.pack val
  val
end

class Number
end

class Int < Number
  def method_missing(name, *args, &blk)
    ret = @num.send(name, *args, &blk)
    ret.is_a?(Integer) ? self.class.new(ret) : ret
  end
  
  def == other
    @num == (other.is_a?(Int) ? other.to_numeric : other)
  end
  
  def to_numeric
    @num
  end
  
  def address
    if @address.nil?
      @address = VirtMem.allocate(self.class::SIZE)
      VirtMem.store(@address, self.class, @num)
    end
    #TODO: store type information in address (ie implement pointer types, yay!)
    @address
  end

  def to_s
    @num.to_s
  end
  
  def inspect
    @num.inspect
  end
end

class UInt8 < Int
  SIZE = 1
  
  def initialize(num)
    @num = num % 2**8
  end

  class << self
    def pack(num)
      [num].pack('C')
    end

    def unpack(str)
      new str.unpack('C').first
    end
  end
end

class Int8 < Int
  SIZE = 1

  def initialize(num)
    @num = (num + 2**7) % 2**8 - 2**7
  end

  class << self
    def pack(num)
      [num].pack('c')
    end

    def unpack(str)
      new str.unpack('c').first
    end
  end
end

class UInt16 < Int
  SIZE = 2
  
  def initialize(num)
    @num = num % 2**16
  end

  class << self
    def pack(num)
      [num].pack('S')
    end

    def unpack(str)
      new str.unpack('S').first
    end
  end
end

class Int16 < Int
  SIZE = 2
  
  def initialize(num)
    @num = (num + 2**15) % 2**16 - 2**15
  end

  class << self
    def pack(num)
      [num].pack('s')
    end

    def unpack(str)
      new str.unpack('s').first
    end
  end
end

class UInt32 < Int
  SIZE = 4
  
  def initialize(num)
    @num = num % 2**32
  end

  class << self
    def pack(num)
      [num].pack('L')
    end

    def unpack(str)
      new str.unpack('L').first
    end
  end
end

class Int32 < Int
  SIZE = 4
  
  def initialize(num)
    @num = (num + 2**31) % 2**32 - 2**31
  end

  class << self
    def pack(num)
      [num].pack('l')
    end

    def unpack(str)
      new str.unpack('l').first
    end
  end
end

class UInt64 < Int
  SIZE = 8
  
  def initialize(num)
    @num = num % 2**64
  end

  class << self
    def pack(num)
      [num].pack('Q')
    end

    def unpack(str)
      new str.unpack('Q').first
    end
  end
end

class Int64 < Int
  SIZE = 8
  
  def initialize(num)
    @num = (num + 2**63) % 2**64 - 2**63
  end

  class << self
    def pack(num)
      [num].pack('q')
    end

    def unpack(str)
      new str.unpack('q').first
    end
  end
end

class IntN < const_get("Int#{[1].pack('i').size * 8}")
end

class UIntN < const_get("UInt#{[1].pack('I').size * 8}")
end

#mem = Memory.new
#ptr = mem.allocate 4
#mem.store ptr, Int64, -12345
#p mem.load ptr, Int64

end

