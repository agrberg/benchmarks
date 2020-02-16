#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'active_support'
require 'active_support/core_ext/time'

time1 = Time.new(2000, 1, 1, 12, 0, 0, '-00:00').utc
time2 = Time.new(2000, 1, 1, 13, 0, 0, '-00:00').utc
same_times = [time1, time1]
diff_times = [time1, time2]

benchmark_lambda = lambda do |x|
  # more or less equal in operation, however, comparison of int `seconds_since_midnight`
  # is much faster than dates
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
