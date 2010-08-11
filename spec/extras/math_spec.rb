require File.dirname(__FILE__) + "/../spec_helper"

begin
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

  describe Cl::Hailstone do
    describe ".run(113383)" do
      subject { Cl::Hailstone.run(113383) }
      it { should eql(247) }
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
    end
  end
rescue Exception => ex
  describe 'Coal::Math' do
    it "should not raise exceptions" do
      raise ex
    end
  end
end

