#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [10, 100, 1_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    arr = Array.new(i) { rand(1_000) }

    x.report("#{i} - sort_by(&:-@)") do
      arr.sort_by(&:-@)
    end

    x.report("#{i} - sort_by{-_1}") do # explicit block is faster but explicit or positional arg doesn't matter
      arr.sort_by { -_1 }
    end

    x.report("#{i} - sort_by{|i| -i}") do
      arr.sort_by { |i| -i }
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
