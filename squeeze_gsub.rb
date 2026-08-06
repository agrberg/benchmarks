#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: squeeze-family still fastest and gsub-family still slowest at every size (2-32); at size 4 squeeze/strip-and-squeeze/squeeze-and-strip are now a same-ish 3-way tie
REGEXP = /\s+/
STRINGS = 5.times.collect do |i|
  num_spaces = 2 ** (i + 1)
  string = 1.upto(num_spaces).collect do |num_space|
    "#{num_space}#{' ' * num_space}"
  end.join

  # For this purpose `squeeze` is the clear answer.

  # `strip` is comparitively a much faster operation than squeeze (avg 3x) or gsub (avg 11x)
  # its impact falls within the margin of error until the number of increasing space entries reaches 8
  # meaning until that point, `strip.squeeze` outperforms `gsub` without a final strip

  # `strip` should be done first until 8 as well

  benchmark_lambda = lambda do |x|
    x.report("#{num_spaces} squeeze spaces") do
      string.squeeze(' '.freeze)
    end

    x.report("#{num_spaces} gsub spaces") do
      string.gsub(REGEXP, ' '.freeze)
    end

    x.report("#{num_spaces} strip and squeeze") do
      string.strip.squeeze(' '.freeze)
    end

    x.report("#{num_spaces} squeeze and strip") do
      string.squeeze(' '.freeze).strip
    end

    x.report("#{num_spaces} strip and gsub") do
      string.strip.gsub(REGEXP, ' '.freeze).strip
    end

    x.report("#{num_spaces} gsub and strip") do
      string.gsub(REGEXP, ' '.freeze).strip
    end

    x.compare! # uncomment if you want comparisons between them all
  end

  Benchmark.ips(&benchmark_lambda)
end
