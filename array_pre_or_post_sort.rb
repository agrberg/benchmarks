#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: ranking holds -- post sort fastest, pre sort slowest at every size
TIMES = [4, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    tenth_overlap = i / 10
    big_array = (1..i).to_a.shuffle
    small_array = ((i / 2)..(i + tenth_overlap)).to_a.shuffle

    x.report("pre sort - #{i}") do
      small_array.sort - big_array.sort
    end

    x.report("one sort - #{i}") do
      small_array.sort - big_array
    end

    x.report("post sort - #{i}") do # Array#sort is much slower than however the comparisons are done
      (small_array - big_array).sort
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
