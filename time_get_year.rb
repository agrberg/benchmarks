#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'active_support'
require 'active_support/core_ext/time'
# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: previously crashed (missing base 'active_support' require — ActiveSupport::IsolatedExecutionState uninitialized), now fixed and running; was ~14% faster historically, now roughly tied (within benchmark-ips error margin). CORRECTION from benchmark-ips defaults (2s/5s): that "tied" call was a 1s/1s timing artifact — Time.now.year is genuinely faster, and by more than the original claim (1.38x, not ~14%).

benchmark_lambda = lambda do |x|
  x.report('Time.now.year') do # still faster, and by more than originally thought: 1.38x at benchmark-ips defaults (2s/5s)
    Time.now.year
  end

  x.report('Time.current.year') do
    Time.current.year
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
