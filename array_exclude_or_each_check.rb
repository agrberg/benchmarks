#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

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

    # RESULT - v Fastest: doing the check is _always_ faster for any sized array

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

    # surprisingly this is _always_ slightly faster than if the element is first or in the middle
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
