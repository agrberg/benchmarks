#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    x.report("first case") do
      puts 'first case'
    end

    x.report("2nd case") do
      puts '2nd case'
    end
  end

  # uncomment if you want comparisons between them all
  # x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
