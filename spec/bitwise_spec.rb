require File.dirname(__FILE__) + "/spec_helper"

describe Coal do

describe "return(106 & 63)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "return(21 ^ 63)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "return(40 | 10)" do
  it { should eval_with_libjit_to_int32(42) }
  it { should eval_with_ruby_to_int32(42) }
end

describe "uint8 x = 0 ; x = ~x ; return(x)" do
  it { should eval_with_libjit_to_int32(255) }
  it("should evaluate to 255 using the Ruby translator") { pending }
end

end

