#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'active_support/core_ext/time'

time_zone = 'America/New_York'

benchmark_lambda = lambda do |x|
  x.report("use_zone") do # 1.4x slower
    Time.use_zone(time_zone) { Time.current }
  end

  x.report("direct") do
    Time.find_zone(time_zone).now
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
