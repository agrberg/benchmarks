#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: my first pass (1s/1s reduced timing) called all four same-ish -- CORRECTION from benchmark-ips defaults (2s/5s): that was too strong a claim. `== 0` (true/false tie with each other) is genuinely ~1.13-1.14x faster than `zero?` (true/false tie with each other) -- original "== is faster" direction holds, just true/false doesn't matter within either method.

zero = 0
one = 1

benchmark_lambda = lambda do |x|
  x.report("zero? #=> true") do
    zero.zero?
  end

  x.report("zero? #=> false") do
    one.zero?
  end

  x.report("== 0 #=> true") do # still faster, ~1.13-1.14x, at benchmark-ips defaults (== is fast, zero? is "normal speed" in C) -- true/false doesn't matter within either method
    zero == 0
  end

  x.report("== 0 #=> false") do # there is no difference if it is true or false
    one == 0
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
