#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [5, 20, 100]
ALPHA = ('a'..'z').to_a

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    base_string = '.' + Array.new(i) { ALPHA.sample }.join

    x.report("delete('.') - #{i}") { base_string.delete('.') }

    x.report("delete!('.') - #{i}") do
      string = base_string.dup
      string.delete!('.')
    end

    x.report("[1..-1] - #{i}") { base_string[1..-1] }

    x.report("[/[^\.]+/] - #{i}") { base_string[/[^\.]+/] }

    x.report("[1, #size] - #{i}") { base_string[1, base_string.size] } # fastest overall (new string produced) - little difference when replacing via assignment s = s[1, s.size] even w/ implicit dup

    x.report("[/^\./] = '' - #{i}") do
      string = base_string.dup
      string[/^\./] = ''
    end

    x.report("[0] = '' - #{i}") do # fastest of those that manually dup - best for inline replacement
      string = base_string.dup
      string[0] = ''
    end

    x.report("['.'] = '' - #{i}") do
      string = base_string.dup
      string['.'] = ''
    end

    x.report("sub('.', '') - #{i}") { base_string.sub('.', '') }

    x.report("sub!('.', '') - #{i}") do
      string = base_string.dup
      string.sub!('.', '')
    end

    x.report("tr('.', '') - #{i}") { base_string.tr('.', '') }

    x.report("tr!('.', '') - #{i}") do
      string = base_string.dup
      string.tr!('.', '')
    end

    x.report("tr_s('.', '') - #{i}") { base_string.tr_s('.', '') }

    x.report("tr_s!('.', '') - #{i}") do
      string = base_string.dup
      string.tr!('.', '')
    end

    x.report("rpartition('.').last - #{i}") { base_string.rpartition('.').last }
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
