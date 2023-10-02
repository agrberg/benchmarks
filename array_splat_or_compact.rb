#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

benchmark_lambda = lambda do |x|
  a = nil
  b = "b"

  x.report("nil — splat") do
    [*a]
  end

  x.report("nil — compact") do # fastest of the nils
    [a].compact
  end

  x.report("present — splat") do # fastest over all and presence is faster than absence
    [*b]
  end

  x.report("present — compact") do
    [b].compact
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
