require 'ostruct'
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

benchmark_lambda = lambda do |x|
  x.report("24.hours.ago") do
    24.hours.ago
  end

  x.report("now - calculation") do
    Time.now.utc - 24 * 60 * 60
  end
end

Benchmark.ips &benchmark_lambda
