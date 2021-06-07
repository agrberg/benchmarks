#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [10, 100, 1_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    arr = Array.new(i) { rand(1_000) }

    x.report("#{i} - sort.reverse") do # consistently faster on Ruby 3 and 2.5
      arr.sort.reverse
    end

    x.report("#{i} - sort { b <=> a }") do
      arr.sort { |a, b| b <=> a }
    end

    x.report("#{i} - sort_by(&:to_i).reverse") do
      arr.sort_by(&:to_i).reverse
    end

    x.report("#{i} - sort_by{_1.to_i}.reverse") do
      arr.sort_by { _1.to_i }.reverse
    end

    x.report("#{i} - sort_by(&:-@)") do
      arr.sort_by(&:-@)
    end

    x.report("#{i} - sort_by{-_1}") do # fastest for non-sortables (could depend on op in block) - more than &:proc
      arr.sort_by { -_1 }
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
