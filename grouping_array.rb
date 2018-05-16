#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    items = Array.new(i) { |i| [i, i % 4] }

    x.report("each - #{i}") do # default proc penalty is gone >= 100 items
      res = Hash.new { |hash, key| hash[key] = [] }

      items.each do |(item, group_value)|
        res[group_value] << item
      end

      res
    end

    x.report("each w/ creation- #{i}") do # mannual creation is faster up until 16
      res = {}

      items.each do |(item, group_value)|
        res[group_value] ||= []
        res[group_value] << item
      end

      res
    end

    x.report("each_with_object - #{i}") do # slower than manual
      items.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |(item, group_value), memo|
        memo[group_value] << item
      end
    end

    x.report("each_with_object w/creation - #{i}") do # slower than manual
      items.each_with_object({}) do |(item, group_value), memo|
        memo[group_value] ||= []
        memo[group_value] << item
      end
    end

    x.report("group_by - #{i}") do # fastest always - though more processing later
      items.group_by(&:last)
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
