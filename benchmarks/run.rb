require 'coal'
require 'benchmark'
require 'benchmarks/c_functions'
require 'benchmarks/ruby_functions'

def fail
  print "FAIL"
end

puts "=========="
puts "Benchmarks"
puts "=========="
puts

Benchmark.bmbm do |b|
  b.report("1000th prime (Coal)") { fail if Cl.prime(1000) != 7919 }
  b.report("1000th prime (Ruby)") { fail if Rb.prime(1000) != 7919 }
end

