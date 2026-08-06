#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require "active_support/core_ext/object/blank"

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: comparators still wins, ratio now ~2.79x (was 2.27x)
benchmark_lambda = lambda do |x|
  one = ""
  two = ""
  three = ""
  four = ""

  x.report("array") do
    [one, two, three, four].all?(&:blank?)
  end

  x.report("comparators") do # faster by 2.79x
    one.blank? && two.blank? && three.blank? && four.blank?
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
