require 'coal'

Coal.class "File" do |c|
  c.fields [
    ['handle', :pointer],
  ]
  
  c.getter 'handle'
  
  c.constructor [:pointer], <<-'end'
    self.handle = arg(1)
  end
  
  c.function 'open', [:stringz, :stringz], Cl::File, <<-'end'
    return(File.new(Core.fopen(arg(0), arg(1))))
  end
  
  c.method 'close', [], :void, <<-'end'
    Core.fclose(self.handle)
  end
end

