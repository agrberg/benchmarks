#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

string = '5'
frozen_string = '5'.freeze
int = 5

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: changed — gap narrowed to ~17-18% (was 34%), and frozen String#to_i is now slightly faster than non-frozen (was slightly slower).
benchmark_lambda = lambda do |x|
  x.report("String#to_i") do # ~18% slower than Integer#to_i no-op; also slightly slower than frozen string
    string.to_i
  end

  x.report("frozen String#to_i") do # ~17% slower than no-op; slightly faster than non-frozen (reversed from prior reading)
    frozen_string.to_i
  end

  x.report("Integer#to_i") do # fastest - ~17-18% faster than the String#to_i variants
    int.to_i
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
