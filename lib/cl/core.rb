module Cl
  module Core
    extend Coal::ModuleExt
    
    C_FUNCTIONS =
      %w[
        puts putchar printf sprintf time rand malloc
        realloc free fprintf fscanf fopen fread fclose
      ] unless defined? C_FUNCTIONS
    
    def self.libjit_call! trans, name, *args
      if C_FUNCTIONS.include? name.to_s
        trans.function.c.call_native name, *args
      end
    end
    
    def self.method_missing name, *args
      if C_FUNCTIONS.include? name.to_s
        trans = Coal.translator_class.new
        if trans.is_a? Coal::Translators::LibJIT
          JIT::LibC::FUNCTIONS[name.to_sym].first.call *args
        else
          raise 'TODO: c function emulation in ruby'
        end
      else
        super
      end
    end
  end
end

