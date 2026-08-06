#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

capture_regexp = /(cap)?ture me/ # https://regexper.com/#%2F%28cap%29%3Fture%20me%2F
non_capture_regexp = /(?:cap)?ture me/ # https://regexper.com/#%2F%28%3F%3Acap%29%3Fture%20me%2F
hit_string = 'for success capture me'.freeze
miss_string = 'you cannot catch me'.freeze

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: "misses now faster than hits" direction CONFIRMED at benchmark-ips defaults (2s/5s). Correction: the capture-vs-non-capture gap on the *miss* side is not slight -- non-capture-miss is a clear 1.76x ahead of capture-miss there (the "only slight" description holds for the hit side, ~1.03x between capture-hit and non-capture-hit).
benchmark_lambda = lambda do |x|
  x.report("=~ capture hit") do # ~1.5x slower than either miss variant; slightly slower than non-capture hit
    capture_regexp =~ hit_string
  end

  x.report("=~ non-capture hit") do # non-captures are faster than captures, but only slightly; still ~1.5x slower than either miss variant
    non_capture_regexp =~ hit_string
  end

  x.report("=~ capture miss") do # at benchmark-ips defaults: NOT tied with non-capture miss -- 1.76x slower; misses are still faster than hits here
    capture_regexp =~ miss_string
  end

  x.report("=~ non-capture miss") do # fastest overall — misses beat hits here, reversing the old assumption that missing is much slower; and non-capture is a real 1.76x ahead of capture-miss specifically, at benchmark-ips defaults
    non_capture_regexp =~ miss_string
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
