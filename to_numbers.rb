#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

int = '10'.freeze
float = '10.0'.freeze

benchmark_lambda = lambda do |x|
  x.report("to_i w/ int") do
    int.to_i
  end

  x.report("to_i w/ float") do
    float.to_i
  end

  x.report("to_f w/ int") do # suprizingly to_f is faster by ~ 10%
    int.to_f
  end

  x.report("to_f w/ float") do # there is almost no difference if the number is a float or int but int is slightly faster
    float.to_f
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
