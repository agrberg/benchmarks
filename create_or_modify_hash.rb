#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 2, 4, 8, 16, 32, 100]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    hash = i.times.each_with_object({}) { |i, memo| memo[i.to_s] = i }

    x.report("Modify - #{i}") do # faster with object creation
      hash.each do |k, v|
        hash[k] = Hash.new(0)
      end
    end

    x.report("Create - #{i}") do
      hash.each_with_object({}) do |(k, v), memo|
        memo[k] = Hash.new(0)
      end
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
