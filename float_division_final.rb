#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: ranking holds (Float#/ still ahead, though the gap is now a more modest 1.17x rather than "much")
benchmark_lambda = lambda do |x|
  x.report('ensure Int#fdiv, explicit converison') do
    4.0.to_i.fdiv 3.to_f
  end

  x.report('ensure Float#/, interal conversion') do # Float#/ w/ internal is much faster
    4.to_f / 3
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
