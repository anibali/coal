require 'aruba'
require 'coal'

Before do
  Coal.namespace.clear!
  @parser = Coal::Parser.new
end

