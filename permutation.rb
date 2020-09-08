#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
# Make sure you `gem install unique_permutations` - https://github.com/agrberg/unique_permutation
require 'unique_permutation'

TIMES = 1..10 # unique is faster at 8 items w/ 4 duplicates

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    half = i / 2
    array = ['duplicate'] * half + (i - half).times.map { |j| "unique #{j}" }

    x.report("#unique_permutation - #{i}") do
      array.unique_permutation.to_a
    end

    x.report("#permutation - #{i}") do
      array.permutation.to_a
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
