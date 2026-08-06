#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: "range w/o creation" vs "integer checks" was ~50% faster historically, now roughly tied (within benchmark-ips error margin) — CORRECTION from benchmark-ips defaults (2s/5s): that "tied" call was a 1s/1s timing artifact; range w/o creation is genuinely faster, and by more than the original claim (1.87x, not ~50%). "timestamp range" penalty at benchmark-ips defaults: 28.71x.

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

  x.report("timestamp range") do # 28.71x slower at benchmark-ips defaults; obj creation is slow
    (Time.new(2020, 1, 1, 9, 30, 0)...Time.new(2020, 1, 1, 16, 10, 0)).include?(time)
  end

  x.report("range w/o creation") do # still faster than integer checks, and by more than originally thought: 1.87x at benchmark-ips defaults
    range.include?(time)
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
