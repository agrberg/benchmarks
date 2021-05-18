require 'ostruct'
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'active_support/core_ext/numeric/time'

benchmark_lambda = lambda do |x|
  x.report("24.hours.ago") do # SLOWER 2.2x O_o
    24.hours.ago
  end

  x.report("now - calculation") do
    Time.now.utc - 24 * 60 * 60
  end

  x.compare!
end

Benchmark.ips &benchmark_lambda
