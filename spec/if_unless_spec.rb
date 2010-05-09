require File.dirname(__FILE__) + "/spec_helper"

describe Coal do

describe "if(true) { return(1) }; return(0)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "if(true) return(1); return(0)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "if(true) {}; return(1)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "if(false) { return(0) } else { return(1) } ; return(-1)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "if(false) { return(0) } else if(true) { return(1) } ; return(-1)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "unless(false) { return(1) }; return(0)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "unless(false) return(1); return(0)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "unless(false) {}; return(1)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "unless(true) { return(0) } else { return(1) } ; return(-1)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "unless(true) { return(0) } else unless(false) { return(1) } ; return(-1)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

describe "unless(true) { return(0) } else if(true) { return(1) } ; return(-1)" do
  it { should eval_with_libjit_to_int32(1) }
  it { should eval_with_ruby_to_int32(1) }
end

end

