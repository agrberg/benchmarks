require 'ostruct'
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'active_support'
require 'active_support/core_ext/numeric/time'
# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: previously crashed (missing base 'active_support' require — ActiveSupport::IsolatedExecutionState uninitialized; core_ext never loaded so 'hours'/'current' were undefined), now fixed and running; ranking unchanged but gap widened to 2.53x (was ~2.2x)

benchmark_lambda = lambda do |x|
  x.report("24.hours.ago") do # SLOWER 2.53x (was ~2.2x) O_o
    24.hours.ago
  end

  x.report("now - calculation") do
    Time.now.utc - 24 * 60 * 60
  end

  x.compare!
end

Benchmark.ips &benchmark_lambda
