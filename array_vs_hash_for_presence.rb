#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: densified TIMES to localize the size-16 exception -- turned out there isn't one; Hash[] wins 8 through 1000, and Hash#key? overtakes it at 10000 (a new finding the old sparse range never surfaced). Caveat: size 1 is genuinely unstable run-to-run -- the setup below uses unseeded `rand` to build `array`/`hash`, so the *actual* size at "size 1" varies every run (sometimes 0 items, sometimes 1+). Don't trust whichever approach "wins" at size 1 specifically; it's setup noise, not a Ruby-version effect.
TIMES = [1, 8, 16, 32, 100, 1_000, 10_000]

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

    x.report("Array#include - #{i}") do # faster than index except at 100 (flips there); Hash[] beats it at every size from 8 on
      values.each { |value| array.include?(value) }
    end

    x.report("Array#index - #{i}") do
      values.each { |value| array.index(value) }
    end

    x.report("Array#bsearch - #{i}") do # only faster when i gets large
      values.each { |value| sorted_array.bsearch { |sorted_i| value <= sorted_i } }
    end

    x.report("Hash[] - #{i}") do # fastest from 8 through 1000; Hash#key? overtakes it at 10000
      values.each { |value| hash[value] }
    end

    x.report("Hash#key? - #{i}") do # just a little slower than Hash[] through 1000; overtakes it at 10000
      values.each { |value| hash.key?(value) }
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
