#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    arr = Array.new(i) { rand(1_000) }

    x.report("sort.reverse - #{i}") do # consistently faster on Ruby 3 and 2.5
      arr.sort.reverse
    end

    x.report("sort { b <=> a } - #{i}") do
      arr.sort { |a, b| b <=> a }
    end

    x.report("sort_by(&:-@) - #{i}") do
      arr.sort_by(&:-@)
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
