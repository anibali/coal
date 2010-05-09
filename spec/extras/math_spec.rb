require File.dirname(__FILE__) + "/../spec_helper"
require 'coal/extras/math'

describe Coal::Math do

describe ".fibonacci(10)" do
  subject { Coal::Math.fibonacci(10) }
  it { should eql(55) }
end

describe ".fibonacci(19)" do
  subject { Coal::Math.fibonacci(19) }
  it { should eql(4181) }
end

describe ".factorial(5)" do
  subject { Coal::Math.factorial(5) }
  it { should eql(120) }
end

describe ".factorial(10)" do
  subject { Coal::Math.factorial(10) }
  it { should eql(3628800) }
end

describe ".prime(5)" do
  subject { Coal::Math.prime(5) }
  it { should eql(11) }
end

describe ".prime(11)" do
  subject { Coal::Math.prime(11) }
  it { should eql(31) }
end

describe ".pow_of_2(0)" do
  subject { Coal::Math.pow_of_2(0) }
  it { should eql(1) }
end

describe ".pow_of_2(40)" do
  subject { Coal::Math.pow_of_2(40) }
  it { should eql(1099511627776) }
end

end

