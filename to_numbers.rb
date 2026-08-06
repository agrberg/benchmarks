#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: to_i w/ float and to_i w/ int are statistically tied (same-ish per benchmark-ips); to_f w/ int's edge over to_f w/ float narrowed to ~3% (was ~10%)

int = '10'.freeze
float = '10.0'.freeze

benchmark_lambda = lambda do |x|
  x.report("to_i w/ int") do
    int.to_i
  end

  x.report("to_i w/ float") do # fastest overall now, but statistically tied with to_i w/ int (same-ish per benchmark-ips)
    float.to_i
  end

  x.report("to_f w/ int") do # to_f is faster than to_f w/ float by ~3% now (was ~10%)
    int.to_f
  end

  x.report("to_f w/ float") do # there is almost no difference if the number is a float or int but int is slightly faster
    float.to_f
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
