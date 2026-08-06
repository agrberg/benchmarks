#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: strip/squeeze still both far ahead of all gsub variants at every size; size=16 run was unusually noisy (±Inf% error bars) so its same-ish tags there are unreliable
REGEXP_MAP = {
  'gsub \\s+'    => /\s+/,    # https://regexper.com/#%2F%5Cs%2B%2F <= more permissive but sometimes faster
  'gsub {2,}'    => /\s{2,}/, # https://regexper.com/#%2F%5Cs%7B2%2C%7D%2F
  'gsub \\s\\s+' => /\s\s+/   # https://regexper.com/#%2F%5Cs%5Cs%2B%2F
}

STRINGS = 6.times.collect do |i|
  num_spaces = 2 ** i
  string = "#{' ' * num_spaces}#{num_spaces}#{' ' * num_spaces}"

  # gsub is much slower ~ 11x
  # strip is better until the number of spaces gets high

  benchmark_lambda = lambda do |x|
    x.report("#{num_spaces} strip") do
      string.strip
    end

    x.report("#{num_spaces} squeeze") do
      string.squeeze(' '.freeze)
    end

    REGEXP_MAP.each do |name, regexp|
      x.report("#{num_spaces} #{name}") do
        string.gsub(regexp, ' '.freeze)
      end
    end

    x.compare! # uncomment if you want comparisons between them all
  end

  Benchmark.ips(&benchmark_lambda)
end
