require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'
require 'json'

TIMES = [3, 5, 10, 100]

recursive_proc = -> (hash, regex) do
  hash.keys.any? { |key| key =~ regex } ||
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

    x.report("recursive hash first #{i}") do
      recursive_proc.call(hash_first, my_key_hash_reg)
    end
    x.report("recursive hash end #{i}") do
      recursive_proc.call(hash_nested, my_key_hash_reg)
    end
    x.report("recursive hash nested first #{i}") do
      recursive_proc.call(hash_end, my_key_hash_reg)
    end
    x.report("recursive hash nested end #{i}") do
      recursive_proc.call(hash_nested_end, my_key_hash_reg)
    end

    x.report("to_json first #{i}") do
      json_proc.call(hash_first, my_key_json_reg)
    end
    x.report("to_json end #{i}") do
      json_proc.call(hash_nested, my_key_json_reg)
    end
    x.report("to_json nested first #{i}") do
      json_proc.call(hash_end, my_key_json_reg)
    end
    x.report("to_json nested end #{i}") do
      json_proc.call(hash_nested_end, my_key_json_reg)
    end
  end

  x.compare!
end

Benchmark.ips(&benchmark_lambda)
