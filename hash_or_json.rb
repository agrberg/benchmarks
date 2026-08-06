require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'json'

TIMES = [3, 5, 10, 100]

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1: previously crashed on Ruby 3.2+ (Kernel#=~ removed), now fixed and running. Fresh finding below (no prior conclusion existed).
recursive_proc = -> (hash, regex) do
  # `key =~ regex` used to rely on Kernel#=~'s no-match default for non-String/Symbol
  # keys; Ruby 3.2 removed that method entirely, so non-strings now raise NoMethodError.
  hash.keys.any? { |key| key.to_s =~ regex } ||
    hash.values.any? { |value| value.is_a?(Hash) && recursive_proc.call(value, regex) }
end

json_proc = -> (hash, regex) do
  hash.to_json.index(regex)
end

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    my_key = :thekey
    my_key_hash_reg = /thekey/
    my_key_json_reg = /"thekey":/

    hash_first = Hash[my_key, :some_value]
    hash_nested = {nested: Hash[my_key, :some_value]}
    hash_end = {}
    hash_nested_end = {}

    i.times do |i|
      i_plus_one = i + 1
      i_plus_one_times_2 = i_plus_one * 2
      hash_first[i_plus_one] = i_plus_one_times_2
      hash_nested[i_plus_one] = i_plus_one_times_2
      hash_end[i_plus_one] = i_plus_one_times_2
      hash_nested_end[i_plus_one] = i_plus_one_times_2
    end

    hash_end[my_key] = :some_value
    hash_nested_end[:nested] = Hash[my_key, :some_value]

    x.report("recursive hash first #{i}") do # fastest of all variants at every size — target key found immediately, no recursion needed
      recursive_proc.call(hash_first, my_key_hash_reg)
    end
    x.report("recursive hash end #{i}") do # the one case where to_json wins (at size 100) — the nested match sits early in the serialized string, letting to_json short-circuit
      recursive_proc.call(hash_nested, my_key_hash_reg)
    end
    x.report("recursive hash nested first #{i}") do # beats its to_json counterpart at every size
      recursive_proc.call(hash_end, my_key_hash_reg)
    end
    x.report("recursive hash nested end #{i}") do # beats its to_json counterpart at every size, despite needing the deepest scan
      recursive_proc.call(hash_nested_end, my_key_hash_reg)
    end

    x.report("to_json first #{i}") do # slower than the recursive scan at every size
      json_proc.call(hash_first, my_key_json_reg)
    end
    x.report("to_json end #{i}") do # only variant where to_json beats recursive, and only at size 100 — see note above
      json_proc.call(hash_nested, my_key_json_reg)
    end
    x.report("to_json nested first #{i}") do # slower than the recursive scan at every size
      json_proc.call(hash_end, my_key_json_reg)
    end
    x.report("to_json nested end #{i}") do # slowest overall — match sits at the end of both the hash and the serialized string
      json_proc.call(hash_nested_end, my_key_json_reg)
    end
  end

  x.compare!
end

Benchmark.ips(&benchmark_lambda)
