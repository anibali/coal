require 'coal'
require 'benchmark'
require 'benchmarks/c_functions'
require 'benchmarks/ruby_functions'

puts "=========="
puts "Benchmarks"
puts "=========="
puts

Benchmark.bmbm do |b|
  b.report("Heavy arithmetic (Coal)") { Cl.arithmetic(1000000) }
  b.report("Heavy arithmetic (Ruby)") { Rb.arithmetic(1000000) }
end

