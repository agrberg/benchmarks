#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: densified TIMES to localize the crossover -- it's pinned precisely between 8 and 16 ("=" still wins at 1/4/8, "||=" takes over at 16+). "=" becomes the slowest from 1000+; "default" wins from 100+.
TIMES = [1, 4, 8, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    items = Array.new(i) { |num| num % 3 }

    x.report("= - #{i}") do # fastest through 8 items (tied w/ ||= only at 1); "||=" takes over at 16, "=" becomes outright slowest from 1000+
      hash = {}
      items.each do |item|
        hash[item] = true
      end
    end

    x.report("||= - #{i}") do # ties "=" at 1, loses through 8, takes over at 16 and stays ahead; default overtakes both from 100+
      hash = {}
      items.each do |item|
        hash[item] ||= true
      end
    end

    x.report("default - #{i}") do # not a great solution but interesting - faster starting at 100
      hash = Hash.new { |hash, key| hash[key] = true }
      items.each do |item|
        hash[item]
      end
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
