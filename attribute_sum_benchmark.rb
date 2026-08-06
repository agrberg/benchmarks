require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# TIMES = [2, 16, 100, 1_000, 10_000]
# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: sum(&:value)/manual/collect.sum/inject ranking holds; "manual 2x" is now consistently slower than collect.sum across 2-16, reversed from before
TIMES = 2..16

class Simple
  attr_reader :value

  def initialize(value:)
    @value = value
  end
end

benchmark_lambda = lambda do |x|
  TIMES.each do |num|
    array = Array.new(num) { |i| Simple.new(value: i + 1) }

    # Fastest is most common 100 and below

    x.report("manual - #{num}") do # 2nd place (one-off dip to 3rd at 12 items)
      sum = 0
      array.each { |object| sum += object.value }
      sum
    end

    x.report("inject - #{num}") do # last (except at 11 items, where manual 2x is marginally slower)
      array.inject(0) {|sum, object| sum + object.value }
    end

    x.report("collect.sum - #{num}") do # 3rd (one-off jump to 2nd, ahead of manual, at 12 items)
      array.collect(&:value).sum
    end

    x.report("sum(&:value) - #{num}") do # fastest
      array.sum(&:value)
    end

    x.report("manual 2x - #{num}") do # now consistently slower than collect.sum across this whole range (2-16), reversed from before
      sum1 = 0
      sum2 = 0

      array.each do |object|
        sum1 += object.value
        sum2 += object.value
      end

      [sum1, sum2]
    end
  end

  x.compare!
end

Benchmark.ips &benchmark_lambda
