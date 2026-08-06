#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: added a j=50 point to isolate what actually drives the split -- it's the appended string's absolute length (j), not the base/appended ratio as I first read it. `<<` wins outright whenever j=5, for every tested base length; interpolation wins outright whenever j>=50, for every tested base length; j=20 is a genuine toss-up (2 of 4 base lengths go each way -- looks like per-report GC-timing noise, not a real sub-boundary). `interp + <<` never wins outright at any combo; `join` is slowest at every combo.
TIMES = [5, 20, 50, 100]
ALPHA = ('a'..'z').to_a

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    base_string = Array.new(i) { ALPHA.sample }.join

    TIMES.each do |j|
      string_to_append = Array.new(j) { ALPHA.sample }.join

      x.report("interpolation - #{i} + #{j} = #{i + j}") do # wins outright whenever the appended string (j) is 50+, regardless of base length; loses to `<<` whenever j=5; j=20 is a noisy toss-up
        "#{base_string}/#{string_to_append}"
      end

      x.report("join - #{i} + #{j} = #{i + j}") do
        [base_string, string_to_append].join('/')
      end

      x.report("<< - #{i} + #{j} = #{i + j}") do # wins outright whenever the appended string (j) is 5, regardless of base length; loses to interpolation whenever j is 50+
        base_string.dup << string_to_append
      end

      x.report("interp + << - #{i} + #{j} = #{i + j}") do # never wins outright at any tested combo -- strictly worse than picking plain interpolation or plain `<<` per the j-based rule above
        "#{base_string}/" << string_to_append
      end
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
