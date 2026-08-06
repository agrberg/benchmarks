#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'date_core'
# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: ranking unchanged (to_date.iso8601 fastest, to_date.strftime long/short next and nearly tied, plain strftime long/short slowest)

time = Time.new(2020, 1, 1, 9, 30, 0)

benchmark_lambda = lambda do |x|
  x.report("to_date.iso8601") do # native so fastest of them all
    time.to_date.iso8601
  end

  x.report("to_date.strftime short") do # strftime is faster on dates than times no matter what
    time.to_date.strftime('%F')
  end

  x.report("to_date.strftime long") do # longer syntax is always faster
    time.to_date.strftime('%Y-%m-%d')
  end

  x.report("strftime short") do # amaingly somehow 1.27x slower
    time.strftime('%F') # equal to "%Y-%m-%d"
  end

  x.report("strftime long") do # a bit faster at 1.16x slower
    time.strftime('%Y-%m-%d')
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
