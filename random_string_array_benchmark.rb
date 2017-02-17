require 'ostruct'
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

chars = [*('a'..'z'), *('A'..'Z'), *('0'..'9')]

TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |num|
    x.report("times #{num}") do
      num.times.collect { chars.sample }.join
    end

    # Faster
    x.report("Array.new(#{num})") do
      Array.new(num) { chars.sample }.join
    end
  end
end

Benchmark.ips &benchmark_lambda
