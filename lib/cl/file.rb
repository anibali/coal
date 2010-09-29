require 'coal'

Coal.class "File" do
  fields [
    ['handle', :pointer],
  ]
  
  getter 'handle'
  
  constructor [:pointer], <<-'end'
    self.handle = arg(1)
  end
  
  function 'open', [:stringz, :stringz], Cl::File, <<-'end'
    return(File.new(Core.fopen(arg(0), arg(1))))
  end
  
  method 'close', [], :void, <<-'end'
    Core.fclose(self.handle)
  end
end

