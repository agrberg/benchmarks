#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    hash = Hash[*i.times.map { |j| [j, j.to_s] }.flatten]
    values_to_remove_hash = {}
    new_val = rand(i)
    until values_to_remove_hash.size > i / 3
      new_val = rand(i) while values_to_remove_hash.key?(new_val)
      values_to_remove_hash[new_val] = new_val
    end
    values_to_remove = values_to_remove_hash.keys

    x.report("except - #{i}") do # faster - kinda obvious but I wanted to see
      hash.except(*values_to_remove)
    end

    x.report("reject - #{i}") do
      hash.reject { |k, _v| values_to_remove_hash[k] }
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
