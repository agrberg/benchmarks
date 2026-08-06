#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: "check is always faster" now breaks at 256 (next-if-middle drops below Array#-); "worst is always fastest" no longer holds -- flips across sizes
TIMES = [4, 16, 64, 256]

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

    # RESULT - v Fastest: doing the check is faster for every size except 256, where next-if-middle falls behind Array#- (gap collapses into noise)

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

    # no longer a reliable pattern -- fastest position flips across sizes (best@4, worst@16, middle@64, best@256), looks like noise
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
