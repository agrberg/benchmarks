require 'ostruct'
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# chars = [*('a'..'z'), *('A'..'Z'), *('0'..'9')]

TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |num|
    hash = {}
    num.times.each {|i| hash[i] = i.to_s }
    test_keys = (0..num).to_a.sample((num / 2.0).ceil)

    x.report("array - array #{num}") do
      (test_keys - hash.keys).any?
    end

    x.report("has_key? #{num}") do
      test_keys.all? {|k| hash.has_key?(k) }
    end
  end
end

Benchmark.ips &benchmark_lambda
