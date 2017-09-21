# https://bugs.ruby-lang.org/issues/11076
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]

is_even_proc = -> (v) { v % 2 == 0 }
hash_proc = -> (hash, &block) { Hash[hash.group_by(&block).map { |key,vals| [key, vals.size] }] }
inline_proc = -> (hash, &block) do
  hash.group_by(&block).tap do |groups|
    groups.each {|k,v| groups[k] = v.count }
  end
end
inline_no_tap_proc = -> (hash, &block) do
  groups = hash.group_by(&block)
  groups.each {|k,v| groups[k] = v.count }
  groups
end
single_eval_proc = -> (hash, &block) do
  hash.each_with_object(Hash.new(0)) do |elm, h|
    h[block.call(elm)] += 1
  end
end

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    array = i.times.collect.to_a

    x.report("Hash[]\t#{i}") do # 2nd place
      hash_proc.call(array, &is_even_proc)
    end

    x.report("inline\t#{i}") do # slightly faster than hash @ < 100
      inline_proc.call(array, &is_even_proc)
    end

    x.report("inline w/o tap\t#{i}") do # fastest
      inline_no_tap_proc.call(array, &is_even_proc)
    end

    x.report("single eval\t#{i}") do # worst > 10 values
      single_eval_proc.call(array, &is_even_proc)
    end
  end

  # uncomment if you want comparisons between them all
  x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
