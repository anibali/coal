($LOAD_PATH << File.dirname(File.dirname(File.expand_path(__FILE__)))).uniq!
require 'spec_helper'

describe Cl::Math do
  describe ".fibonacci(10)" do
    subject { Cl::Math.fibonacci(10) }
    it { should eql(55) }
  end

  describe ".fibonacci(19)" do
    subject { Cl::Math.fibonacci(19) }
    it { should eql(4181) }
  end

  describe ".factorial(5)" do
    subject { Cl::Math.factorial(5) }
    it { should eql(120) }
  end

  describe ".factorial(10)" do
    subject { Cl::Math.factorial(10) }
    it { should eql(3628800) }
  end

  describe ".prime(5)" do
    subject { Cl::Math.prime(5) }
    it { should eql(11) }
  end

  describe ".prime(11)" do
    subject { Cl::Math.prime(11) }
    it { should eql(31) }
  end
  
  describe ".choose(10, 5)" do
    subject { Cl::Math.choose(10, 5) }
    it { should eql(252) }
  end
end

describe Cl::Math::ComplexNumber do
  context "when representing 3 + 4i" do
    let(:z) { Cl::Math::ComplexNumber.new(3, 4) }
    subject { z }
    
    its('re') { should eql(3) }
    its('im') { should eql(4) }
    
    describe "conj" do
      subject { z.conj }
      
      its('re') { should eql(3) }
      its('im') { should eql(-4) }
    end
    
    its('r') { should eql(5) }
    
    context "when added to 2 - 7i" do
      subject { z.add Cl::Math::ComplexNumber.new(2, -7) }
      
      its('re') { should eql(5) }
      its('im') { should eql(-3) }
    end
    
    its('to_stringz') { should eql("3 + 4i") }
  end
end

