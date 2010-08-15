require File.dirname(__FILE__) + "/../spec_helper"

begin
  require 'cl/string'
  
  describe Cl::String do
    describe "when created with length 42" do
      subject { Cl::String.new 42 }
      
      its(:length) { pending ; should eql(42) }
    end
  end
rescue Exception => ex
  describe 'Coal::String' do
    it "should not raise exceptions" do
      raise ex
    end
  end
end
