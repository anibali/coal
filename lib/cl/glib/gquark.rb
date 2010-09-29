require 'coal'
require 'cl/glib'

Coal.module "GLib" do
  self.class "GQuark" do
    fields [
      ['id', :uint32],
    ]
    
    getter 'id'
    
    constructor [:stringz], <<-'end'
      self.id = GLib.g_quark_from_string(arg(1))
    end
    
    method 'to_sz', [], :stringz, <<-'end'
      return(GLib.g_quark_to_string(self.id))
    end
    
    destructor <<-'end'
    end
  end
end

#q = Cl::GLib::GQuark.new('hello')
#puts q.to_sz

