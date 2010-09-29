require 'coal'

Coal.class "String" do
  fields [
    ['length', :uintn],
    ['chars', :pointer, :uint8],
  ]
  
  getter 'length'
  
  constructor [:uintn], <<-'end'
    self.chars = Core.malloc(arg(1))
    self.length = arg(1)
  end
  
  method 'resize', [:uintn], :void, <<-'end'
    self.chars = Core.realloc(self.chars, arg(1))
    self.length = arg(1)
  end
  
  destructor <<-'end'
    Core.free(self.chars)
  end
end

