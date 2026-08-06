#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'set'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: Array#sort#== and Set#== are now roughly tied (previously Array#sort#== was faster). CONFIRMED same-ish at benchmark-ips defaults (2s/5s) too.
benchmark_lambda = lambda do |x|
  array = [2, 1, 3, 4]
  set = Set.new([1, 2, 4, 3])

  x.report("Array#sort#==") do # roughly tied with Set#== now (previously faster)
    array.sort == [2, 1, 4, 3].sort
  end

  x.report("Set#==") do
    set == Set.new([3, 4, 1, 2])
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
