#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

benchmark_lambda = lambda do |x|
  # Directly comparing the values is always faster than using Array#include? as the creation of the array is not free

  x.report("1 item - Array") do
    [1].include?(10)
  end

  x.report("1 item - Comparison") do
    1 == 10
  end

  x.report("2 items - Array") do
    [2, 1].include?(10)
  end

  x.report("2 items - Comparison") do
    2 == 10 || 1 == 10
  end

  x.report("3 items - Array") do
    [3, 2, 1].include?(10)
  end

  x.report("3 items - Comparison") do
    3 == 10 || 2 == 10 || 1 == 10
  end

  x.report("4 items - Array") do
    [4, 3, 2, 1].include?(10)
  end

  x.report("4 items - Comparison") do
    4 == 10 || 3 == 10 || 2 == 10 || 1 == 10
  end

  x.report("5 items - Array") do
    [5, 4, 3, 2, 1].include?(10)
  end

  x.report("5 items - Comparison") do
    5 == 10 || 4 == 10 || 3 == 10 || 2 == 10 || 1 == 10
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
