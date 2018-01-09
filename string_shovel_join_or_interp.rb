#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [5, 20, 100]
ALPHA = ('a'..'z').to_a

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    base_string = Array.new(i) { ALPHA.sample }.join

    TIMES.each do |j|
      string_to_append = Array.new(j) { ALPHA.sample }.join

      x.report("interpolation - #{i} + #{j} = #{i + j}") do # this is the fastest in almost all cases at all sizes
        "#{base_string}/#{string_to_append}"
      end

      x.report("join - #{i} + #{j} = #{i + j}") do
        [base_string, string_to_append].join('/')
      end

      x.report("<< - #{i} + #{j} = #{i + j}") do
        base_string.dup << string_to_append
      end

      x.report("interp + << - #{i} + #{j} = #{i + j}") do
        "#{base_string}/" << string_to_append
      end
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
