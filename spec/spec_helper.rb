require File.dirname(__FILE__) + "/../lib/coal"

%w[uint8 int8 uint16 int16 uint32 int32 uint64 int64 float32 float64].each do |type|
  [Coal::Translators::LibJIT, Coal::Translators::Ruby].each do |clazz|
    class_name = clazz.to_s.split("::").last

    Spec::Matchers.define "eval_with_#{class_name.downcase}_to_#{type}" do |expected|
      match do |actual|
        JIT::Context.default.build_end unless JIT::Context.default.nil?
        tree = Coal::Parser.parse(actual)
        callable = clazz.new.compile_func([], type, tree)
        @result = callable.call
        @result == expected
      end
      
      failure_message_for_should do |actual|
        "expected that #{actual} would " << description << " but result was #{@result}"
      end
      
      failure_message_for_should_not do |actual|
        "expected that #{actual} would not " << description
      end
      
      description do
        "evaluate to #{expected} using the #{class_name} translator"
      end
    end
  end
end

