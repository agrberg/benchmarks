#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

zero = 0
one = 1

benchmark_lambda = lambda do |x|
  x.report("zero? #=> true") do
    zero.zero?
  end

  x.report("zero? #=> false") do
    one.zero?
  end

  x.report("== 0 #=> true") do # this is faster because `==` is fast, `zero?` is normal speed in C
    zero == 0
  end

  x.report("== 0 #=> false") do # there is no difference if it is true or false
    one == 0
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
