#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: my first pass (1s/1s reduced timing) claimed Array#include edges out Hash[] at 16 -- CORRECTION from benchmark-ips defaults (2s/5s): that was a timing artifact. Hash[] wins at every tested size (1/16/100/1000/10000) after all, matching the original finding.
TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    values = (0..i).to_a.shuffle
    array = []
    hash = {}
    values.each do |value|
      next if rand > 0.75

      array << value
      hash[value] = true
    end
    sorted_array = array.sort
    values.shuffle!

    x.report("Array#include - #{i}") do # faster than index except at 100 (flips there); Hash[] still beats it at every size incl. 16, at benchmark-ips defaults
      values.each { |value| array.include?(value) }
    end

    x.report("Array#index - #{i}") do
      values.each { |value| array.index(value) }
    end

    x.report("Array#bsearch - #{i}") do # only faster when i gets large
      values.each { |value| sorted_array.bsearch { |sorted_i| value <= sorted_i } }
    end

    x.report("Hash[] - #{i}") do # FASTEST at every size tested -- the "except 16" exception didn't hold at benchmark-ips defaults
      values.each { |value| hash[value] }
    end

    x.report("Hash#key? - #{i}") do # just a little slower than fastest
      values.each { |value| hash.key?(value) }
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
