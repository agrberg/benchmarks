#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'active_support'
require 'active_support/core_ext/time'
# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: previously crashed (missing base 'active_support' require — ActiveSupport::IsolatedExecutionState uninitialized), now fixed and running; was ~1.4x slower historically, now roughly tied (within benchmark-ips error margin) — CORRECTION from benchmark-ips defaults (2s/5s): that "tied" call was a 1s/1s timing artifact; use_zone is genuinely slower, close to the original figure (1.29x, was ~1.4x).

time_zone = 'America/New_York'

benchmark_lambda = lambda do |x|
  x.report("use_zone") do # still slower: 1.29x at benchmark-ips defaults (close to the original ~1.4x)
    Time.use_zone(time_zone) { Time.current }
  end

  x.report("direct") do
    Time.find_zone(time_zone).now
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
