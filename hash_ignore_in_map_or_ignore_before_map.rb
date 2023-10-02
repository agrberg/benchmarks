#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

benchmark_lambda = lambda do |x|
  hash = {one: 1, two: 2, three: 3, four: 4}

  x.report(".map { |k _v| … }") do
    hash.map { |k, _v| [k.to_s, k] }
  end

  x.report(".each_key.map") do # slightly surprizingly slower by 1.19x
    hash.each_key.map { |k| [k.to_s, k] }
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
