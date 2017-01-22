require 'ostruct'
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |num|
    array = num.times.collect.to_a # goofy but it basically does {|i| i }

    x.report("manual #{num}") do
      sum = 0
      array.each {|i| sum += i }
      sum
    end

    x.report("reduce naive #{num}") do
      array.reduce(0) {|sum, i| sum + i }
    end

    x.report("reduce &:+ #{num}") do
      array.reduce(&:+)
    end
  end
end

Benchmark.ips &benchmark_lambda
