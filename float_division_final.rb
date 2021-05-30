#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

benchmark_lambda = lambda do |x|
  x.report('ensure Int#fdiv, explicit converison') do
    4.0.to_i.fdiv 3.to_f
  end

  x.report('ensure Float#/, interal conversion') do # Float#/ w/ internal is much faster
    4.to_f / 3
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
