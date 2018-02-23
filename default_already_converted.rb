#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

benchmark_lambda = lambda do |x|
  # Testing the benefits of having a pre-converted default a la `ENV.fetch('value_might_be_present', '0').to_f`

  x.report("convert string to float") do # 1.51x slower than preconverted (1.26x if frozen)
    '0'.to_f
  end

  x.report("convert int to float") do # about the same / always falls in the noise
    0.to_f
  end

  x.report("default already converted") do # fastest for sure
    0.0.to_f
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
