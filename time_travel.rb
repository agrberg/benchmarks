#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'active_support'
require 'active_support/core_ext/numeric/time'
# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: previously crashed (missing base 'active_support' require — ActiveSupport::IsolatedExecutionState uninitialized), now fixed and running; finding unchanged, from_now still slightly faster (1.12x)

benchmark_lambda = lambda do |x|
  x.report('from_now') do # slightly faster
    3.minutes.from_now
  end

  x.report('now + ') do
    Time.current + 3.minutes
  end

  # uncomment if you want comparisons between them all
  x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
