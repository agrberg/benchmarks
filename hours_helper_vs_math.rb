#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

benchmark_lambda = lambda do |x|
  time_const = 90000 # 25.hours.to_i

  x.report("25.hours.ago.to_i") do # slower
    25.hours.ago.to_i
  end

  x.report("25.hours.from_now.to_i") do # slowest
    25.hours.from_now.to_i
  end

  x.report("(Time.current - CONST).to_i") do # within MoE as fastest
    (Time.current - time_const).to_i
  end

  x.report("(Time.current + CONST).to_i") do # fastest
    (Time.current + time_const).to_i
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
