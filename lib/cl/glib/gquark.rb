require 'coal'
require 'cl/glib'

Coal.module "GLib" do |m|
  m.class "GQuark" do |c|
    c.fields [
      ['id', :uint32],
    ]
    
    c.getter 'id'
    
    c.constructor [:stringz], <<-'end'
      self.id = GLib.g_quark_from_string(arg(1))
    end
    
    c.method 'to_sz', [], :stringz, <<-'end'
      return(GLib.g_quark_to_string(self.id))
    end
    
    c.destructor <<-'end'
    end
  end
end

# TODO: make dealing with strings agnostic of translator
class Cl::GLib::GQuark
  alias_method :old_to_sz, :to_sz
  
  def to_sz
    old_to_sz.get_string(0)
  end
  
  class << self
    alias_method :old_new, :new
    
    def new str
      old_new(FFI::MemoryPointer.from_string str)
    end
  end
end

#q = Cl::GLib::GQuark.new('hello')
#p q.to_sz
#q.destroy

