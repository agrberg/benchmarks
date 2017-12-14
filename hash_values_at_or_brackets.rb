#!/usr/bin/env ruby
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

hash_2 = {one: 1, two: 2}
hash_6 = {one: 1, two: 2, three: 3, four: 4, five: 5, six: 6}
hash_10 = {one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8, nine: 9, ten: 10}

benchmark_lambda = lambda do |x|
  x.report('values_at - 2') { hash_2.values_at(:one, :two) }
  x.report('[] - 2') { [hash_2[:one], hash_2[:two]] } # Faster

  x.report('values_at - 6') { hash_6.values_at(:one, :two, :three, :four, :five, :six) }
  x.report('[] - 6') { [hash_6[:one], hash_6[:two], hash_6[:three], hash_6[:four], hash_6[:five], hash_6[:six]] } # Faster

  x.report('values_at - 10') { hash_10.values_at(:one, :two, :three, :four, :five, :six) } # Faster for larger values
  x.report('[] - 10') { [hash_10[:one], hash_10[:two], hash_10[:three], hash_10[:four], hash_10[:five], hash_10[:six], hash_10[:seven], hash_10[:eight], hash_10[:nine], hash_10[:ten]] }

  x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
