#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'active_support/inflector'

# "all missing" is overall the fastest for each case
# "all present" is overall the second fastest for each case
# "reduce" is vastly the slowest being SLOWER than "all present - string"
# "all present - string" is the fastest worse case for string concat AND faster than all non-string non-missing cases

benchmark_lambda = lambda do |x|
  str1 = "string 1\n"
  str2 = "string 2\n"
  str3 = "string 3"
  str1_nil = str2_nil = str3_nil = nil

  # x.report("all missing - string") do
  #   output = ""
  #   output << "Str1: #{str1}" if str1_nil
  #   output << "Str2: #{str2}" if str2_nil
  #   output << "Str3: #{str3}" if str3_nil
  # end

  # ~23x faster for worst case (full) present cases
  # hash and reduce are about the same
  x.report("all present - string") do
    output = ""
    output << "Str1: #{str1}" if str1
    output << "Str2: #{str2}" if str2
    output << "Str3: #{str3}" if str3
  end

  # x.report("half present - string") do
  #   output = ""
  #   output << "Str1: #{str1}" if str1
  #   output << "Str2: #{str2}" if str2_nil
  #   output << "Str3: #{str3}" if str3
  # end

  # x.report("all missing - hash") do
  #   {str1: str1_nil, str2: str2_nil, str3: str3_nil}.compact.map { |k, v| "#{k.to_s.humanize}: #{v}" }.join("")
  # end

  # this is the only case where `hash` is faster than `reduce`
  x.report("all present - hash") do
    {str1: str1, str2: str2, str3: str3}.compact.map { |k, v| "#{k.to_s.humanize}: #{v}" }.join("")
  end

  x.report("all present - hash - explicit") do
    {"Str1" => str1, "Str2" => str2, "Str3" => str3}.compact.map { |k, v| "#{k}: #{v}" }.join("")
  end

  x.report("all present - hash - no AS::I") do
    {str1: str1, str2: str2, str3: str3}.compact.map { |k, v| "#{k.to_s.capitalize.tr("_", " ")}: #{v}" }.join("")
  end

  # x.report("half present - hash") do
  #   {str1: str1, str2: str2_nil, str3: str3}.compact.map { |k, v| "#{k.to_s.humanize}: #{v}" }.join("")
  # end

  # x.report("all missing - reduce") do
  #   {str1: str1_nil, str2: str2_nil, str3: str3_nil}.reduce("") do |output, (k, v)|
  #     next output unless v.present?

  #     output << "#{k.to_s.humanize}: #{v}\n"
  #   end
  # end

  # without ActiveSupport::Inflector (which also brings in `#present?`) `reduce` is faster than `hash` for all present cases
  # and only 2.33x slower than string concat
  x.report("all present - reduce") do
    {str1: str1, str2: str2, str3: str3}.reduce("") do |output, (k, v)|
      next output unless v.present?

      output << "#{k.to_s.humanize}: #{v}"
    end
  end

  # explicit string preformated keys cut 2x off the time w/o AS methods for a total of 10x faster
  x.report("all present - reduce - explicit") do
    {"Str1" => str1, "Str2" => str2, "Str3" => str3}.reduce("") do |output, (k, v)|
      next output unless v

      output << "#{k}: #{v}"
    end
  end

  # AS::I methods add about 5x to the time
  x.report("all present - reduce - no AS::I") do
    {str1: str1, str2: str2, str3: str3}.reduce("") do |output, (k, v)|
      next output unless v

      output << "#{k.to_s.capitalize.tr("_", " ")}: #{v}"
    end
  end

  # x.report("half present - reduce") do
  #   {str1: str1, str2: str2_nil, str3: str3}.reduce("") do |output, (k, v)|
  #     next output unless v.present?

  #     output << "#{k.to_s.humanize}: #{v}\n"
  #   end
  # end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
