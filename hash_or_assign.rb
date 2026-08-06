#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: reversed — "||=" overtakes "=" from 16+ and "=" becomes the slowest from 1000+; "default" wins from 100+. CONFIRMED at benchmark-ips defaults (2s/5s), with one correction: at 1 item "=" is genuinely ahead of "||=" (~1.12x, not a tie).
TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    items = Array.new(i) { |num| num % 3 }

    x.report("= - #{i}") do # fastest only at 1 item (tied w/ ||=); becomes the slowest from 16+
      hash = {}
      items.each do |item|
        hash[item] = true
      end
    end

    x.report("||= - #{i}") do # at least as fast as "=" at every size now (not just starting at 100); default overtakes both from 100+
      hash = {}
      items.each do |item|
        hash[item] ||= true
      end
    end

    x.report("default - #{i}") do # not a great solution but interesting - faster starting at 100
      hash = Hash.new { |hash, key| hash[key] = true }
      items.each do |item|
        hash[item]
      end
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
