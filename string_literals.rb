require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

benchmark_lambda = lambda do |x|
  x.report("%w[]") do # same as [...] mostly
    %w[one two three]
  end

  x.report("manual array") do # same as %w[] mostly
    ['one', 'two', 'three']
  end

  x.report("manual array freeze") do # fastest over many iterations
    ['one'.freeze, 'two'.freeze, 'three'.freeze]
  end

  x.report("manual array map freeze") do # useless
    ['one', 'two', 'three'].map(&:freeze)
  end

  x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
