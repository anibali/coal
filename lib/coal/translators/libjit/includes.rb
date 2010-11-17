module Coal::Translators ; LibJIT.class_eval do
  
  class Includes
    def self.add trans, name
      case name
      when 'math.h'
        trans.add_special_function('pow') { |f, a, b| a ** b }
        trans.add_special_function('powf') { |f, a, b| a ** b }
        # ...
      when 'stdio.h'
        trans.add_special_function('printf') { |f, *args| f.c.printf *args }
        # ...
      else
        raise "missing include: #{name}" if inc.nil?
      end
    end
  end

end ; end

