require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'base64'

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
    x.report("unpack #{i}") do
      strings[i].each {|str| str.unpack('m*'.freeze).first }
    end

    x.report("decode64 #{i}") do
      strings[i].each {|str| Base64.decode64(str) }
    end
  end

  # uncomment if you want comparisons between them all
  x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
