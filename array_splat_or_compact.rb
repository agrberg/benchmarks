#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: reversed -- nil-splat is now fastest overall (was present-splat), and splat beats compact within the nil group (was the other way around). CONFIRMED at benchmark-ips defaults (2s/5s).
benchmark_lambda = lambda do |x|
  a = nil
  b = "b"

  x.report("nil — splat") do # fastest overall now
    [*a]
  end

  x.report("nil — compact") do # no longer fastest of the nils -- nil-splat wins that now
    [a].compact
  end

  x.report("present — splat") do # second fastest overall; nil-splat now beats it
    [*b]
  end

  x.report("present — compact") do # roughly tied with nil-compact for slowest
    [b].compact
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
