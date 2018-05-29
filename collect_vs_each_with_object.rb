#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    array = Array.new(i) { |num| num }

    x.report("collect - #{i}") do # fastest over all
      array.collect do |item|
        item.to_s
      end
    end

    x.report("collect w/ skips + compact - #{i}") do # faster than each w/ obj + skipping
      array.collect do |item|
        next if item.odd?

        item.to_s
      end.compact
    end

    x.report("collect w/ skips + reject - #{i}") do # slower than compact for simple nils
      array.collect do |item|
        next if item.odd?

        item.to_s
      end.reject(&:nil?)
    end

    x.report("each_with_object([]) - #{i}") do # slower than collect
      array.each_with_object([]) do |item, memo|
        memo << item.to_s
      end
    end

    x.report("each_with_object([]) w/ skips - #{i}") do # faster than w/o skips on each_with_object
      array.each_with_object([]) do |item, memo|
        next if item.odd?

        memo << item.to_s
      end
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
