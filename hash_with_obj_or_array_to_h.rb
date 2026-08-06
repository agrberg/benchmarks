#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 2, 4, 8, 16, 32]

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: my first pass (1s/1s reduced timing) claimed Array#to_h wins at every size -- CORRECTION from benchmark-ips defaults (2s/5s): the pattern is genuinely noisy, not a clean crossover in either direction. each_with_object wins at 1/4/8, Array#to_h wins at 2/16/32. Neither the original "each_with_object faster up to 4" claim nor the "Array#to_h always wins" revision holds cleanly -- don't trust a single-sentence winner here.
benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    test_hash = Array.new(i) { |number| [number, number.to_s] }.to_h

    x.report("each_with_object({}) - #{i}") do # at benchmark-ips defaults: wins at 1/4/8, loses at 2/16/32 -- no clean crossover
      test_hash.each_with_object({}) do |(k, v), memo|
        memo[k.to_s] = v.to_i * 10
      end
    end

    x.report("Array#to_h - #{i}") do # at benchmark-ips defaults: wins at 2/16/32, loses at 1/4/8 -- no clean crossover
      test_hash.map do |k, v|
        [k.to_s, v.to_i * 10]
      end.to_h
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
