#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require "active_support/core_ext/object/blank"

benchmark_lambda = lambda do |x|
  one = ""
  two = ""
  three = ""
  four = ""

  x.report("array") do
    [one, two, three, four].all?(&:blank?)
  end

  x.report("comparators") do # faster by 2.27x
    one.blank? && two.blank? && three.blank? && four.blank?
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
