#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: my first pass (1s/1s reduced timing) called check-array vs force-array a toss-up -- CORRECTION from benchmark-ips defaults (2s/5s): force-array actually ties with check-item in one large same-ish cluster; check-array is a real, separate ~5-8% slower tier, not tied with force-array. check-item vs force-item still clearly favors checking (~2.3-2.4x). Net: forcing is cheap unless the object needs wrapping into a genuinely new array (the force-item case).
TIMES = [1, 2, 4, 8, 16, 32, 100, 1_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    array = i.times.to_a
    item = i

    # at benchmark-ips defaults: a real ~5-8% slower tier vs. force-array/check-item (not noise, but not dramatic either)
    x.report("check - array - #{i}") do
      result = array.is_a?(Array) ? array.first : array
    end

    x.report("check - item - #{i}") do # this is fastest but only because `first` doesn't need to be called
      result = item.is_a?(Array) ? item.first : item
    end

    x.report("force - array - #{i}") do
      result = Array(array).first
    end

    x.report("force - item - #{i}") do
      result = Array(item).first
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
