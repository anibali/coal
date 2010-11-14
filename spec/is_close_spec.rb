require 'spec_helper'

module IsClose
  extend Coal::Namespace
end

describe 'IsClose' do
  before(:all) do
    Coal.namespace = IsClose
    
    begin
      require 'c_files/is_close'
    rescue Exception => @exception
    end
  end
  
  it "should not raise an exception when loading is_close.c" do
    expect { raise @exception if @exception }.to_not raise_exception
  end
  
  it "should add the 'is_close' method" do
    IsClose.should respond_to :is_close
  end
  
  describe ".is_close(0.4, 0.6, 0.3)" do
    it { IsClose.is_close(0.4, 0.6, 0.3).should_not == 0 }
  end
  
  describe ".is_close(0.4, 0.6, 0.1)" do
    it { IsClose.is_close(0.4, 0.6, 0.1).should == 0 }
  end
  
  after(:all) do
    Coal.namespace = Cl
  end
end

