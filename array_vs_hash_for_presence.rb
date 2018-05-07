#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]

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

    x.report("Array#include - #{i}") do # faster than index
      values.each { |value| array.include?(value) }
    end

    x.report("Array#index - #{i}") do
      values.each { |value| array.index(value) }
    end

    x.report("Array#bsearch - #{i}") do # only faster when i gets large
      values.each { |value| sorted_array.bsearch { |sorted_i| value <= sorted_i } }
    end

    x.report("Hash[] - #{i}") do # FASTEST
      values.each { |value| hash[value] }
    end

    x.report("Hash#key? - #{i}") do # just a little slower than fastest
      values.each { |value| hash.key?(value) }
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
