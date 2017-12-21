#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 2, 4, 8, 16, 32, 100, 1_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    array = i.times.to_a
    item = i

    # checking is 1-2x faster
    x.report("check - array - #{i}") do
      result = array.is_a?(Array) ? array.first : array
    end

    x.report("check - item - #{i}") do # this is fastest but only because `first` doesn't need to be called
      result = item.is_a?(Array) ? item.first : item
    end

    x.report("force - array - #{i}") do
      result = Array(array).first
    end

    x.report("force - item - #{i}") do
      result = Array(item).first
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
