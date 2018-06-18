#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    assignments = {code: [], hash: []}
    i.times.each do |num|
      assignments[:code] << "return_hash['#{num}'] = #{num}"
      assignments[:hash] << "'#{num}' => #{num},"
    end
    assignment_code = assignments[:code].join("\n")
    assignment_hash_code = ['{', assignments[:hash], '}'].join("\n")
    assignment_proc = lambda { |return_hash| eval(assignment_code) }

    x.report(".tap - #{i}") do
      {one: 1, two: 2}.tap &assignment_proc
    end

    x.report(".merge - #{i}") do # fastest
      {one: 1, two: 2}.merge eval(assignment_hash_code)
    end

    x.report("[]= - #{i}") do
      return_hash = {one: 1, two: 2}
      assignment_proc.call return_hash
      return_hash
    end
  end

  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
