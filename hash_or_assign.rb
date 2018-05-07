#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    items = Array.new(i) { |num| num % 3 }

    x.report("= - #{i}") do # fastest
      hash = {}
      items.each do |item|
        hash[item] = true
      end
    end

    x.report("||= - #{i}") do # faster as i gets larger (starting at 100)
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
