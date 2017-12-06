require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# TIMES = [2, 16, 100, 1_000, 10_000]
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

    x.report("manual - #{num}") do # 2nd place
      sum = 0
      array.each { |object| sum += object.value }
      sum
    end

    x.report("inject - #{num}") do # last
      array.inject(0) {|sum, object| sum + object.value }
    end

    x.report("collect.sum - #{num}") do # 3rd
      array.collect(&:value).sum
    end

    x.report("sum(&:value) - #{num}") do # fastest
      array.sum(&:value)
    end

    x.report("manual 2x - #{num}") do # faster than collect.sum for values around 16 or under
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
