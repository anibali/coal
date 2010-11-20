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
        # Operations on files
        libc *%w[remove rename tmpfile, tmpnam]
        # File access functions
        libc *%w[fclose fflush fopen freopen setbuf setvbuf]
        # Formatted input/output functions
        libc *%w[fprintf fscanf printf scanf sprintf sscanf snprintf] #vprintf...
        # Character input/output functions
        libc *%w[fgetc fgets fputc fputs getc getchar gets putc putchar puts ungetc]
        # Direct input/output functions
        libc *%w[fread, fwrite]
        # File positioning functions
        libc *%w[fgetpos fseek fsetpos ftell rewind]
        # Error-handling functions
        libc *%w[clearerr feof ferror perror]
      when 'stdlib.h'
        # Numeric conversion functions
        libc *%w[atof atoi atol atoll strtod strtof 
          strtol strtoll strtoul strtoull] #strtold
        # Pseudo-random sequence generation functions
        libc *%w[rand srand]
        # Memory management functions
        libc *%w[calloc free malloc realloc]
        # Communication with the environment
        libc *%w[abort exit _Exit getenv system] #atexit
        # Searching and sorting utilities
        libc *%w[bsearch qsort]
        # Integer arithmetic functions
        libc *%w[abs labs llabs] #div, ldiv, lldiv
        # Multibyte/wide character conversion functions
        libc *%w[mblen] #mbtowc, wctomb
        # Multibyte/wide string conversion functions
        #mbstowcs, wcstombs
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

