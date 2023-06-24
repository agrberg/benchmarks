#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'set'

ENUM_SIZES = [4, 16, 100, 1_000]
ENUM_COUNTS = [2, 4, 8, 16, 100]

benchmark_lambda = lambda do |x|
  # arrays = []
  # sets = []

  # 16.times do
  #   ENUM_SIZES.each do |size|
  #     array = []
  #     array << rand(1..(size * 2)) until array.size == size
  #     arrays << array

  #     set = Set.new
  #     set << rand(1..(size * 2)) until set.size == size
  #     sets << set
  #   end
  # end
  size = 100
  array1, array2 = [], []
  array1 << rand(1..(size * 2)) until array1.size == size
  array2 << rand(1..(size * 2)) until array2.size == size
  set1, set2 = Set.new, Set.new
  set1 << rand(1..(size * 2)) until set1.size == size
  set2 << rand(1..(size * 2)) until set2.size == size

  x.report("Array") do # Faster by .09x but I didn't verify the correctness of the benchmark
    (array1 + array2).sort.uniq
  end

  x.report("Set") do
    (set1 + set2).sort
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
