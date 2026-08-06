#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: reversed — plain `fdiv i` (no conversion) is now tied for fastest overall instead of slowest; `fdiv to_f` dropped from fastest fdiv to slowest fdiv. CONFIRMED at benchmark-ips defaults (2s/5s).
benchmark_lambda = lambda do |x|
  x.report('to_f/to_f') do
    4.to_f / 3.to_f
  end

  x.report('f/to_f') do
    4.0 / 3.to_f
  end

  x.report('to_f/f') do # Float#/ w/o conversion fastest `to_f`; also ties for fastest overall now
    4.to_f / 3.0
  end

  x.report('to_f/i') do #
    4.to_f / 3
  end

  x.report('fdiv f') do # Int#fdiv w/o conversion; ties for fastest overall (same-ish w/ to_f/f, f/to_f, fdiv i)
    4.fdiv(3.0)
  end

  x.report('fdiv to_f') do # Int#fdiv w/ explicit conversion; now the slowest `fdiv` variant (was fastest before)
    4.fdiv(3.to_f)
  end

  x.report('fdiv i') do # reversed: now ties for fastest overall instead of slower than all approaches
    4.fdiv(3)
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
