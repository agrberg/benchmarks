#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

string = '5'
frozen_string = '5'.freeze
int = 5

benchmark_lambda = lambda do |x|
  x.report("String#to_i") do # 34% slower than no-op
    string.to_i
  end

  x.report("frozen String#to_i") do # slightly slower than non-frozen
    frozen_string.to_i
  end

  x.report("Integer#to_i") do # obviously faster - 34%
    int.to_i
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
