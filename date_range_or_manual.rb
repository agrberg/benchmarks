#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'date'

min_date = Date.parse('Jan 1, 2000')
max_date = Date.parse('Jan 1, 2050')
range = min_date..max_date

included_date = Date.parse('Jan 1, 2025')
missing_date = Date.parse('Jan 1, 3000')

benchmark_lambda = lambda do |x|
  x.report('range#include? - inclusion') do # MUCH SLOWER 26862.76x  slower
    range.include?(included_date)
  end

  x.report('range#include? - missing') do # 53821.20x  slower worst case
    range.include?(missing_date)
  end

  x.report('range#cover? - inclusion') do # fastest
    range.cover?(included_date)
  end

  x.report('range#cover? - missing') do
    range.cover?(missing_date)
  end

  x.report('manual - inclusion') do # only slightly slower than cover?
    included_date > min_date && included_date < max_date
  end

  x.report('manual - missing') do
    missing_date > min_date && missing_date < max_date
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
