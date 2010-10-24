($LOAD_PATH << File.dirname(File.dirname(File.expand_path(__FILE__)))).uniq!
require 'spec_helper'

exception = nil

begin
  require 'cl/string'
  
  describe Cl::String do
    describe "when created with length 42" do
      let(:str) { Cl::String.new 42 }
      subject { str }
      
      its(:length) { should eql(42) }
    end
  end
rescue Exception => ex
  exception = ex
end

describe 'Cl::String' do
  it "should not raise an exception" do
    raise exception if exception
  end
end

