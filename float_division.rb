#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

benchmark_lambda = lambda do |x|
  x.report('i/i') do # tied fastest w/ same, but doesn't give the intended value
    4 / 3
  end

  x.report('f/f') do # tied fastest w/ same but Float#/ is fastest overall
    4.0/3.0
  end

  x.report('f/i') do # `Float#/i` is fast but mixed is always slower than the same on both sides
    4.0/3
  end

  x.report('i/f') do # Int#/f is slower than Int#fdiv f
    4/3.0
  end

  x.report('to_f/') do # Float#/ has quick implicit conversion; fastest of the `to_f`s and top 3
    4.to_f / 3
  end

  x.report('to_f/f') do
    4.to_f / 3.0
  end

  # 2nd fastest of the `to_f`s and top 3
  # surprisingly, it seems that `/` is more expensive to call on an int
  # than it is to do 2 additional float conversions
  x.report('to_f/to_f') do
    4.to_f / 3.to_f
  end


  x.report('/to_f') do # Int#/ is simply slower; slowest of the `/to_f`s
    4 / 3.to_f
  end

  x.report('fdiv to_f') do # fastest of the `fdiv`s and top 3
    4.fdiv(3.to_f)
  end

  x.report('fdiv f') do # naturally faster `fdiv` is fast on Int and f doesn't need conversion
    4.fdiv(3.0)
  end

  x.report('fdiv f.to_f') do # about same as `fdiv to_f` no-op doesn't really save anything
    4.fdiv(3.0.to_f)
  end

  x.report('fdiv') do # bottom 3; `Int#fdiv`s has the slowest implicit to_f conversion
    4.fdiv(3)
  end

  x.report('to_f fdiv') do # `fdiv` is slower on floats but implicit is better than explicit conversion
    4.to_f.fdiv(3)
  end

  x.report('to_f fdiv to_f') do # clearly `fdiv` is slower on floats + cost of conversion
    4.to_f.fdiv(3.to_f)
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
