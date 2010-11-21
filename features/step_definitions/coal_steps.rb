When /^I feed the parser (a valid|an invalid) (\w+), (.+)$/ do |_, rule, code|
  @parser.root = rule
  @result = @parser.parse(code)
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

When /^I require "([^"]*)"$/ do |lib|
  in_current_dir { require lib }
end

Then /^nothing exciting should happen$/ do
  # No excitement here
end

Then /^the "([^"]*)" Coal function should work$/ do |name|
  Coal.namespace.should respond_to name
  
  case name
  when "is_close"
    Coal.namespace.is_close(0.4, 0.6, 0.3).should_not == 0
    Coal.namespace.is_close(0.4, 0.6, 0.1).should == 0
  when "collatz"
    Coal.namespace.collatz(27).should == 111
  when "choose"
    Coal.namespace.choose(10, 5).should == 252
  when "binom_pdf"
    Coal.namespace.binom_pdf(10, 0.3, 5).should be_within(1e-6).of(0.1029193)
  when "forty_two"
    Coal.namespace.forty_two().should == 42
  end
end

