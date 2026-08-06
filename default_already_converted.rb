#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: int-to-float now nominally edges out "default already converted" (same-ish, statistically tied); no longer a clear-cut "fastest for sure". CONFIRMED same-ish at benchmark-ips defaults (2s/5s) too.
benchmark_lambda = lambda do |x|
  # Testing the benefits of having a pre-converted default a la `ENV.fetch('value_might_be_present', '0').to_f`

  x.report("convert string to float") do # 1.89x slower than preconverted (1.26x if frozen)
    '0'.to_f
  end

  x.report("convert int to float") do # now nominally fastest, but same-ish/tied with default already converted
    0.to_f
  end

  x.report("default already converted") do # roughly tied with int-to-float now (same-ish) — no longer clearly "fastest for sure"
    0.0.to_f
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
