#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

benchmark_lambda = lambda do |x|
  x.report('Time.now.utc.to_i') do
    Time.now.utc.to_i
  end

  x.report('Time.now.to_i') do #2x faster
    Time.now.to_i
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
