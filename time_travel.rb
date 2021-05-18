#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'active_support/core_ext/numeric/time'

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
