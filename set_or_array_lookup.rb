#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'set'

TIMES = (1..5).to_a

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    array = (2..i).to_a + [1] # Worst case, item is last
    set = array.to_set

    x.report("#{i} - Array#include?") do # Faster _until_ there are 4+ elements
      array.include?(1)
    end

    x.report("#{i} -   Set#include?") do # Faster when there are 4+ elements
      set.include?(1)
    end
  end

  x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
