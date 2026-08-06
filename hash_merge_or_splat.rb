#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: ranking holds
TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  a = {one: 1, two: 2}
  b = {three: 3, four: 4}

  x.report("merge - 2") do # fastest — has some benefit from non-literal hash, splat - 2 has the outer hash and is the slowest
    a.merge(b)
  end

  x.report("merge - literal") do
    {one: 1, two: 2}.merge(b)
  end

  x.report("splat - 2") do
    {**a, **b}
  end

  x.report("splat - literal") do # slightly faster than merge - literal
    {one: 1, two: 2, **b}
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
