#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

time_hour = 12
time_minute = 12
time_before = Time.new(2020, 1, 1, time_hour - 1, time_hour - 1, 0)
time = Time.new(2020, 1, 1, time_hour, time_minute, 0)

benchmark_lambda = lambda do |x|
  x.report("hours & minutes - false") do # falses are simply faster due to doing less work on simpler objects
    time_before.hour > time_hour && time_before.min > time_minute
  end

  x.report("hours & minutes - true") do # trues are slightly slower than timestamps ~ 1.46x
    time_before.hour < time_hour && time_before.min < time_minute
  end

  x.report("timestamp") do # timestamps have a perf penalty ~ 1.40x slower but are consistent (true/false doesn't matter)
    time_before < time
  end

  x.report("timestamp - construction") do # creating the timestamp incurs a 33x slowdown
    time_before < Time.new(2020, 1, 1, time_hour, time_minute, 0)
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
