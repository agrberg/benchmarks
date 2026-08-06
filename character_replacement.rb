require 'benchmark'
# Make sure you `gem install benchmark-ips`
require 'benchmark/ips'

# Re-run 2026-08-06 — Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1 (fresh reading, not a re-verification): tr wins for small strings (<=100 chars); gsub with a string pattern overtakes it by 1000 chars and tr is the slowest of the three by 10000
TIMES = [1, 16, 100, 1_000, 10_000]

benchmark_lambda = lambda do |x|
  TIMES.each do |i|
    string = 'a' * i
    single = string + ':'
    many = string + ':' * 10

    x.report("gsub string single #{i} chars") do # faster than tr once size hits ~1000+
      single.gsub(':', '')
    end

    x.report("gsub reg single #{i} chars") do # slowest gsub option throughout
      single.gsub(/:/, '')
    end

    x.report("tr single #{i} chars") do # fastest up to ~100 chars, falls behind gsub string at 1000+, slowest by 10000
      single.tr(':', '')
    end

    x.report("gsub string many #{i} chars") do # same crossover as single: wins at 1000+ chars
      many.gsub(':', '')
    end

    x.report("gsub reg many #{i} chars") do # slowest gsub option throughout
      many.gsub(/:/, '')
    end

    x.report("tr many #{i} chars") do # fastest for small strings, slowest by 10000 chars
      many.tr(':', '')
    end

  end
end

Benchmark.ips(&benchmark_lambda); nil
