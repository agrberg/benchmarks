require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [10, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    min = 0
    max = i
    range = min..max
    value_in = (max + min) / 2
    value_under = min - 1
    value_above = max + 1

    x.report("range match #{max}") do
      range.include?(value_in)
    end

    x.report("range too low #{max}") do
      range.include?(value_under)
    end

    x.report("range too high #{max}") do
      range.include?(value_above)
    end

    x.report("> && < match #{max}") do
      value_in >= min && value_in <= max
    end

    x.report("> && < too low #{max}") do
      value_under >= min && value_under <= max
    end

    x.report("> && < too high #{max}") do
      value_above >= min && value_above <= max
    end
  end

  # uncomment if you want comparisons between them all
  x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
