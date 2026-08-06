require 'ostruct'
require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

arrays = 100.times.collect {|i| (rand(10) + 1).times.collect { rand(100) } }
non_arrays = 100.times.collect do |i|
  case rand(3)
  when 0
    i + 1
  when 1
    "#{i + 1}"
  when 2
    i % 2 == 0
  end
end.shuffle
mixed = (arrays[0...50] + non_arrays[0...50]).shuffle

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1 (fresh reading, not a re-verification): still no single winner across all 3 scenarios -- `Array()`/`[]` with check are fastest or near-fastest everywhere; `.flatten` is consistently the worst option except for plain non-array wrapping, where it's merely mediocre
benchmark_lambda = lambda do |x|
  # Worst case - none need operation
  x.report("`Array()` arrays") do
    arrays.map {|i| Array(i) }
  end
  x.report("`[].flatten` arrays") do # always the worst option for arrays (~13x slower than fastest)
    arrays.map {|i| [i].flatten }
  end
  x.report("`Array()` arrays with check") do
    arrays.map {|i| i.is_a?(Array) ? i : Array(i) }
  end
  x.report("`[]` arrays with check") do
    arrays.map {|i| i.is_a?(Array) ? i : [i] }
  end

  # Worst case - all need operation
  x.report("`Array()` non arrays") do
    non_arrays.map {|i| Array(i) }
  end
  x.report("`[].flatten` non arrays") do # mid-pack here -- beats bare `Array()` but still loses to `[]` with check
    non_arrays.map {|i| [i].flatten }
  end
  x.report("`Array()` non arrays with check") do
    non_arrays.map {|i| i.is_a?(Array) ? i : Array(i) }
  end
  x.report("`[]` non arrays with check") do
    non_arrays.map {|i| i.is_a?(Array) ? i : [i] }
  end

  # Mixed case
  x.report("`Array()` mixed") do
    mixed.map {|i| Array(i) }
  end
  x.report("`[].flatten` mixed") do # worst mixed option too
    mixed.map {|i| [i].flatten }
  end
  x.report("`Array()` mixed with check") do
    mixed.map {|i| i.is_a?(Array) ? i : Array(i) }
  end
  x.report("`[]` mixed with check") do
    mixed.map {|i| i.is_a?(Array) ? i : [i] }
  end

  x.compare!
end

Benchmark.ips &benchmark_lambda
