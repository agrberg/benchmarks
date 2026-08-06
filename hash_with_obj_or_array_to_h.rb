#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 2, 4, 8, 16, 32, 100, 1_000]

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: extended TIMES to 1000 -- reveals a real three-regime pattern instead of pure noise: each_with_object wins small (1/4/8), Array#to_h takes over mid-range (16/32/100), each_with_object wins again at 1000. Size 2 specifically keeps flipping between runs (noise at that one point) so don't read too much into it, but the mid-range handoff to Array#to_h and the reversal back at 1000 have now shown up consistently.
benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    test_hash = Array.new(i) { |number| [number, number.to_s] }.to_h

    x.report("each_with_object({}) - #{i}") do # wins at 1/4/8, loses 16-100, wins again at 1000 (size 2 flips between runs -- noise)
      test_hash.each_with_object({}) do |(k, v), memo|
        memo[k.to_s] = v.to_i * 10
      end
    end

    x.report("Array#to_h - #{i}") do # wins 16-100 only; loses at the small end (1/4/8) and loses again at 1000
      test_hash.map do |k, v|
        [k.to_s, v.to_i * 10]
      end.to_h
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
