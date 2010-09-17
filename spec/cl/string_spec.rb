require File.dirname(__FILE__) + "/../spec_helper"

begin
  require 'cl/string'
  
  describe Cl::String do
    describe "when created with length 42" do
      let(:str) { Cl::String.new 42 }
      subject { str }
      
      its(:length) { should eql(42) }
      
      after do
        str.destroy
      end
    end
  end
rescue Exception => ex
  describe 'Coal::String' do
    it "should not raise exceptions" do
      raise ex
    end
  end
end

