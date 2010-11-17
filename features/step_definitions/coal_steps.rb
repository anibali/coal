When /^I feed the parser (a valid|an invalid) (\w+), (.+)$/ do |_, rule, code|
  @parser.root = rule
  @result = @parser.parse(code)
end

When /^I require "([^"]*)"$/ do |lib|
  begin
    in_current_dir { require lib }
  rescue Exception => @exception
  end
end

Then /^no exception should be raised$/ do
  @exception.should be_nil
end

Then /^the Coal namespace should respond to "([^"]*)"$/ do |method|
  Coal.namespace.should respond_to method
end

Then /^it should parse successfully$/ do
  puts @parser.failure_reason if @result.nil?
  @result.should_not be_nil
end

Then /^it should parse successfully to a node with attributes {(.+)}$/ do |attrs|
  puts @parser.failure_reason if @result.nil?
  @result.should_not be_nil
  attrs = attrs.split(', ').map {|e| i = e.index ':' ; [e[0...i], e[i+1..-1].strip]}
  attrs.each do |k, v|
    @result.should respond_to k
    @result.send(k).should == eval(v)
  end
end

Then /^it should fail to parse$/ do
  @result.should be_nil
end

