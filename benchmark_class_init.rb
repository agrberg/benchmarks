require 'ostruct'
require 'benchmark'
require 'benchmark/ips'

COUNT = 10_000_000
NAME = "Test Name"
EMAIL = "test@example.org"

class Person
  attr_accessor :name, :email
end

class PersonNamedInit
  attr_accessor :name, :email

  def initialize(name:, email:)
    @name = name
    @email = email
  end
end

class PersonOrderedInit
  attr_accessor :name, :email

  def initialize(name, email)
    @name = name
    @email = email
  end
end

PersonStruct = Struct.new(:name, :email)

person = Person.new
person.name = NAME
person.email = EMAIL

person_named_init = PersonNamedInit.new(name: NAME, email: EMAIL)

person_ordered_init = PersonOrderedInit.new(NAME, EMAIL)

hash = {name: NAME, email: EMAIL}

ostruct = OpenStruct.new
ostruct.name = NAME
ostruct.email = EMAIL

struct = PersonStruct.new
struct.name = NAME
struct.email = EMAIL

struct_ordered = PersonStruct.new(NAME, EMAIL)

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1 (fresh reading, not a re-verification): no single overall winner -- Hash is fastest to init, Struct is fastest to access; OpenStruct is dramatically slowest at both
benchmark_lambda = lambda do |x|
  x.report("hash:init:") do # fastest init overall
      p = {name: NAME, email: EMAIL}
  end

  x.report("openstruct:init:") do # dramatically slowest init (~78x slower than hash)
      p = OpenStruct.new
      p.name = NAME
      p.email = EMAIL
  end

  x.report("struct:init:") do
      p = PersonStruct.new
      p.name = NAME
      p.email = EMAIL
  end

  x.report("struct_ordered:init:") do
      p = PersonStruct.new(NAME, EMAIL)
  end

  x.report("class:init:") do
      p = Person.new
      p.name = NAME
      p.email = EMAIL
  end

  x.report("class:named:init:") do
      p = PersonNamedInit.new(name: NAME, email: EMAIL)
  end

  x.report("class:ordered:init:") do
      p = PersonOrderedInit.new(NAME, EMAIL)
  end

  x.report("hash:access:") do
      hash[:name]
      hash[:email]
  end

  x.report("openstruct:access:") do # slowest access too, though only ~1.5x behind the rest (less dramatic than init)
      ostruct.name
      ostruct.email
  end

  x.report("struct:access:") do # fastest access, narrowly ahead of class/hash (which are roughly tied)
      struct.name
      struct.email
  end

  x.report("struct_ordered:access:") do # tied with struct:access for fastest
      struct_ordered.name
      struct_ordered.email
  end

  x.report("class:access:") do
      person.name
      person.email
  end

  x.report("class:named:access:") do
      person_named_init.name
      person_named_init.email
  end

  x.report("class:ordered:access:") do
      person_ordered_init.name
      person_ordered_init.email
  end
end

Benchmark.ips &benchmark_lambda
