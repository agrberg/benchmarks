#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: extended TIMES to 4096 to see if the shrinking margin (was ~5% at size 1) ever flips into a real gap -- it doesn't; it keeps converging (0.25% by 4096). Re-running this file gives a *different* size flips to reduce each time (only 512 flipped on this run, vs 32/512 on the previous one) -- confirms these two are genuinely noise-equivalent, not a crossover with a findable location. Treat them as interchangeable at any size.

TIMES = [1, 16, 32, 128, 512, 1_024, 2_048, 4_096]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    numbers = Array.new(i) { |num| num }.reverse

    x.report("each_with_index.reduce - #{i}") do # within <2% of with_index at every size; which one's ahead at a given size varies run to run
      numbers.each_with_index.reduce({}) do |memo, (value, index)|
        memo[index] = value
        memo
      end
    end

    x.report("each_with_object.with_index - #{i}") do # within <2% of reduce at every size; the gap keeps shrinking as size grows (0.25% by 4096) rather than diverging
      numbers.each_with_object({}).with_index do |(value, memo), index|
        memo[index] = value
      end
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
