# See culture.rb for details.

require 'rubygems'
require 'fileutils'
require 'pathname'
$LOAD_PATH << Pathname.new(__FILE__).expand_path.dirname.dirname.dirname.join('lib').to_s

require 'culture'

puts "Running Coal solution to 'Culture' on test data..."
puts "+--------------+--------------+--------------+--------------+"
puts "| Input        | Expected     | Actual       | Verdict      |"
puts "+--------------+--------------+--------------+--------------+"
[
  ["136", "17 3"],
  ["2", "1 1"],
  ["16384", "1 14"],
  ["3072", "3 10"],
  ["12", "3 2"]
].each do |input, expected|
  open('cultin.txt', 'w') { |f| f.write(input) }
  Cl::Culture.run
  actual = File.read('cultout.txt').strip
  verdict = actual == expected ? "Correct" : "*Incorrect*"
  puts "| #{input.ljust(12)} | #{expected.ljust(12)} | #{actual.ljust(12)} | #{verdict.ljust(12)} |"
  
  FileUtils.remove 'cultin.txt'
  FileUtils.remove 'cultout.txt'
end
puts "+--------------+--------------+--------------+--------------+"

puts "Done."

