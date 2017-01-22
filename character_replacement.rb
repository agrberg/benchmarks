require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    string = 'a' * i
    single = string + ':'
    many = string + ':' * 10

    x.report("gsub string single #{i} chars") do
      single.gsub(':', '')
    end

    x.report("gsub reg single #{i} chars") do
      single.gsub(/:/, '')
    end

    x.report("tr single #{i} chars") do
      single.tr(':', '')
    end

    x.report("gsub string many #{i} chars") do
      many.gsub(':', '')
    end

    x.report("gsub reg many #{i} chars") do
      many.gsub(/:/, '')
    end

    x.report("tr many #{i} chars") do
      many.tr(':', '')
    end

  end
end

Benchmark.ips(&benchmark_lambda); nil
