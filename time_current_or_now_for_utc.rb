#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

benchmark_lambda = lambda do |x|
  twenty_five_hours = 90_000
  x.report("now") do # 700% FASTER O_o
    Time.now.utc
  end

  x.report("current") do
    Time.current.utc
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
