module Cl
  module Math
    extend Coal::ModuleExt
    
    MATH_FUNCTIONS = 
      %w[
        acos asin atan atan2 ceil cos cosh exp floor
        log log rint round sin sinh sqrt tan tanh
      ] unless defined? MATH_FUNCTIONS
    
    def self.libjit_call! trans, name, *args
      if MATH_FUNCTIONS.include? name.to_s
        trans.function.math.send name, *args
      end
    end
  end
end

Coal.module 'Math' do
  function 'fibonacci', [:uint32], :uint64, <<-'end'
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
  
  function 'factorial', [:uint32], :uint64, <<-'end'
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
  function 'prime', [:uint32], :uint64, <<-'end'
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
  
  function 'choose', [:uint32, :uint32], :uint64, <<-'end'
    uint32 n = arg(0)
    uint32 r = arg(1)
    if(n - r < r) r = n - r
    if(r == 0) return(1)
    uint64 result = n
    uint32 i = 1
    while(i < r)
    {
      result /= i
      result *= n - i
      i += 1
    }
    return(result / r)
  end
  
  # See http://www.lomont.org/Math/Papers/2003/InvSqrt.pdf
  function 'inv_sqrt', [:float32], :float32, <<-'end'
    float32 x = arg(0)
    
    int32 i = *(@x):int32
    i = 0x5f375a86 - (i >> 1)
    x = *(@i):float32
    
    float32 half_x = x / 2
    # Yucky. Coal doesn't have float constants yet...
    float32 three_halves = 3 ; three_halves /= 2
    
    x *= three_halves - half_x * x * x # Repeat this step for greater accuracy
    
    return(x)
  end
  
  self.class "ComplexNumber" do
    fields [
      ['re', :int32],
      ['im', :int32]
    ]
    
    accessor 're', 'im'
    
    constructor [:int32, :int32], <<-'end'
      self.re = arg(1)
      self.im = arg(2)
    end
    
    method 'r', [], :int32, <<-'end'
      return(Math.sqrt(self.re ** 2 + self.im ** 2))
    end
    
    method 'conj', [], Cl::Math::ComplexNumber, <<-'end'
      return(Math.ComplexNumber.new(self.re, -self.im))
    end
    
    method 'add', [Cl::Math::ComplexNumber], Cl::Math::ComplexNumber, <<-'end'
      Math.ComplexNumber sum = Math.ComplexNumber.new(self.re, self.im)
      sum.re += arg(1).re
      sum.im += arg(1).im
      return(sum)
    end
    
    method 'to_stringz', [], :stringz, <<-'end'
      stringz str = Core.malloc(256)
      
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

