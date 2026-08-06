#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'active_support'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/time'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: previously undocumented missing 'active_support' require (only worked via ambient Rails env) — now fixed and running standalone. Finding changed: (Time.current - CONST) is now the outright fastest, with (Time.current + CONST) same-ish (previously the labels were reversed).
benchmark_lambda = lambda do |x|
  time_const = 90000 # 25.hours.to_i

  x.report("25.hours.ago.to_i") do # slower
    25.hours.ago.to_i
  end

  x.report("25.hours.from_now.to_i") do # slowest
    25.hours.from_now.to_i
  end

  x.report("(Time.current - CONST).to_i") do # fastest
    (Time.current - time_const).to_i
  end

  x.report("(Time.current + CONST).to_i") do # same-ish with the "-" version, within error
    (Time.current + time_const).to_i
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
