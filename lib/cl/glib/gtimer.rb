require 'coal'
require 'cl/glib'

Coal.module "GLib" do |m|
  m.class "GTimer" do |c|
    c.fields [
      ['g_timer_ptr', :pointer],
    ]
    
    c.getter 'g_timer_ptr'
    
    c.constructor [], <<-'end'
      self.g_timer_ptr = GLib.g_timer_new()
    end
    
    c.method 'start', [], :void, <<-'end'
      GLib.g_timer_start(self.g_timer_ptr)
    end
    
    c.method 'stop', [], :void, <<-'end'
      GLib.g_timer_stop(self.g_timer_ptr)
    end
    
    c.method 'continue', [], :void, <<-'end'
      GLib.g_timer_continue(self.g_timer_ptr)
    end
    
    c.method 'elapsed', [], :float64, <<-'end'
      return(GLib.g_timer_elapsed(self.g_timer_ptr, 0))
    end
    
    c.destructor <<-'end'
      GLib.g_timer_destroy(self.g_timer_ptr)
    end
  end
end

#timer = Cl::GLib::GTimer.new
#timer.start
#sleep 0.1
#timer.stop
#sleep 0.1
#timer.continue
#sleep 0.1
#timer.stop
#p timer.elapsed # Should be ~0.2 seconds
#timer.destroy

