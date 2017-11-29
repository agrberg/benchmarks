#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]
ALPHABET = ('a'..'z').to_a

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    word_chars = Array.new(i) { ALPHABET.sample }
    to_replace = word_chars.sample
    replace_with = '!'
    word = word_chars.join

    x.report("gsub #{i} chars") do
      word.gsub(to_replace, replace_with)
    end

    x.report("tr #{i} chars") do # tr is bonkers faster
      word.tr(to_replace, replace_with)
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
