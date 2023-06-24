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

  x.report("all present - hash") do
    {str1: str1, str2: str2, str3: str3}.compact.map { |k, v| "#{k.to_s.humanize}: #{v}" }.join("")
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

  x.report("all present - reduce") do
    {str1: str1, str2: str2, str3: str3}.reduce("") do |output, (k, v)|
      next output unless v.present?

      output << "#{k.to_s.humanize}: #{v}\n"
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
