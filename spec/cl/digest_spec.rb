require 'spec_helper'

begin
  require 'cl/digest'
  
  describe Cl::Digest do
    describe('murmurhash2("hello", 5, 42)') do
      subject { Cl::Digest.murmurhash2("hello", 5, 42) }
      it { should eql 2013460684 }
    end
  end
rescue Exception => ex
  describe 'Cl::Digest' do
    it "should not raise exceptions" do
      raise ex
    end
  end
end

