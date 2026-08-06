#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: my first pass (1s/1s reduced timing) called this same-ish; benchmark-ips defaults (2s/5s) show a real ~1.14x gap, .map still ahead. The "same-ish" call was a timing-window artifact — original finding holds, just more modest than "consistently slower".
benchmark_lambda = lambda do |x|
  hash = {one: 1, two: 2, three: 3, four: 4}

  x.report(".map { |k _v| … }") do # still faster, ~1.14x at benchmark-ips defaults (not a tie)
    hash.map { |k, _v| [k.to_s, k] }
  end

  x.report(".each_key.map") do # still slower, ~1.14x, not tied with .map at benchmark-ips defaults
    hash.each_key.map { |k| [k.to_s, k] }
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
