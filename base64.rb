require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'base64'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: densified TIMES for confirmation -- decode64/unpack are same-ish at 1 (this run-to-run flips between "tied" and "decode64 slightly ahead" at size 1, so treat it as a tie -- matches the *original* pre-reversal finding). decode64 clearly wins 4 through 1000; unpack flips back ahead at 10000.
TIMES = [1, 4, 8, 16, 100, 1_000, 10_000]
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
    # at benchmark-ips defaults: tied with decode64 at 1, decode64 wins 4-1000, unpack flips back ahead at 10000
    x.report("unpack #{i}") do
      strings[i].each {|str| str.unpack('m*'.freeze).first }
    end

    x.report("decode64 #{i}") do # tied with unpack at 1; faster at 4/8/16/100/1000; loses to unpack at 10000
      strings[i].each {|str| Base64.decode64(str) }
    end
  end

  # uncomment if you want comparisons between them all
  x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
