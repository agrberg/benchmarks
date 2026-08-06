#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: Time.now.to_i still wins but the margin narrowed to 1.54x (was ~2x)

benchmark_lambda = lambda do |x|
  x.report('Time.now.utc.to_i') do
    Time.now.utc.to_i
  end

  x.report('Time.now.to_i') do #1.54x faster (was ~2x)
    Time.now.to_i
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
