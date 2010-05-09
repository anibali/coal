require File.dirname(__FILE__) + "/spec_helper"

describe Coal do

describe "int32 x = 42 ; return(x)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "int32 x = 7 ; x += 4 ; return(x)" do
  it { should eval_with_libjit_to_int32(11) }
  it { should eval_with_ruby_to_int32(11) }
end

describe "int32 x = 12 ; x -= 3 ; return(x)" do
  it { should eval_with_libjit_to_int32(9) }
  it { should eval_with_ruby_to_int32(9) }
end

describe "int32 x = 7 ; x *= 2 ; return(x)" do
  it { should eval_with_libjit_to_int32(14) }
  it { should eval_with_ruby_to_int32(14) }
end

describe "int32 x = 42 ; x /= 6 ; return(x)" do
  it { should eval_with_libjit_to_int32(7) }
  it { should eval_with_ruby_to_int32(7) }
end

describe "int32 x = 99 ; x %= 2 ; return(x)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "int32 x = 106 ; x &= 63 ; return(x)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "int32 x = 21 ; x ^= 63 ; return(x)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "int32 x = 40 ; x |= 10 ; return(x)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "int32 x = 21 ; x <<= 1 ; return(x)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "int32 x = 84 ; x >>= 1 ; return(x)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "int32 x ; return((x = 2) * 21)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "int32 x ; int32 y ; x = y = 13 ; return(x + y)" do
  it { should eval_with_libjit_to_int32(26) }
  it { should eval_with_ruby_to_int32(26) }
end

end

