require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  x.report("%w[]") do
    %w[one two three]
  end

  x.report("manual array") do
    ['one', 'two', 'three']
  end

  x.report("manual array freeze") do
    ['one'.freeze, 'two'.freeze, 'three'.freeze]
  end
  # uncomment if you want comparisons between them all
  # x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
