#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'active_support/core_ext/time'

benchmark_lambda = lambda do |x|
  x.report('Time.now.year') do # 14% faster
    Time.now.year
  end

  x.report('Time.current.year') do
    Time.current.year
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
