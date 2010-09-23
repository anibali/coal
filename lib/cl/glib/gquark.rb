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

q = Cl::GLib::GQuark.new('hello')
puts q.to_sz
q.destroy

