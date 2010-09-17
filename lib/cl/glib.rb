require 'coal'

begin
  require 'cl/glib/glib-ffi'
rescue LoadError
  require 'cl/glib/glib-ruby'
end

