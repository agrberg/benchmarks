#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

capture_regexp = /(cap)?ture me/ # https://regexper.com/#%2F%28cap%29%3Fture%20me%2F
non_capture_regexp = /(?:cap)?ture me/ # https://regexper.com/#%2F%28%3F%3Acap%29%3Fture%20me%2F
hit_string = 'for success capture me'.freeze
miss_string = 'you cannot catch me'.freeze

benchmark_lambda = lambda do |x|
  x.report("=~ capture hit") do
    capture_regexp =~ hit_string
  end

  x.report("=~ non-capture hit") do # as expected non-captures are faster than captures all of the time but only slightly
    non_capture_regexp =~ hit_string
  end

  x.report("=~ capture miss") do
    capture_regexp =~ miss_string
  end

  x.report("=~ non-capture miss") do # while faster than the capture miss, missing in general is _much_ slower than hits
    non_capture_regexp =~ miss_string
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
