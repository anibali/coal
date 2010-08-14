# This Coal example is a solution to the problem stated at:
#   http://orac.amt.edu.au/aio/sample03/culture.html
# It demonstrates IO capabilities, loops and arithmetic.
#
# To prove that it works, run `ruby test_culture.rb`.

require 'coal'

Coal.module 'Culture' do |m|
  m.function 'run', [], :void, <<-'end'
    pointer input = Core.fopen('cultin.txt', 'r')
    pointer output = Core.fopen('cultout.txt', 'w')
    
    int32 n
    Core.fscanf(input, '%d', @n)
    
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
    
    Core.fprintf(output, '%d %d', b, d)
    
    Core.fclose(input)
    Core.fclose(output)
  end
end

# Cl::Culture.run

