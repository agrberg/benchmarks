require 'ostruct'
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  x.report("creating the array `*{range}`") do
    [*'0'..'9', *'A'..'Z', *'a'..'z']
  end

  x.report("creating the array `to_a`") do
    ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a
  end

  x.report("creating the array `Array(…)`") do
    Array('0'..'9') + Array('A'..'Z') + Array('a'..'z')
  end

  x.report("creating the array `['a', 'b', ... 'z']`") do
    ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] +
      ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"] +
      ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
  end

  TIMES.each do |num_times|
    existing_array = (0..num_times).to_a

    x.report("`+` 1 element to an array of #{num_times}") do
      [1] + existing_array
    end

    x.report("`[i, *ary]` 1 element to an array of #{num_times}") do
      [1, *existing_array]
    end
  end
end

Benchmark.ips &benchmark_lambda
