#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'active_support/core_ext/time'

benchmark_lambda = lambda do |x|
  x.report("now") do # 30% faster Ruby 3.0.1 Rails 6.1
    Time.now.utc
  end

  x.report("current") do
    Time.current.utc
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
