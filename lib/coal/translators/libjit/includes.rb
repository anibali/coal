module Coal::Translators ; LibJIT.class_eval do
  
  class Includes
    def self.add trans, name
      @translator = trans
      case name
      when 'math.h'
        asf('pow') { |f, a, b| a ** b }
        asf('powf') { |f, a, b| a ** b }
        # ...
      when 'stdio.h'
        libc *%w[remove rename tmpfile, tmpnam]
        libc *%w[fclose fflush fopen freopen setbuf] #setvbuf
        libc *%w[fprintf fscanf printf scanf sprintf sscanf] #snprintf, vprintf...
        libc *%w[fgetc fgets fputc fputs getc getchar gets putc putchar puts ungetc]
        #fread, fwrite
        libc *%w[fgetpos fseek fsetpos ftell rewind]
        libc *%w[clearerr feof ferror perror]
      else
        raise "missing include: #{name}" if inc.nil?
      end
    end
    
    private
    def self.asf(*args, &block)
      @translator.add_special_function *args, &block
    end
    
    def self.libc *names
      names.each do |name|
        asf(name) { |f, *args| f.c.call_native(name, *args) }
      end
    end
  end

end ; end

