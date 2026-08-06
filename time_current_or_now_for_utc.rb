#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'active_support'
require 'active_support/core_ext/time'
# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: previously crashed (missing base 'active_support' require — ActiveSupport::IsolatedExecutionState uninitialized), now fixed and running; now.utc is 1.62x faster than current.utc (was ~1.3x on Ruby 3.0.1/Rails 6.1)

benchmark_lambda = lambda do |x|
  x.report("now") do # 30% faster Ruby 3.0.1 Rails 6.1; Ruby 4.0.6: 1.62x faster
    Time.now.utc
  end

  x.report("current") do
    Time.current.utc
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
