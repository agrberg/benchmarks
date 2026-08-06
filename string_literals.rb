require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: manual array freeze still fastest, map freeze still slowest; manual array and %w[] remain close
benchmark_lambda = lambda do |x|
  x.report("%w[]") do # same as [...] mostly
    %w[one two three]
  end

  x.report("manual array") do # same as %w[] mostly
    ['one', 'two', 'three']
  end

  x.report("manual array freeze") do # fastest over many iterations
    ['one'.freeze, 'two'.freeze, 'three'.freeze]
  end

  x.report("manual array map freeze") do # useless
    ['one', 'two', 'three'].map(&:freeze)
  end

  x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
