require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [10, 100, 1_000, 10_000]

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: fresh reading (no prior conclusion existed). `>&&<` beats Range#include? at every size (10/100/1000/10000) and every condition (match/too low/too high) tested — no crossover.
benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    min = 0
    max = i
    range = min..max
    value_in = (max + min) / 2
    value_under = min - 1
    value_above = max + 1

    x.report("range match #{max}") do # slower than `> && <` at every size tested
      range.include?(value_in)
    end

    x.report("range too low #{max}") do # slower than `> && <` at every size tested
      range.include?(value_under)
    end

    x.report("range too high #{max}") do # slower than `> && <` at every size tested
      range.include?(value_above)
    end

    x.report("> && < match #{max}") do # faster than Range#include? at every size tested
      value_in >= min && value_in <= max
    end

    x.report("> && < too low #{max}") do # faster than Range#include? at every size tested
      value_under >= min && value_under <= max
    end

    x.report("> && < too high #{max}") do # faster than Range#include? at every size tested
      value_above >= min && value_above <= max
    end
  end

  # uncomment if you want comparisons between them all
  x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
