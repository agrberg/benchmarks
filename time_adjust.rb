#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'active_support'
require 'active_support/core_ext/time'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: my first pass (1s/1s reduced timing) called all four same-ish; benchmark-ips defaults (2s/5s) show that was too strong a claim. The two seconds_since_midnight variants tie with each other, the two beginning_of_day variants tie with each other, but seconds_since_midnight as a group is genuinely ~1.11-1.14x faster than beginning_of_day — original direction holds, just more modest than "much faster".
time1 = Time.new(2000, 1, 1, 12, 0, 0, '-00:00').utc
time2 = Time.new(2000, 1, 1, 13, 0, 0, '-00:00').utc
same_times = [time1, time1]
diff_times = [time1, time2]

benchmark_lambda = lambda do |x|
  # seconds_since_midnight (eq/neq tie with each other) is genuinely ~1.11-1.14x faster than beginning_of_day (eq/neq tie with each other) at benchmark-ips defaults
  x.report("seconds_since_midnight - eq") do
    same_times.map(&:seconds_since_midnight).uniq.size
  end

  x.report("seconds_since_midnight - neq") do
    diff_times.map(&:seconds_since_midnight).uniq.size
  end

  x.report("beginning_of_day - eq") do
    same_times.map(&:beginning_of_day).uniq.size
  end

  x.report("beginning_of_day - neq") do
    diff_times.map(&:beginning_of_day).uniq.size
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
