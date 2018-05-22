#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 32, 128, 512, 1_024]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    numbers = Array.new(i) { |num| num }.reverse

    x.report("each_with_index.reduce - #{i}") do # gets slightly faster over 100 items
      numbers.each_with_index.reduce({}) do |memo, (value, index)|
        memo[index] = value
        memo
      end
    end

    x.report("each_with_object.with_index - #{i}") do # faster at first
      numbers.each_with_object({}).with_index do |(value, memo), index|
        memo[index] = value
      end
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
