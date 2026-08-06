require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: ranking holds -- block check still wins (~1.23x faster than pre-remove)
TIMES = [1, 5, 10, 50, 100]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    array = (0..i).to_a

    x.report('pre-remove') do
      (array - [0]).find { |el| el == i }
    end

    x.report('block check') do # winner
      array.find { |el| el != 0 && el == i }
    end
  end

  # uncomment if you want comparisons between them all
  x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
