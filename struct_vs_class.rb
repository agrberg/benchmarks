#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Odd results on this one. The structs are faster (their difference is in the noise) when initializing w/
# the data already present.
# HOWEVER, the class is faster when it does not have an initialize method and only assignment is used

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
