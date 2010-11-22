module Rb
  def self.prime(n)
    return 2 if n == 1
    
    x = 1
    m = 1
    
    while(m < n)
      x += 1
      y = 2
      while(x % y != 0)
        m += 1 if (y += 1) / x == 1
      end
    end
    
    return x
  end
end

