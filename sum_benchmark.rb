require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [0, 1, 2, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |num|
    array = (1..num).to_a

    x.report("manual #{num}") do # fastest of the rest
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

    x.report("sum - #{num}") do # so much freakin' faster
      array.sum
    end
  end

  x.compare!
end

Benchmark.ips &benchmark_lambda
