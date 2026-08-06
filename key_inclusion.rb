require 'ostruct'
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# chars = [*('a'..'z'), *('A'..'Z'), *('0'..'9')]

TIMES = [1, 16, 100, 1_000, 10_000]

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: fresh reading (no prior conclusion existed). has_key? wins at 1, 100, 1000, and 10000; array - array only wins at 16, which looks like noise given the overlapping error bars there.
benchmark_lambda = lambda do |x|
  TIMES.each do |num|
    hash = {}
    num.times.each {|i| hash[i] = i.to_s }
    test_keys = (0..num).to_a.sample((num / 2.0).ceil)

    x.report("array - array #{num}") do # faster only at 16 (likely noise); has_key? wins at 1, 100, 1000, 10000
      (test_keys - hash.keys).any?
    end

    x.report("has_key? #{num}") do # faster at 1, 100, 1000, 10000; loses only at 16 (likely noise)
      test_keys.all? {|k| hash.has_key?(k) }
    end
  end
end

Benchmark.ips &benchmark_lambda
