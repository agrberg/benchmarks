#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: long still wins
benchmark_lambda = lambda do |x|
  x.report('tap block') do
    5.tap do |i|
      i.to_s
    end
  end

  x.report('tap proc') do
    5.tap(&:to_s)
  end

  x.report('long') do # Winner
    5.to_s
    5
  end

  # uncomment if you want comparisons between them all
  x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
