#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 2, 4, 8, 16, 32]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    test_hash = Array.new(i) { |number| [number, number.to_s] }.to_h

    x.report("each_with_object({}) - #{i}") do # faster up to 4
      test_hash.each_with_object({}) do |(k, v), memo|
        memo[k.to_s] = v.to_i * 10
      end
    end

    x.report("Array#to_h - #{i}") do # faster after 4
      test_hash.map do |k, v|
        [k.to_s, v.to_i * 10]
      end.to_h
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
