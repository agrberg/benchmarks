#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'active_support'
require 'active_support/core_ext/time'
# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: previously crashed (no ActiveSupport require at all), now fixed and running; finding REVERSED — "utc first" was 2x faster historically, now 1.16x slower than plain to_i. CONFIRMED at benchmark-ips defaults (2s/5s): 1.13x slower, same direction and similar magnitude — this is the reversal I was most worried was a timing artifact, and it isn't.

benchmark_lambda = lambda do |x|
  twenty_five_hours = 90_000
  x.report("utc first") do # was 2x FASTER historically; now REVERSED — 1.16x slower than to_i
    (Time.current.utc - twenty_five_hours).to_i
  end

  x.report("to_i") do # now the fastest (reversed from historical "utc first" advantage)
    (Time.current - twenty_five_hours).to_i
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil

# Time.current #=> ActiveSupport::TimeWithZone
# Ultimately TimeWithZone#to_i converts the timestamp to UTC
# Time.current.utc => Time where #- and #to_i are done in C
