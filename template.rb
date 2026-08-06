#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Runtime ≈ reports_per_size × len(TIMES) × 7s at benchmark-ips defaults (2s warmup + 5s calc).
# For a *grid* sweep (TIMES.each nested inside TIMES.each), it's squared: × len(TIMES)^2 × 7s.
# Bias points toward the low end if you're hunting a crossover -- most of this repo's real
# crossovers landed below 100, and a low-N report is cheap regardless of how many you add.
TIMES = [1, 4, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    x.report("#{i} - FIRST_WAY") do
    end

    x.report("#{i} - SECOND_WAY") do
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
