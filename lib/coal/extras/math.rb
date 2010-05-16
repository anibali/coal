require 'coal'

module Coal::Math
  include Coal::Power
  
  defc 'self.fibonacci', [:uint32], :uint64, <<-end
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
  
  defc 'self.factorial', [:uint32], :uint64, <<-end
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
  defc 'self.prime', [:uint32], :uint64, <<-end
    uint32 n = arg(0)
    uint32 cur_n = 0
    uint32 num = 2
    uint32 ans = 0
    int8 running = true
    
    while(cur_n < n)
    {
      int8 prime = true
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
  
  defc 'self.pow_of_2', [:uint32], :uint64, <<-end
    uint32 n = arg(0)
    uint64 one = 1
    
    return(one << n)
  end
end

