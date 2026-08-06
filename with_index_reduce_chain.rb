#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: my first pass (1s/1s reduced timing) claimed each_with_object.with_index wins at every size -- CORRECTION from benchmark-ips defaults (2s/5s): the two are practically equivalent, with tiny (<2%) differences that flip direction by size -- with_index wins at 1/16/128/1024, reduce wins at 32/512. Neither a stable crossover nor a stable single winner; treat them as interchangeable.

TIMES = [1, 16, 32, 128, 512, 1_024]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    numbers = Array.new(i) { |num| num }.reverse

    x.report("each_with_index.reduce - #{i}") do # at benchmark-ips defaults: within <2% of with_index, actually ahead at 32 and 512
      numbers.each_with_index.reduce({}) do |memo, (value, index)|
        memo[index] = value
        memo
      end
    end

    x.report("each_with_object.with_index - #{i}") do # at benchmark-ips defaults: within <2% of reduce, ahead at 1/16/128/1024 but not 32/512 -- practically equivalent
      numbers.each_with_object({}).with_index do |(value, memo), index|
        memo[index] = value
      end
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
