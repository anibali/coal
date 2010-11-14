require 'spec_helper'

module Collatz
  extend Coal::Namespace
end

describe 'Collatz' do
  before(:all) do
    Coal.namespace = Collatz
    
    begin
      require 'c_files/collatz'
    rescue Exception => @exception
    end
  end
  
  it "should not raise an exception when loading collatz.c" do
    expect { raise @exception if @exception }.to_not raise_exception
  end
  
  it "should add the 'collatz' method" do
    Collatz.should respond_to :collatz
  end
  
  describe ".collatz(27)" do
    it { Collatz.collatz(27).should == 111 }
  end
  
  after(:all) do
    Coal.namespace = Cl
  end
end

