require 'coal'

Coal.class "String" do |c|
  c.fields [
    ['length', :uintn],
    ['chars', :pointer, :uint8],
  ]
  
  c.getter 'length'
  
  c.constructor [:uintn], <<-'end'
    self.chars = Core.malloc(arg(1))
    self.length = arg(1)
  end
  
  c.method 'resize', [:uintn], :void, <<-'end'
    self.chars = Core.realloc(self.chars, arg(1))
    self.length = arg(1)
  end
end

