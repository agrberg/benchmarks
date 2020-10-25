#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]
ALPHABET = ('a'..'z').to_a
words = Hash[TIMES.map do |times|
  [times, Array.new(times) { ALPHABET.sample }.join]
end]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    word = words[i]

    x.report('/#{string}/' + " - #{i}") do # more or less the same, too noisy
      /#{word}/
    end

    x.report('%r[#{string}]' + " - #{i}") do
      %r[#{word}]
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
