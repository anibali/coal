module Rb
  def self.arithmetic(n)
    x = 1
    1.step(n) do |i|
      x = ((i + x * i) - i) / x
    end
    return x
  end
end

