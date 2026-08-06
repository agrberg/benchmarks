require 'ostruct'
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

chars = [*('a'..'z'), *('A'..'Z'), *('0'..'9')]

TIMES = [1, 16, 100, 1_000, 10_000]

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: Array.new still faster at 1, 16, 100, and 10000; at 1000 raw numbers show "times" ahead, but Array.new(1000)'s error margin (±60%) is too wide to call a real crossover.
benchmark_lambda = lambda do |x|
  TIMES.each do |num|
    x.report("times #{num}") do # faster than Array.new only at 1000, and that's within Array.new's very wide (±60%) error margin — not a reliable crossover
      num.times.collect { chars.sample }.join
    end

    # Faster at every size except 1000, where the comparison is too noisy to call
    x.report("Array.new(#{num})") do
      Array.new(num) { chars.sample }.join
    end
  end
end

Benchmark.ips &benchmark_lambda
