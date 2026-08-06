#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: my first pass (1s/1s reduced timing) called all six same-ish -- CORRECTION from benchmark-ips defaults (2s/5s): that was a timing artifact. `PersonClass new w/ args` is decisively the fastest of all six (beats every other variant by 1.38-1.59x, none tagged same-ish) -- a third, different finding from both the original historical claim and the same-ish revision. Plain Class with an args constructor wins outright; the Struct-vs-Class / new-vs-assign split from the original comment doesn't hold either.

FIRST_NAME = 'Firstname'.freeze
LAST_NAME = 'Lastname'.freeze

class PersonClass
  attr_accessor :first_name, :last_name

  def initialize(first_name = nil, last_name = nil)
    @first_name = first_name
    @last_name = last_name
  end
end

class PersonInheritedStruct < Struct.new(:first_name, :last_name)
end

PersonAssignedStruct = Struct.new(:first_name, :last_name)

benchmark_lambda = lambda do |x|
  x.report('PersonClass new w/ args') do
    PersonClass.new(FIRST_NAME, LAST_NAME)
  end

  x.report('PersonInheritedStruct new w/ args') do
    PersonInheritedStruct.new(FIRST_NAME, LAST_NAME)
  end

  x.report('PersonAssignedStruct new w/ args') do
    PersonAssignedStruct.new(FIRST_NAME, LAST_NAME)
  end

  x.report('PersonClass assign') do
    p = PersonClass.new
    p.first_name = FIRST_NAME
    p.last_name = LAST_NAME
  end

  x.report('PersonInheritedStruct assign') do
    p = PersonInheritedStruct.new
    p.first_name = FIRST_NAME
    p.last_name = LAST_NAME
  end

  x.report('PersonAssignedStruct assign') do
    p = PersonAssignedStruct.new
    p.first_name = FIRST_NAME
    p.last_name = LAST_NAME
  end


  x.compare! # uncomment if you want comparisons between them all
end

Benchmark.ips(&benchmark_lambda); nil
