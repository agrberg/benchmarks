#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

market_hours = 10..15
time_hour = 16
time_minute = 9
time = Time.new(2020, 1, 1, time_hour, time_minute, 0)
range = Time.new(2020, 1, 1, 9, 30, 0)...Time.new(2020, 1, 1, 16, 10, 0)

benchmark_lambda = lambda do |x|
  x.report("integer checks") do
    market_hours.include?(time.hour)
    time.hour == 9 && time.min >= 30
    time.hour == 16 && time.min < 10
  end

  x.report("timestamp range") do # 21.40x slower obj creation is slow
    (Time.new(2020, 1, 1, 9, 30, 0)...Time.new(2020, 1, 1, 16, 10, 0)).include?(time)
  end

  x.report("range w/o creation") do # 50% faster if you can swing it
    range.include?(time)
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
