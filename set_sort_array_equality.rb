#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'set'

benchmark_lambda = lambda do |x|
  array = [2, 1, 3, 4]
  set = Set.new([1, 2, 4, 3])

  x.report("Array#sort#==") do # faster
    array.sort == [2, 1, 4, 3].sort
  end

  x.report("Set#==") do
    set == Set.new([3, 4, 1, 2])
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
