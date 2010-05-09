require File.dirname(__FILE__) + "/spec_helper"

describe Coal do

describe "return(4 * 6)" do
  it { should eval_with_libjit_to_int32(24) }
  it { should eval_with_ruby_to_int32(24) }
end

describe "return(10 + 6)" do
  it { should eval_with_libjit_to_int32(16) }
  it { should eval_with_ruby_to_int32(16) }
end

describe "return(22 - 12)" do
  it { should eval_with_libjit_to_int32(10) }
  it { should eval_with_ruby_to_int32(10) }
end

describe "return(64 / 2)" do
  it { should eval_with_libjit_to_int32(32) }
  it { should eval_with_ruby_to_int32(32) }
end

describe "return(5 % 3)" do
  it { should eval_with_libjit_to_int32(2) }
  it { should eval_with_ruby_to_int32(2) }
end

describe "int8 x = 42 ; return(-x)" do
  it { should eval_with_libjit_to_int32(-42) }
  it { should eval_with_ruby_to_int32(-42) }
end

end

