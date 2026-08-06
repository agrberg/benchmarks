# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A personal collection of standalone Ruby micro-benchmarks (~70 scripts, actively added to since 2017) comparing idiomatic Ruby/Rails patterns for speed — e.g. `Set` vs `Array#include?`, hash `merge` vs splat, `Struct` vs `Class` vs `OpenStruct`, `tr` vs `gsub`, ActiveSupport time helpers vs raw math. Not a gem, app, or test suite — each file is a self-contained experiment run manually and read for its printed output.

Two files are not benchmarks and are exceptions to everything below: `thread_testing.rb` (an ActiveRecord locking experiment, no `Benchmark` harness) and `pathfinding.md` (unrelated notes on exploring a large codebase).

## Running a benchmark

```bash
gem install benchmark-ips    # one-time; most scripts require this
ruby <name>.rb
```

There's no Gemfile — dependencies (`benchmark-ips`, and occasionally `active_support`/`ostruct`) are installed ad hoc and `require`d directly at the top of each file. No test suite, linter, or CI: correctness is "does it run and print a comparison."

[`README.md`](README.md) is the findings index — a table of every benchmark, what it compares, and its current conclusion, kept in sync with the inline comments below. Check it for the last-verified Ruby/ActiveSupport/benchmark-ips version and its Caveats section before trusting an old file's numbers.

## Conventions for new/edited benchmarks

`template.rb` is the canonical scaffold — copy it for new benchmarks:

```ruby
#!/usr/bin/env ruby
require 'benchmark'
require 'benchmark/ips'

benchmark_lambda = lambda do |x|
  x.report("FIRST_WAY") { }
  x.report("SECOND_WAY") { }
  x.compare!
end

Benchmark.ips(&benchmark_lambda); nil
```

- Use `Benchmark.ips` (iterations-per-second), not `Benchmark.bm`/`bmbm`. Always call `x.compare!` to get relative-speed output.
- When input size matters, sweep it rather than picking one N — the default is `TIMES = [1, 4, 16, 100, 1_000, 10_000]`, looping `TIMES.each` inside the lambda and suffixing report labels with the size (e.g. `"#{i} - Array#include?"`). This is how crossover points get found (e.g. `set_or_array_lookup.rb` shows Array beats Set below 4 elements, loses above it).
  - **Runtime cost**: `reports_per_size × len(TIMES) × 7s` at benchmark-ips defaults (2s warmup + 5s calc). For a *grid* sweep (`TIMES.each` nested inside `TIMES.each`, e.g. `string_shovel_join_or_interp.rb`), it's squared — `reports × len(TIMES)² × 7s`. Adding a point to a grid file costs far more than adding one to a linear file; don't densify a grid casually.
  - Bias added resolution toward the low end (below 100) if you're hunting a crossover — every real crossover found in this repo's history landed there, low-N reports are the cheapest kind to add, and a slow high-N report burns the same time budget for fewer, noisier samples. If a suspected flip lands between two adjacent points, add points to bisect the gap rather than widening the whole range.
- **Record the conclusion as an inline comment on the `x.report` line it belongs to** (`x.report("tr #{i} chars") do # tr is bonkers faster...`) — this repo's findings live in code comments, not a separate doc, so they never drift out of sync with what was actually run. Follow this when adding new benchmarks.
- Filenames are `subject_a_or_subject_b.rb` / `topic_verb.rb`, self-describing since there's no index file.
- If a "faster" alternative isn't semantically interchangeable with the baseline (e.g. `tr`'s char-set substitution vs `gsub`'s literal/regex replacement), say so in a comment — don't let the speed win imply a safe drop-in swap.

## Re-verifying an existing benchmark

- Stamp the file with what you verified and when: `# Re-run <date> — Ruby <version> (+YJIT if enabled), ActiveSupport <version>, benchmark-ips <version>: <one-line finding>`. Placed once, near the top (after requires, before the benchmark body). This is what lets a future re-run tell "still true" apart from "never checked since 2019."
- **Don't shorten benchmark-ips's `warmup`/`time` below its own defaults (2s/5s) for a finding you intend to record.** A shortened window (used once here to make a 70-file sweep tractable in one sitting) produced false "same-ish" ties and false reversals on ~45% of the surprising results it flagged, in both directions — some snapped back to the original finding, a couple landed on a *third* result different from both readings. If you must shorten it to survey many files quickly, re-run anything surprising at the real defaults before writing the conclusion down, and say in the stamp that you did.
- benchmark-ips's own "same-ish: difference falls within error" tag is trustworthy at any window length — it's the tool's own confidence-interval check. Non-"same-ish" numbers from a shortened window are what need re-verification, not same-ish calls.
