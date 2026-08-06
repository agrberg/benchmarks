#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: "group_by is no longer fastest at any size" holds robustly at benchmark-ips defaults (2s/5s) too -- real finding, confirmed both timing regimes. CORRECTION: "each_with_object overtakes manual (each w/creation) from 16+" does NOT hold at defaults -- each w/creation is still ahead at 16 and 100; the actual ranking among the four non-group_by approaches shifts messily with size (plain "each" without creation even takes over as fastest by 1000+, which neither prior reading mentioned). Don't trust a simple two-way crossover story for anything but group_by's loss.
TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    items = Array.new(i) { |i| [i, i % 4] }

    x.report("each - #{i}") do # default proc penalty is gone >= 100 items
      res = Hash.new { |hash, key| hash[key] = [] }

      items.each do |(item, group_value)|
        res[group_value] << item
      end

      res
    end

    x.report("each w/ creation- #{i}") do # mannual creation is faster up until 16
      res = {}

      items.each do |(item, group_value)|
        res[group_value] ||= []
        res[group_value] << item
      end

      res
    end

    x.report("each_with_object - #{i}") do # at benchmark-ips defaults: does NOT overtake each w/creation at 16 or 100 -- ranking among the non-group_by approaches shifts messily with size, plain "each" (no creation) ends up fastest by 1000+
      items.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |(item, group_value), memo|
        memo[group_value] << item
      end
    end

    x.report("each_with_object w/creation - #{i}") do # slower than manual
      items.each_with_object({}) do |(item, group_value), memo|
        memo[group_value] ||= []
        memo[group_value] << item
      end
    end

    x.report("group_by - #{i}") do # no longer fastest at any size — confirmed at both 1s/1s and benchmark-ips defaults (2s/5s); still convenient if you need the grouping for more processing later
      items.group_by(&:last)
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
