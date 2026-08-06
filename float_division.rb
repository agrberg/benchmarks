#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: big reversal CONFIRMED at benchmark-ips defaults (2s/5s) — plain `fdiv` really did jump to top 3 overall / fastest fdiv, and `to_f/f` really is fastest of the to_f's. One overstatement corrected: `fdiv to_f` is no longer the *fastest* fdiv, but it's not literally the *slowest* fdiv either -- `fdiv f.to_f`, `to_f fdiv`, and `to_f fdiv to_f` are all slower than it.
benchmark_lambda = lambda do |x|
  x.report('i/i') do # tied fastest w/ same, but doesn't give the intended value
    4 / 3
  end

  x.report('f/f') do # tied fastest w/ same as i/i (same-ish) — no longer a clear standalone winner over i/i
    4.0/3.0
  end

  x.report('f/i') do # `Float#/i` is fast but mixed is always slower than the same on both sides
    4.0/3
  end

  x.report('i/f') do # Int#/f is slower than Int#fdiv f
    4/3.0
  end

  x.report('to_f/') do # Float#/ has quick implicit conversion, but `to_f/f` is now faster; no longer top 3
    4.to_f / 3
  end

  x.report('to_f/f') do # now the fastest of the `to_f`s (just outside the overall top 3)
    4.to_f / 3.0
  end

  # now 3rd fastest of the `to_f`s (behind `to_f/f` and `to_f/`), not top 3 anymore
  # surprisingly, it seems that `/` is more expensive to call on an int
  # than it is to do 2 additional float conversions
  x.report('to_f/to_f') do
    4.to_f / 3.to_f
  end


  x.report('/to_f') do # Int#/ is simply slower; still slowest of the `/to_f`s
    4 / 3.to_f
  end

  x.report('fdiv to_f') do # no longer fastest of the `fdiv`s or top 3 — plain `fdiv` and `fdiv f` both beat it now; still beats `fdiv f.to_f`/`to_f fdiv`/`to_f fdiv to_f` though, so not the outright slowest fdiv
    4.fdiv(3.to_f)
  end

  x.report('fdiv f') do # naturally faster `fdiv` is fast on Int and f doesn't need conversion; now 2nd-fastest fdiv, behind plain `fdiv`
    4.fdiv(3.0)
  end

  x.report('fdiv f.to_f') do # about same as `fdiv to_f` no-op doesn't really save anything; both now near the bottom of the fdiv family
    4.fdiv(3.0.to_f)
  end

  x.report('fdiv') do # reversed: now fastest of the `fdiv`s and in the overall top 3 — no longer bottom 3
    4.fdiv(3)
  end

  x.report('to_f fdiv') do # `fdiv` is slower on floats but implicit is better than explicit conversion
    4.to_f.fdiv(3)
  end

  x.report('to_f fdiv to_f') do # clearly `fdiv` is slower on floats + cost of conversion
    4.to_f.fdiv(3.to_f)
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
