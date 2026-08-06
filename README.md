# benchmarks

Standalone Ruby micro-benchmarks comparing idiomatic approaches to common problems — which `Array` method is faster, `Struct` vs `Class`, ActiveSupport time helpers vs raw math, and so on. Collected since 2017, each file is a runnable experiment; the table below is an index of what's been tried and what won.

**Last verified 2026-08-06** on Ruby 4.0.6 (no YJIT), ActiveSupport 8.1.3.1, benchmark-ips 2.15.1 — every file below was re-run on this exact stack. See [Caveats](#caveats) before treating any specific number as gospel.

## Running one

```bash
gem install benchmark-ips    # one-time; most scripts need this
ruby <name>.rb
```

No Gemfile, test suite, or CI — each script prints its own `benchmark-ips` comparison when run. See [`CLAUDE.md`](CLAUDE.md) for the conventions to follow when adding a new one (`template.rb` is the scaffold to copy).

## Findings

Conclusions below are pulled from each file's own inline comments, refreshed alongside the 2026-08-06 re-run. **"No conclusion recorded" means the file compares approaches but never annotated a winner** — read it yourself before trusting either side. **"Same-ish"** means benchmark-ips's own confidence intervals overlap — the tool itself can't call a winner, so neither can this table. Findings marked **(reversed)** flipped outright from the historical result; **(now same-ish)** means a previously-confident winner is now statistically tied.

### Array

| Benchmark | Compares | Finding |
|---|---|---|
| [`array_check_or_force.rb`](array_check_or_force.rb) | `is_a?(Array)` check vs `Array()` coercion before `.first` | ✅ refined at default timing: `force-array` actually ties with `check-item` in one large same-ish cluster; `check-array` is a real, separate ~5–8% slower tier — not a toss-up. `check-item` vs `force-item` still clearly favors checking (~2.3x) |
| [`array_exclude_or_each_check.rb`](array_exclude_or_each_check.rb) | `Array#-` to exclude an item vs `each` with a `next if` guard | "check always faster" now breaks at 256 items; "worst position always fastest" no longer holds — flips by size |
| [`array_join_with_unique_or_pipe.rb`](array_join_with_unique_or_pipe.rb) | `Array#\|` (union) vs `(a + b).uniq` | **(reversed, ✅ confirmed at default timing)** `\|` no longer always faster — `(one + two).uniq` wins at 1000+ items |
| [`array_operation_or_chained_comparators.rb`](array_operation_or_chained_comparators.rb) | `[a,b,c,d].all?(&:blank?)` vs chained `&&` comparators | Chained comparators still win, now 2.79x (was 2.27x) |
| [`array_pre_or_post_sort.rb`](array_pre_or_post_sort.rb) | Sorting both arrays before `Array#-` vs sorting only after | Holds — post-sort fastest, pre-sort slowest at every size |
| [`array_splat_or_compact.rb`](array_splat_or_compact.rb) | `[*x]` splat vs `[x].compact` to array-wrap a possibly-nil value | **(reversed, ✅ confirmed at default timing)** nil-splat is now fastest overall (was present-splat); splat now beats compact within the nil group too |
| [`array_vs_hash_for_presence.rb`](array_vs_hash_for_presence.rb) | `Array#include?`/`index`/`bsearch` vs `Hash[]`/`Hash#key?` for membership | ⚠️ **noise, corrected**: `Hash[]` actually wins at *every* tested size — the "`Array#include?` edges it out at 16" claim didn't survive default-timing verification |
| [`array_wrapping.rb`](array_wrapping.rb) | `Array()`, `[].flatten`, and `is_a?`-guarded wrapping, across all/none/mixed inputs | Fresh reading, no single winner: `Array()`/`[]` with a guard are fastest or near it everywhere; `.flatten` is consistently worst |
| [`benchmark_array_concat.rb`](benchmark_array_concat.rb) | Array-building syntaxes and `+` vs `[i, *ary]` concatenation | Fresh reading: `+` vs `[i, *ary]` trades off by size, no clean winner; the hardcoded literal is still ~2x faster than building from a range |
| [`block_check_or_subtract.rb`](block_check_or_subtract.rb) | Pre-removing an element via `Array#-` then `find` vs an inline `!=` check in `find`'s block | Holds — inline block check still wins (~1.23x) |
| [`block_style.rb`](block_style.rb) | `sort_by(&:-@)` vs `sort_by{-_1}` vs `sort_by{|i| -i}` | Holds — explicit block still faster; `&:-@` vs positional arg still doesn't matter |
| [`permutation.rb`](permutation.rb) | `Array#unique_permutation` vs `Array#permutation` on arrays with duplicates | Holds — crossover still at 8 items w/ 4 duplicates |
| [`random_string_array_benchmark.rb`](random_string_array_benchmark.rb) | `num.times.collect` vs `Array.new(num){...}` | `Array.new` still faster at 1/16/100/10000; an apparent win for `times` at 1000 falls inside Array.new's own ±60% error margin — not a real crossover |
| [`small_array_include_or_multiple_comparisons.rb`](small_array_include_or_multiple_comparisons.rb) | `Array#include?` vs direct `==` comparisons for 1–5 item lookups | Holds — direct comparison still wins at every size, no crossover |
| [`sort_reverse.rb`](sort_reverse.rb) | `sort.reverse`, `sort{b<=>a}`, `sort_by(&:-@)`/`sort_by{-_1}` for descending sort | Holds — `sort.reverse` still fastest; `sort_by{-_1}` still beats `sort_by(&:-@)` |

### Hash

| Benchmark | Compares | Finding |
|---|---|---|
| [`array_vs_hash_for_presence.rb`](array_vs_hash_for_presence.rb) | *(see Array — same file)* | |
| [`count_by.rb`](count_by.rb) | `Hash[]`+`group_by` vs inline `group_by`+`tap` vs inline w/o `tap` vs single-pass `each_with_object` counting | Holds |
| [`create_or_modify_hash.rb`](create_or_modify_hash.rb) | Modifying an existing hash's values in place vs rebuilding via `each_with_object` | Holds — modify-in-place always wins |
| [`grouping_array.rb`](grouping_array.rb) | `each`+default-hash, manual `each`, `each_with_object`, `group_by` for grouping | `group_by` no longer fastest at any size — ✅ confirmed at default timing. The ranking among the other four is genuinely messy and shifts with size (⚠️ the "`each_with_object` overtakes manual from 16+" detail didn't hold — don't trust a simple crossover story beyond group_by's loss) |
| [`hash_except_v_reject.rb`](hash_except_v_reject.rb) | `Hash#except` vs `Hash#reject` for removing keys | Holds — `except` still faster |
| [`hash_ignore_in_map_or_ignore_before_map.rb`](hash_ignore_in_map_or_ignore_before_map.rb) | `hash.map{|k,_v|}` vs `hash.each_key.map` | ⚠️ **noise, corrected**: `.map` is genuinely ~1.14x faster at default timing — the "same-ish" call was a shortened-window artifact; original finding holds, just more modest than "consistently slower" |
| [`hash_merge_or_splat.rb`](hash_merge_or_splat.rb) | `Hash#merge` vs `{**a, **b}` double-splat | Holds |
| [`hash_or_assign.rb`](hash_or_assign.rb) | `hash[k]=` vs `hash[k] ||=` vs a default-proc `Hash` | **(reversed, ✅ confirmed at default timing)** `||=` overtakes `[]=` from 16+, and `[]=` becomes the slowest from 1000+; `default` wins from 100+. One correction: at 1 item `[]=` is genuinely ahead (~1.12x), not tied |
| [`hash_or_json.rb`](hash_or_json.rb) | Recursive hash-key regex search vs `to_json` + regex index search | *Newly annotated* — recursive scan wins in nearly every case; `to_json` only wins where the nested match sits early in the serialized string, and only at size 100 |
| [`hash_tap_merge_assign.rb`](hash_tap_merge_assign.rb) | `Hash#tap`, `Hash#merge`, manual `[]=` for building a hash from generated code | Holds — `merge` still fastest at every size |
| [`hash_values_at_or_brackets.rb`](hash_values_at_or_brackets.rb) | `Hash#values_at` vs multiple individual `[]` accesses | Holds — `[]` faster at 2/6 keys, `values_at` faster at 10 |
| [`hash_with_obj_or_array_to_h.rb`](hash_with_obj_or_array_to_h.rb) | `each_with_object({})` vs `map`+`Array#to_h` for transforming a hash | ⚠️ **noise, corrected**: genuinely no clean crossover in either direction — `each_with_object` wins at 1/4/8, `Array#to_h` wins at 2/16/32. Neither the original claim nor the "`Array#to_h` always wins" revision survived default-timing verification |
| [`key_inclusion.rb`](key_inclusion.rb) | Array difference (`keys - test_keys`) vs `Hash#has_key?` | *Newly annotated* — `has_key?` wins at 1/100/1000/10000; array-diff's one win at 16 looks like noise (overlapping error bars) |

### String

| Benchmark | Compares | Finding |
|---|---|---|
| [`base64.rb`](base64.rb) | `String#unpack('m*')` vs `Base64.decode64` | **(reversed, refined at default timing)** `decode64` wins at 1/16/100/1000 (clearly ahead even at 1, not tied) — but `unpack` flips back ahead at 10000 |
| [`character_replacement.rb`](character_replacement.rb) | `gsub` (string), `gsub` (regex), `tr` for single-char removal | *Newly annotated* — `tr` wins ≤100 chars; `gsub` (string pattern) overtakes at 1000+; `tr` becomes slowest by 10000 chars |
| [`gsub_tr.rb`](gsub_tr.rb) | `gsub` (string) vs `gsub` (regex) vs `tr` for character replacement | `tr` is still "bonkers faster" — note: not semantically interchangeable with `gsub`. The regex-vs-string-arg `gsub` comparison shifted; see the file |
| [`no_op_vs_string_to_i.rb`](no_op_vs_string_to_i.rb) | `String#to_i` (frozen/unfrozen) vs `Integer#to_i` no-op | Gap narrowed to ~17–18% (was 34%); frozen `String#to_i` is now slightly *faster* than unfrozen (was the reverse) |
| [`squeeze_gsub.rb`](squeeze_gsub.rb) | `squeeze` vs `gsub` (regex) vs `strip`+`squeeze` for collapsing repeated spaces | Holds — squeeze-family fastest, gsub-family slowest at every size; a new same-ish 3-way tie appears at size 4 |
| [`string_char_removal.rb`](string_char_removal.rb) | `delete`, `slice`, `sub`, `tr`, `gsub`, `rpartition` for stripping a leading char | Holds — `[1, #size]` still fastest overall, `[0] = ''` still fastest among dup-first approaches |
| [`string_concat_if_or_object_compact.rb`](string_concat_if_or_object_compact.rb) | `<<` with if-guards vs `hash.compact.map.join` vs `hash.reduce` for conditional string building | Direction holds but ratios shrank: string-concat ~13x faster than reduce/hash (was ~23x); hash vs reduce now roughly tied (hash used to win) |
| [`string_literals.rb`](string_literals.rb) | `%w[]` vs manual array vs manually-frozen string array literals | Holds — manual array + freeze still fastest, map+freeze still slowest |
| [`string_shovel_join_or_interp.rb`](string_shovel_join_or_interp.rb) | Interpolation vs `Array#join` vs `<<` for concatenation | **(changed, ✅ confirmed at default timing)** `<<` wins when both strings are short, interpolation wins when the appended string is much larger than the base — including a plain interpolation win at 100+100, correcting an earlier "interp+`<<`" misread; `join` stays consistently slowest |
| [`strip_squeeze_gsub.rb`](strip_squeeze_gsub.rb) | `strip` vs `squeeze` vs three `gsub` (regex) variants for trimming/collapsing spaces | Holds — `strip`/`squeeze` still far ahead of every `gsub` variant at every size |

### Time/Date

| Benchmark | Compares | Finding |
|---|---|---|
| [`date_range_or_manual.rb`](date_range_or_manual.rb) | `Range#include?` vs `Range#cover?` vs manual `>`/`<` for Date ranges | Holds — `cover?` fastest, manual close behind, `include?` still catastrophically slower (exact multiples shifted) |
| [`hours_helper_vs_math.rb`](hours_helper_vs_math.rb) | ActiveSupport `25.hours.ago`/`from_now` vs manual `Time.current` +/- constant | *Fixed (was missing `require 'active_support'`, only ran before inside an ambient Rails console).* `(Time.current - CONST)` is now the outright fastest; `+CONST` is same-ish with it |
| [`time_adjust.rb`](time_adjust.rb) | `seconds_since_midnight` vs `beginning_of_day` for comparing times | ⚠️ **noise, corrected**: not a 4-way tie — `seconds_since_midnight` (eq/neq tie with each other) is genuinely ~1.11–1.14x faster than `beginning_of_day` (eq/neq tie with each other) |
| [`time_current_or_now_for_utc.rb`](time_current_or_now_for_utc.rb) | `Time.now.utc` vs `Time.current.utc` | *Fixed (missing base `active_support` require).* Holds — `now` still faster, now 1.62x (was ~1.3x on Rails 6.1) |
| [`time_date_iso_strftime.rb`](time_date_iso_strftime.rb) | `Date#iso8601` vs `Date#strftime` vs `Time#strftime` | Holds — `to_date.iso8601` still fastest |
| [`time_get_year.rb`](time_get_year.rb) | `Time.now.year` vs `Time.current.year` | *Fixed (missing base `active_support` require).* ⚠️ **noise, corrected**: `Time.now.year` is genuinely faster, and by more than the original claim (1.38x, not ~14%) |
| [`time_helpers.rb`](time_helpers.rb) | ActiveSupport `24.hours.ago` vs manual `Time.now.utc - seconds` | *Fixed (missing base `active_support` require).* Holds — `24.hours.ago` still slower, gap widened to 2.53x (was 2.2x) |
| [`time_simple_compare.rb`](time_simple_compare.rb) | Integer hour/minute comparisons vs `Time` object comparison, incl. inline construction | "true" vs "timestamp" narrowed from ~1.46x apart to nearly identical; inline `Time` construction penalty narrowed to ~24.6x (was ~33x) |
| [`time_specific_compare.rb`](time_specific_compare.rb) | Integer hour/min checks vs `Range#include?` over `Time` objects, with/without object creation | ⚠️ **noise, corrected**: range-without-creation is genuinely faster than integer checks, and by more than the original claim (1.87x, not ~50%); inline range construction penalty is 28.71x |
| [`time_to_i_utc.rb`](time_to_i_utc.rb) | `Time.now.utc.to_i` vs `Time.now.to_i` | Holds — `Time.now.to_i` still faster, margin narrowed to 1.54x (was 2x) |
| [`time_travel.rb`](time_travel.rb) | ActiveSupport `3.minutes.from_now` vs `Time.current + 3.minutes` | *Fixed (missing base `active_support` require).* Holds — `from_now` still slightly faster (1.12x) |
| [`time_zone_direct_or_use_zone.rb`](time_zone_direct_or_use_zone.rb) | `Time.use_zone` block vs `Time.find_zone(...).now` direct call | *Fixed (missing base `active_support` require).* ⚠️ **noise, corrected**: `use_zone` is genuinely slower, close to the original figure (1.29x, was ~1.4x) |
| [`utc_first_or_to_i_convert.rb`](utc_first_or_to_i_convert.rb) | `Time.current.utc - offset` vs `(Time.current - offset).to_i` | *Fixed (had no ActiveSupport require at all).* **(reversed, ✅ confirmed at default timing)** "utc first" was 2x faster historically — now 1.13–1.16x **slower** |

### Struct/Class/Object

| Benchmark | Compares | Finding |
|---|---|---|
| [`benchmark_class_init.rb`](benchmark_class_init.rb) | Init/access speed of `Hash`, `OpenStruct`, `Struct`, ordered `Struct`, plain `Class` | Fresh reading, no single winner: `Hash` fastest to init, `Struct` fastest to access, `OpenStruct` dramatically slowest at both |
| [`struct_vs_class.rb`](struct_vs_class.rb) | Plain `Class`, inherited `Struct`, assigned `Struct` — init-with-args vs post-init assignment | ⚠️ **noise, corrected**: not a 6-way tie — `PersonClass new w/ args` is decisively the fastest of all six (beats everything else by 1.38–1.59x), a third finding distinct from both the original and the "same-ish" reading |

### Set

| Benchmark | Compares | Finding |
|---|---|---|
| [`set_or_array_lookup.rb`](set_or_array_lookup.rb) | `Array#include?` vs `Set#include?` at small sizes | Holds — crossover still ~4 elements |
| [`set_or_array_uniq.rb`](set_or_array_uniq.rb) | `(array1+array2).sort.uniq` vs `(set1+set2).sort` for deduping | **(now same-ish, ✅ confirmed at default timing)** was "Array faster by .09x" — still flagged by the author as correctness-unverified |
| [`set_sort_array_equality.rb`](set_sort_array_equality.rb) | `Array#sort#==` vs `Set#==` for order-independent equality | **(now same-ish, ✅ confirmed at default timing)** was a clear `Array#sort#==` win |

### Math/Numeric

| Benchmark | Compares | Finding |
|---|---|---|
| [`default_already_converted.rb`](default_already_converted.rb) | `String#to_f`, `Integer#to_f`, pre-converted `Float` default | **(now same-ish, ✅ confirmed at default timing)** int-to-float nominally edges out the pre-converted default now, but they're statistically tied — no longer "fastest for sure" |
| [`float_division_final.rb`](float_division_final.rb) | `Int#fdiv` w/ explicit `to_f` vs `Float#/` w/ internal conversion | Holds — `Float#/` still ahead, though the gap is now a modest 1.17x rather than "much faster" |
| [`float_division_generic.rb`](float_division_generic.rb) | Multiple `to_f`/`fdiv` combinations | **(reversed, ✅ confirmed at default timing)** plain `fdiv i` (no conversion) is now tied for fastest overall, was slowest; `fdiv to_f` dropped from fastest `fdiv` to slowest |
| [`float_division.rb`](float_division.rb) | Many int/float division and `fdiv` variants | **(reversed, ✅ confirmed at default timing)** plain `fdiv` jumped from bottom-3 to top-3/fastest `fdiv`; `to_f/f` (not `to_f/`) is now fastest of the `to_f` family. One overstatement corrected: `fdiv to_f` is no longer fastest `fdiv`, but it's not the outright slowest either |
| [`range_comparison.rb`](range_comparison.rb) | `Range#include?` vs chained `>=`/`<=` for bounds checking | *Newly annotated* — `>&&<` beats `Range#include?` at every size and condition tested, no crossover |
| [`to_numbers.rb`](to_numbers.rb) | `String#to_i` vs `String#to_f` on int-like and float-like strings | `to_i` w/ int and w/ float are now statistically tied; `to_f`'s edge on int-like strings narrowed to ~3% (was ~10%) |
| [`zero_predicate_or_literal.rb`](zero_predicate_or_literal.rb) | `Integer#zero?` vs `== 0` literal comparison | ⚠️ **noise, corrected**: not a 4-way tie — `== 0` (true/false tie with each other) is genuinely ~1.13–1.14x faster than `zero?` (true/false tie with each other); original direction holds |

### Collection/Enumerable

| Benchmark | Compares | Finding |
|---|---|---|
| [`attribute_sum_benchmark.rb`](attribute_sum_benchmark.rb) | Manual loop, `inject`, `collect.sum`, `sum(&:value)`, dual-accumulator loop | `sum(&:value)`/manual/`collect.sum`/`inject` ranking holds; "manual 2x" reversed — now consistently *slower* than `collect.sum` across 2–16 items (was faster) |
| [`collect_vs_each_with_object.rb`](collect_vs_each_with_object.rb) | `collect`, `collect`+`compact`/`reject`, `each_with_object` for mapping with skips | `collect` is only fastest at 1 item now; the compact-skipping variant overtakes it from 16+ |
| [`sum_benchmark.rb`](sum_benchmark.rb) | Manual loop, `reduce(0){}`, `reduce(&:+)`, `Array#sum` | Holds — `sum` still dominates for 1+ items (tied with manual only at 0) |
| [`with_index_reduce_chain.rb`](with_index_reduce_chain.rb) | `each_with_index.reduce` vs `each_with_object.with_index` for building an index=>value hash | ⚠️ **noise, corrected**: practically equivalent — differences are tiny (<2%) and flip direction by size (`with_index` wins at 1/16/128/1024, `reduce` wins at 32/512) |

### Regex

| Benchmark | Compares | Finding |
|---|---|---|
| [`reg_percent_r_sigil.rb`](reg_percent_r_sigil.rb) | `/#{string}/` interpolation vs `%r[#{string}]` sigil | Holds — still no clear winner, too noisy |
| [`regexp_capture_group.rb`](regexp_capture_group.rb) | Capturing vs non-capturing regex group, on hit and miss strings | **(reversed, ✅ confirmed at default timing)** misses are now *faster* than hits. Correction: the capture-vs-non-capture gap is only slight on the *hit* side (~1.03x) — on the miss side it's a real 1.76x |

### Other

| Benchmark | Compares | Finding |
|---|---|---|
| [`param_filtering.rb`](param_filtering.rb) | `ActiveSupport::ParameterFilter` with a full filter list vs a reduced list (regex vs strings) | Holds — reduced list still faster (now ~17%, was "20+%"); regex-vs-strings still within margin of error |
| [`tap_or_long_way.rb`](tap_or_long_way.rb) | `Object#tap` with a block vs with a proc vs plain sequential statements | Holds — plain sequential code still wins |

### Not benchmarks

- [`thread_testing.rb`](thread_testing.rb) — an ActiveRecord locking/transaction timing experiment, no `benchmark-ips` harness.
- [`pathfinding.md`](pathfinding.md) — unrelated notes on exploring a large, unfamiliar codebase.

## Caveats

- **The full 70-file sweep used a shortened benchmark-ips window** (1s warmup / 1s calculation, vs. the tool's own 2s/5s default) to make re-running everything in one sitting tractable. The 24 files with reversed or newly-"same-ish" findings were then re-run at true defaults (2s/5s) to check which survived — results are folded into the findings above, tagged **✅ confirmed** or **⚠️ noise, corrected**. Roughly half held up as real; the other half were false ties or false reversals from the shortened window, in both directions — some corrected back toward the original historical finding, and a couple (`struct_vs_class.rb`, `array_check_or_force.rb`) landed on a third result different from both prior readings. Files without either tag weren't re-verified at default timing and carry the same shortened-window risk.
- **Nine files were outright broken** on this Ruby/ActiveSupport version before being fixed as part of this pass:
  - [`hash_or_json.rb`](hash_or_json.rb) — relied on `Kernel#=~`'s no-match default for non-String keys, which Ruby 3.2 removed.
  - [`hours_helper_vs_math.rb`](hours_helper_vs_math.rb), [`time_current_or_now_for_utc.rb`](time_current_or_now_for_utc.rb), [`time_get_year.rb`](time_get_year.rb), [`time_helpers.rb`](time_helpers.rb), [`time_travel.rb`](time_travel.rb), [`time_zone_direct_or_use_zone.rb`](time_zone_direct_or_use_zone.rb), [`utc_first_or_to_i_convert.rb`](utc_first_or_to_i_convert.rb) — all required an ActiveSupport `core_ext` file directly without the base `require 'active_support'`; current ActiveSupport needs the base load first for `Time.current`/`Time.zone` to work.
  - [`string_concat_if_or_object_compact.rb`](string_concat_if_or_object_compact.rb) — relied on `active_support/inflector` transitively loading `#present?`, which current ActiveSupport no longer does.
- A handful of "faster" wins still aren't drop-in-safe: `tr` (in [`gsub_tr.rb`](gsub_tr.rb)) does char-set substitution, not literal/regex replacement, so it's not interchangeable with `gsub` despite winning on speed.
- Findings before this pass were measured at different times across 2017–2025 on whatever Ruby/Rails version was current then, with no version recorded — which is exactly why so many flipped. Re-run again before trusting any number for more than a couple of years.
