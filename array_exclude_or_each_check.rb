#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: densified TIMES to localize the "breaks at 256" claim -- CORRECTION: that didn't hold. next-if still clearly wins at 128 and 256 too; the only crack is at 512, where Array#-[best] edges past next-if[worst] specifically (next-if[best]/[middle] still lead overall). "worst is always fastest" still doesn't hold -- flips across sizes with no stable pattern.
TIMES = [4, 16, 64, 128, 256, 512]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    items = Array.new(i) { |i| i + 1 }
    item_to_exclude_best_case = 1
    item_to_exclude_middle_case = i / 2
    item_to_exclude_worst_case = i

    x.report("Array#- [best] - #{i}") do
      (items - [item_to_exclude_best_case]).each { |item| item.to_s }
    end

    x.report("Array#- [middle] - #{i}") do
      (items - [item_to_exclude_middle_case]).each { |item| item.to_s }
    end

    x.report("Array#- [worst] - #{i}") do
      (items - [item_to_exclude_worst_case]).each { |item| item.to_s }
    end

    # RESULT - v Fastest: doing the check is faster through 256; only at 512 does one Array#- variant (best-case) edge past one next-if variant (worst-case)

    x.report("next if [best] - #{i}") do
      items.each do |item|
        next if item == item_to_exclude_best_case
        item.to_s
      end
    end

    x.report("next if [middle] - #{i}") do
      items.each do |item|
        next if item == item_to_exclude_middle_case
        item.to_s
      end
    end

    # no longer a reliable pattern -- fastest position flips across sizes (best@4, worst@16, best@64, middle@128, ~3-way tie@256), looks like noise
    x.report("next if [worst] - #{i}") do
      items.each do |item|
        next if item == item_to_exclude_worst_case
        item.to_s
      end
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
