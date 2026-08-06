require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'base64'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: reversal partially CONFIRMED at benchmark-ips defaults (2s/5s), with a refinement: decode64 wins at 1/16/100/1000 (not tied at 1 -- decode64 clearly ahead, 1.70x), but unpack flips back ahead at 10000. So decode64 wins for small-to-large strings, unpack wins only at the very largest tested size.
TIMES = [1, 16, 100, 1_000, 10_000]
chars = [*('a'..'z'), *('A'..'Z'), *('0'..'9')]
strings = {}
TIMES.each do |i|
  strings[i] = i.times.collect do
    random_string = Array.new(20) { chars.sample }.join
    Base64.encode64("#{random_string}:#{random_string}")
  end
end

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    # at benchmark-ips defaults: decode64 wins at 1/16/100/1000, but unpack flips back ahead at 10000
    x.report("unpack #{i}") do
      strings[i].each {|str| str.unpack('m*'.freeze).first }
    end

    x.report("decode64 #{i}") do # faster than unpack at 1/16/100/1000; loses to unpack at 10000
      strings[i].each {|str| Base64.decode64(str) }
    end
  end

  # uncomment if you want comparisons between them all
  x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
