require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: switched back to the sparse range (was TIMES = 2..16, contiguous) -- that granularity bought nothing for a smooth monotonic trend and needed a 240s timeout; this is ~75% cheaper and actually reaches realistic collection sizes. Confirmed the sparse range gives the same, cleaner answer: sum(&:value) wins at every size (tied with manual only at 2); ranking from 16 on is stable: sum(&:value) > collect.sum > manual > inject > manual 2x.
TIMES = [2, 16, 100, 1_000, 10_000]

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

    x.report("manual - #{num}") do # 3rd from 16 on (tied with sum(&:value) at size 2)
      sum = 0
      array.each { |object| sum += object.value }
      sum
    end

    x.report("inject - #{num}") do # 4th from 16 on
      array.inject(0) {|sum, object| sum + object.value }
    end

    x.report("collect.sum - #{num}") do # 2nd from 16 on
      array.collect(&:value).sum
    end

    x.report("sum(&:value) - #{num}") do # fastest at every size (tied with manual only at 2)
      array.sum(&:value)
    end

    x.report("manual 2x - #{num}") do # slowest from 16 on -- consistently behind collect.sum across the whole range, reversed from before
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
