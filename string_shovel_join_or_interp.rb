#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: multi-regime finding CONFIRMED at benchmark-ips defaults (2s/5s) — `<<` genuinely wins short-base+short-append, interpolation genuinely wins when the appended string is large relative to the base, `join` is consistently slowest. One correction: at 100+100, plain interpolation wins outright (not "interp + <<" as my first pass claimed).
TIMES = [5, 20, 100]
ALPHA = ('a'..'z').to_a

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    base_string = Array.new(i) { ALPHA.sample }.join

    TIMES.each do |j|
      string_to_append = Array.new(j) { ALPHA.sample }.join

      x.report("interpolation - #{i} + #{j} = #{i + j}") do # not a clear all-around winner: `<<` wins when both strings are short (5+5, 20+5, 20+20, 100+20), interpolation wins when the appended string is large relative to the base -- including at 100+100, confirmed at benchmark-ips defaults; `join` is consistently slowest
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
