#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

benchmark_lambda = lambda do |x|
  twenty_five_hours = 90_000
  x.report("utc first") do # 2x FASTER
    (Time.current.utc - twenty_five_hours).to_i
  end

  x.report("to_i") do
    (Time.current - twenty_five_hours).to_i
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil

# Time.current #=> ActiveSupport::TimeWithZone
# Ultimately TimeWithZone#to_i converts the timestamp to UTC
# Time.current.utc => Time where #- and #to_i are done in C
