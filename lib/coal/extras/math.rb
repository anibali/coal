require 'coal'

# TODO: Rename to "FastMath"?
module Coal::Math
  include Coal::Power
  
  defc 'self.fibonacci', [:uint32], :uint64, <<-'end'
    uint32 n = arg(0)
    uint64 fib_n = 2

    unless(n < 2)
    {
      uint64 fib_i_take_2 = 0
      uint64 fib_i_take_1 = 1
      uint32 i = 2

      while(i <= n)
      {
        fib_n = fib_i_take_2 + fib_i_take_1
        fib_i_take_2 = fib_i_take_1
        fib_i_take_1 = fib_n
        i += 1
      }
    }

    return(fib_n)
  end
  
  defc 'self.factorial', [:uint32], :uint64, <<-'end'
    uint32 n = arg(0)
    uint64 factorial = 1
    uint32 i = 1

    while(i <= n)
    {
      factorial *= i
      i += 1
    }

    return(factorial)
  end
  
  # TODO: Include a prime number generator which doesn't suck :)
  defc 'self.prime', [:uint32], :uint64, <<-'end'
    uint32 n = arg(0)
    uint32 cur_n = 0
    uint32 num = 2
    uint32 ans = 0
    
    while(cur_n < n)
    {
      bool prime = true
      int32 i = 2
      while(i < num)
      {
        if(num % i == 0)
        {
          prime = false
          break
        }
        i += 1
      }
      
      if(prime)
      {
        cur_n += 1
        ans = num
      }
      
      num += 1
    }

    return(ans)
  end
  
  defc 'self.pow_of_2', [:uint32], :uint64, <<-'end'
    uint32 n = arg(0)
    uint64 one = 1
    
    return(one << n)
  end
end

Coal.module 'MurmurHash2' do |m|
  # This is a working implementation of MurmurHash2.
  # Original code at: http://sites.google.com/site/murmurhash/MurmurHash2.cpp
  m.function 'hash', [[:pointer, :uint8], :uintn, :uint32], :uint32, <<-'end'
    @uint8 data = arg(0)
    uintn len = arg(1)
    uint32 seed = arg(2)
    
    uint32 m = 0x5bd1e995
    int32 r = 24
    
    uint32 h = seed ^ len
    
    while(len >= 4)
    {
      uint32 k = *data:uint32

      k *= m
      k ^= k >> r
      k *= m
    
      h *= m
      h ^= k

      data += 4
      len -= 4
    }
    
    if(len > 0)
    {
      uint32 k = *data:uint32
      if(len == 3) h ^= k & 0xff0000
      if(len >= 2) h ^= k & 0x00ff00
      h ^= k & 0x0000ff
      h *= m
    }

    h ^= h >> 13
    h *= m
    h ^= h >> 15

    return(h)
  end
  
  # Should always return 2013460684
  m.function 'hash_hello', [], :uint32, <<-'end'
    return(MurmurHash2.hash('hello', 5, 42))
  end
end

#puts(Cl::MurmurHash2.hash_hello == 2013460684 ? "Passed hash" : "Failed hash")

Coal.module "Math" do |m|
  m.class "ComplexNumber" do |c|
    c.fields [
      ['re', :int32],
      ['im', :int32]
    ]
    
    c.accessor 're', 'im'
    
    c.constructor [:int32, :int32], <<-'end'
      self.re = arg(1)
      self.im = arg(2)
    end
    
    c.method 'r', [], :int32, <<-'end'
      return(Math.sqrt(self.re ** 2 + self.im ** 2))
    end
    
    c.method 'conj', [], Cl::Math::ComplexNumber, <<-'end'
      return(Math.ComplexNumber.new(self.re, -self.im))
    end
    
    c.method 'add', [Cl::Math::ComplexNumber], Cl::Math::ComplexNumber, <<-'end'
      Math.ComplexNumber sum = Math.ComplexNumber.new(self.re, self.im)
      sum.re += arg(1).re
      sum.im += arg(1).im
      return(sum)
    end
    
    c.method 'to_stringz', [], :stringz, <<-'end'
      @uint8 str = Core.malloc(256)
      
      if(self.im == 0)
        Core.sprintf(str, '%d', self.re)
      else if(self.re == 0)
        Core.sprintf(str, '%di', self.im)
      else if(self.im > 0)
        Core.sprintf(str, '%d + %di', self.re, self.im)
      else if(self.im < 0)
        Core.sprintf(str, '%d - %di', self.re, -self.im)
        
      return(str)
    end
  end
end

Coal.module 'Hailstone' do |m|
  m.function 'run', [:uint64], :uint64, <<-'end'
    uint64 n = arg(0)
    uint64 steps
    
    if(n % 2 == 0)
      steps = Hailstone.even(n, 0)
    else
      steps = Hailstone.odd(n, 0)
    
    return(steps)
  end
  
  m.function 'odd', [:uint64, :uint64], :uint64, <<-'end'
    uint64 n = arg(0)
    uint64 steps = arg(1)
    
    if(n > 1)
      steps = Hailstone.even(3 * n + 1, steps + 1)
    
    return(steps)
  end
  
  m.function 'even', [:uint64, :uint64], :uint64, <<-'end'
    uint64 n = arg(0)
    uint64 steps = arg(1)
    
    n /= 2
    
    if(n % 2 == 0)
      steps = Hailstone.even(n, steps + 1)
    else
      steps = Hailstone.odd(n, steps + 1)
    
    return(steps)
  end
end

#p Cl::Math.square(-7)

