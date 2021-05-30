#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

benchmark_lambda = lambda do |x|
  x.report('to_f/to_f') do
    4.to_f / 3.to_f
  end

  x.report('f/to_f') do
    4.0 / 3.to_f
  end

  x.report('to_f/f') do # Float#/ w/o conversion fastest `to_f`
    4.to_f / 3.0
  end

  x.report('to_f/i') do #
    4.to_f / 3
  end

  x.report('fdiv f') do # Int#fdiv w/o conversion; fastest overall
    4.fdiv(3.0)
  end

  x.report('fdiv to_f') do # Int#fdiv w/ explicit conversion fastest `fdiv`
    4.fdiv(3.to_f)
  end

  x.report('fdiv i') do # Int#fdiv conversion slower than all approaches
    4.fdiv(3)
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
