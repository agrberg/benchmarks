#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]
ALPHABET = ('a'..'z').to_a

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: tr still bonkers faster; regex-vs-string-arg gsub comparison shifted (see gsub /reg/ note below)
benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    word_chars = Array.new(i) { ALPHABET.sample }
    to_replace = word_chars.sample
    reg = %r[#{to_replace}]
    replace_with = '!'
    word = word_chars.join

    x.report("gsub #{i} chars") do
      word.gsub(to_replace, replace_with)
    end

    # significantly slower! /reg/ 1 char is now still faster than plain gsub @ 100 chars (used to be worse)
    # it's /reg/ @ 100 chars that's now roughly comparable to tr @ 1000
    x.report("gsub /reg/ #{i} chars") do
      word.gsub(reg, replace_with)
    end

    x.report("tr #{i} chars") do # tr is bonkers faster (replace >= 1 times in a 100 char string > gsub 1 @ 1 char)
      word.tr(to_replace, replace_with)
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
