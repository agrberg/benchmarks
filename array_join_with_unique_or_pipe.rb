#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [4, 16, 100, 1_000, 10_000]
OVERLAP_FRACTIONS = [6, 5, 4]

benchmark_lambda = lambda do |x|
  TIMES.each do |items|
    half_point = items / 2

    OVERLAP_FRACTIONS.each do |overlap_denominator|
      overlap_offset = items / overlap_denominator
      # puts "#{items} : #{half_point} :: #{overlap_denominator} : #{overlap_offset}"
      first_part = (1..(half_point + overlap_offset)).to_a
      last_part = ((half_point - overlap_offset + 1)..items).to_a

      # Pipe is always faster
      x.report("#{items} items overlap #{overlap_denominator} :: one | two") do
        first_part | last_part
      end

      x.report("#{items} items overlap #{overlap_denominator} :: (one + two).uniq") do
        (first_part + last_part).uniq
      end
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
