# This Coal example is a solution to the problem stated at:
#   http://orac.amt.edu.au/aio/sample03/culture.html
# It demonstrates IO capabilities, loops and arithmetic.
#
# To prove that it works, run `ruby test_culture.rb`.

require 'coal'
require 'cl/file'

Coal.module 'Culture' do |m|
  m.function 'run', [], :void, <<-'end'
    File input = File.open('cultin.txt', 'r')
    File output = File.open('cultout.txt', 'w')
    
    int32 n
    Core.fscanf(input.handle(), '%d', @n)
    
    int32 b = n
    int32 d = 0
    
    # While b is even
    while(b & 1 == 0)
    {
      # Divide b by two
      b /= 2
      # Increment the number of days
      d += 1
    }
    
    Core.fprintf(output.handle(), '%d %d', b, d)
    
    input.close()
    output.close()
  end
end

# Cl::Culture.run

