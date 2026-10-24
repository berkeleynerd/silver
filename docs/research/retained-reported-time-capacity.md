# Reported-time representation: source and configuration derivation

2026-10-24 UTC, #119/#206. **Candidate complete for independent composition
review. No configuration is adopted by this note.** The
[packet](../evidence/retained-reported-time-capacity-20261024/README.md) freezes
the private configuration, all selected time origins, numeric consumers and
the additive startup interface. The accepted #194 interface requires a source/configuration
provider for the time converted by `spark_report` to Integer. Finite native
server time alone does not establish its `Integer'Last-128` sufficient margin.
`Print_Most_Difficult_Proved_Checks` is called unconditionally; quiet output
does not remove that conversion. The actual source witnesses are retained in
the #194 packet, `spark_report.adb:1161–1191,1566`.

The candidate uses supported private-driver configuration, not tool edits or a
finite proof timeout. Timing values would be explicitly normalized metadata,
not measurements. Preserve per-attempt identity, answer/status, complete proof
obligations and independent failure/resource evidence. Changed timing may
change credit among already Valid provers; identical selected-prover statistics
are not promised. Production #88–#94 remains unstarted.

## Source result and the caught-exception seam

In the pinned Why source, `Call_provers.timeregexp` creates a unit array from
the `%h/%m/%s/%i` substitutions in a driver `time` pattern. With no such units,
that array is empty. If the regexp search succeeds, `grep_time` initializes
`t=0.`, iterates no units and returns `Some 0.` (`call_provers.ml:83–115`).
`parse_prover_run:357–387` then applies the existing floor `mu=0.000001`.
The already selected zero time/step limits bypass the answer-reclassification
branches. Answer, status, output and model fields otherwise follow their
existing computation.

One always-matching pattern is insufficient. The `try ... with _` covers the
search and construction of its returned option; an escaping save exception can
make the function recurse into an empty tail and fall back to raw server time.
Worse, a failed first `Lazy.force` can retain the exception, causing future
fallbacks without any new signal. This was independently identified during
early source review. The global e<=2 allowance bounds new escaping save events,
not every subsequent exception caught by this function.

The candidate therefore uses **three separately constructed timing records**,
each with a zero-unit pattern matching at offset zero. They are three driver
load occurrences, not three aliases of one record. Charge the first relevant
interruption to the currently active private owner; later deterministic
failures of that owner retain that charge. A post-search/option-construction
failure may spend an event without corrupting an owner. With the existing
single process-wide e<=2 budget, at least one of three independent owners
remains untouched. Its normal search must return zero. Exceptions in the
inter-entry recursion outside the protected search abort parsing rather than
returning an unbounded fallback.

This argument is still conditional on **memory-safe owner isolation and
recovery**. Labelling a private owner corrupted cannot excuse an unsafe native
write, a new infinite loop, or damage to another owner. Physical-resource
failures and the existing runtime/callback premises retain their stated scope;
no new blanket exception exclusion is introduced.

## Candidate small regexp

The candidate now uses the supported search-start pattern, a backslash
followed by equals. The initial begin-of-string draft is withdrawn: native
`Str.compile_regexp` calls `Emacs.re_no_emacs`, whose false flag skips the
backslash-backtick BOS case and treats the backtick as a literal. The reference
source lacks that gate. Native inspection found the search-start case ungated,
returning `Start`; its translation uses `After(search_boundary=32)`. The
selected `search_forward` always starts at zero. No native engine was executed.

The source `Ast.anchored` recognizes Start, avoiding the unanchored search
prefix. `Group(Start)` translates into one `After(search_boundary)`, two marks
and two sequences. There are no sets, repetitions or named groups. Colour
construction has one ordinary colour. Initial category is
`search_boundary|inexistant=33`. The first derivative immediately produces one
match; an empty input's final-boundary derivative does the same. The proposed
small-owner invariant is:

- One initial category and at most two normal state-table keys; interrupted
  insert counts need a separate e<=2 charge, with no table resize.
- New pre-index marks have no nonnegative used index. Index choice is zero;
  native inspection gives hint zero and a fresh positions array of length one.
  The working bitvector stays zero without growth.
- Initial-state, transition and final-cache publication stores only completely
  constructed immutable records. Re-entry after an interrupted publication
  finds the existing key or reconstructs that same bounded state.
- Native duplicate removal takes the singleton-match branch and never calls
  Hash_set.add; its optional scratch remains None. The actual body/operand
  attachment is being retained by the native subthread.
- Each call has a fresh positions owner. Shared `Str.state` is overwritten by
  search and never read by zero-unit conversion, which calls no matched-group
  accessor. A cached lazy exception stays attached to its own regexp.

The separate [native lifecycle derivation](retained-reported-time-native.md),
with final native/placeholder freeze `6cc4c72f63` independently reviewed at
`35a5bea549`, supplies the selected owner proof and a
`640*o + 256*q` owned-word interface, with block headers, for `o<=9` owners
and `q` attempted searches. It covers both empty and nonempty arbitrary
represented inputs, including interrupted reuse and cached exceptions. It
does not cover the different placeholder regexp constructed inside
`Call_provers.timeregexp`, nor a whole-process resource bound. Its source and
native correspondence are accepted as bounded providers; their attachment
requires review with this composition. The #208 offset-wrapper correction
changes the detailed call subtotal to214, still within the256-word credit.
R71/R72's earlier fresh answer-regexp proof alone would not establish this
reused-owner lifetime. Unselected configured drivers remain outside attempted
proof selection, as in the controlled recipe.

## Frozen private recipe and constructor relation

Use exactly R78's seven configuration files, all path spellings, unique-file
membership and discovery/import alternatives. Replace only line23 of the
private `overlay/slv-libv2.gen`. The before line is32 bytes including LF;
the after line is33 bytes including LF:

```text
time "\\=" time "\\=" time "\\="
```

Its exact bytes including LF are
`74696d6520225c5c3d222074696d6520225c5c3d222074696d6520225c5c3d220a`.
Each driver string decodes to `5c3d`, the two-byte backslash-equals pattern.
The Alt-Ergo root's own removed-time comment stays unchanged. There is no
other time directive in the selected loaded projection. Other files, prover
keys, commands, transformation/syntax/model/answer/step directives, imports
and configured solver limits remain byte-identical to R78. In particular the
selected ordinary commands retain time/step limits zero, CE off and non-replay.

`create_controller` loads **all nine configured roots**, not just the three
selected provers (`controller_itp.ml:114–136`). The R78 unique-path graph has
one private-common-file occurrence in each selected CVC5, Z3 and Alt-Ergo
root. The other six configured roots reach installed imports. The checker
walks that graph separately for all five retained layouts: exactly three
new located globals per selected root, nine records total, and no new record
in the other roots. `Driver.add_global` invokes `timeregexp` once per AST
occurrence; its local lists and final `List.rev` preserve three distinct
records and independent lazies per selected result parser. A different
selection, driver reload or dynamic config update needs a revised occurrence
bound; this recipe does not silently normalize an unselected driver.

The added productions are `TIME STRING`, then `global`, `loc(global)` and
the enclosing right-recursive global list. They are not comments consumed
without parser work. After line23, both `pos_cnum` and `pos_bol` shift by one;
their difference and each following line/column remain unchanged. Raw
offsets, complete lexer buffers and captured heaps are not equated. All
new positions are on the fixed33-byte line; they fit the existing packed
location domain. Existing filenames and equality classes are unchanged;
there is no additional FileTags name beyond R78's already charged common-file
split. `Loc.extract` uses filename, line and column, not an absolute byte
offset as a semantic key.

Driver dispatch changes only `timeregexps`. The added globals do not request
theories, allocate logical identifiers, alter theory traversal or change
driver-export names. Non-time driver fields and their semantic request/cache
relations follow R78 after erasing the nine new time globals. Establishing
that this related trace retains the no-collection condition additionally
requires the allocation delta below; syntactic erasure alone is insufficient.

Each `timeregexp` first builds the different pattern `%\(.\)` and invokes
`global_substitute` on `5c3d`. Neither input byte is `%`, so the one search
fails, the replacement callback is never called, `nb` stays zero and the
unit list stays empty. The substitute's failure branch takes a two-byte
`string_after`, constructs a singleton list, reverses it and concatenates
the singleton; it returns the original two-byte contents. The final timing
owner is constructed from those bytes; no output-length-dependent string
is created at driver load. The source's `Str.state` is None on completion
of the failed placeholder search. Later successful matching calls overwrite
it before their matched-group reads; no timing rule reads a group. This
does not remove the placeholder construction/search allocation charge.

## Result induction and observation boundary

Let `mu` denote the actual binary64 literal `0.000001`, and `D={0,mu}`.
Use the existing authentic server-response, ordinary runtime, complete
obligation and resource premises, the exact selected roots above, and a fresh
session with no replay/import/editor injection. The fresh-session condition
is a source branch, not just the absence of `--replay`: either `force` selects
`empty_session`, or the session path is absent and that same branch runs.
An existing directory with `force=false` calls `load_session` even without
`--replay`, and is outside this induction (`gnat_checks.ml:384–416`).

The exhaustive retained Why3-source `pr_time =` census has nine lines, of
which one is a record pattern and one a local JSON-reader binding. The actual
origins and transports are:

| Source route | Time and induction step |
| --- | --- |
| Ordinary file result, `call_provers.ml:342–388` | Owner theorem gives `Some 0.`. Both positive-limit tests are false. The existing floor returns `mu`, for every answer/status and every represented output. |
| Empty filename, `call_provers.ml:392–400` | This branch bypasses `grep_time`; it must be checked separately. The Unix server's only empty-filename sender is queued removal and passes0 (`server-unix.c:536–545`). `%f` serialization/readback preserves0. |
| Other Unix server completion | `run_request` stores the nonempty `dir/why3XXXXXX` template from `open_temp_file`; `handle_child_events` sends that filename (`:132–143,434–535`). Its native CPU time therefore reaches the ordinary normalized branch. No malformed/external protocol record is reclassified as a queued cancellation. |
| Trivial, `gnat_checks.ml:237–264` | Fixed `pr_time=0.`. Its synthetic limits1 are not a launched solver limit and do not change the configured zero-limit argument. |
| Editor, `call_provers.ml:567–583` | Fixed0 even if considered; this automatic noninteractive selection does not schedule an editor. |
| XML session load, `session_itp.ml:1034–1052` | Can import arbitrary parsed time; excluded by the fresh branch. Reload/merge of an old session is not silently admitted. |
| IDE JSON import, `json_util.ml:599–618` | Can import arbitrary time or default-1; the selected `gnat_main` automatic entry has no IDE result-import route. |
| Controller smoothing, `controller_itp.ml:401–409,472` | Returns `nres` or a copy with `ores.pr_time`. The floating comparisons decide which existing value to copy, never a third time. |

Initially `empty_session` has an empty attempt table (`session_itp.ml:586–636`).
Grafting adds/resets `proof_state=None`, and `update_proof_attempt` installs
the supplied record without changing its time (`:645–676,737–747`). Before
reset, scheduling saves the old result in `spa_ores`; it is a prior value of
the same induction (`controller_itp.ml:620–647`). `Done` installs the returned
result. Interrupted/InternalFailure notifications create no new result
(`:592–616`). Copies/merges within this fresh process only copy values already
in D. Save callbacks serialize the current state; they do not import a time.
In particular the selected `save_result` emits status/steps, not a time
attribute (`session_itp.ml:2056–2078`). Thus induction over every result and
session update keeps all reachable attempt times in D, conditional on the
owner theorem and successful resource instantiation. The record-pattern use
at `controller_itp.ml:354` is not another constructor.

Statistics initialize time from a selected result or0 and update it only by
maximum (`gnat_checks.ml:806–826`; `gnat_report.ml:135–155`). Checker and
SPARK flow records contribute0. `VC_Kinds.From_JSON` reads `max_time` into
Float; database merge and `Process_Stats` only take maxima. Under ordinary
decimal formatting/parsing, `0<=Max_Time<=1` therefore survives the
binary64-to-decimal-to-Long_Float-to-Float route. This slightly wider interval
avoids pretending that binary32 preserves the exact binary64 mu. It safely
supplies #194's `duration_ceiling=1 <= Integer'Last-128`. The unconditional
`Integer(PC.Max_Time)` is represented and nonnegative, without any restriction
on actual proof elapsed time. This normalization may cause the existing
“No check found with max time greater than 1 second” line; it is a metadata
observation, not evidence that the proof finished in a second.

`find_successful_proof` compares times **among already Valid results**
(`gnat_checks.ml:769–800`). Normalization can change which valid prover receives
credit and its max-step statistic. Each attempt's identity/answer/status record
is distinct, and time is not the proof-success criterion. This is the same
observation distinction already exposed by the accepted timing-configuration
record; a future wrapper must not present normalized figures as measured time
or use them as physical-resource attribution.

The selected numeric-time inventory distinguishes these other conversions:

| Conversion/consumer | Scope of this result |
| --- | --- |
| Native `ru_utime` integers to double, `%.6f`, then `float_of_string` | Still happens before normalization, under the existing server-record bound. The recipe neither bounds elapsed CPU time by1 nor bypasses wire-buffer checks. |
| `%h/%m/%s/%i` group `float_of_string`, multiplication/division | Not reached for zero-unit patterns; the unit array is empty. |
| `actualcommand` ceiling/milliseconds to OCaml int (`call_provers.ml:405–407`) | Uses the configured/adapted limit, not result time. The retained zero-limit proof makes all three limit values0; no new positive timeout is introduced. |
| `fuzzy_proof_time` arithmetic and valid-proof comparison | Arithmetic only controls a choice of existing times; selection among Valid provers may change. |
| Attempt tree `%g`, logging time `%f`, statistics `max_time` `%f` | Receives D, under existing scalar-format bounds. Extra formatting bytes are not inferred to be a deletion; the general formatter bounds still apply. |
| GNATCOLL `Long_Float'Value`, then `Float(Flt_Value)` and final Ada Integer | For normalized attempt statistics,0..1 survives each representation step (`gnatcoll-json.adb:620–628,1350–1358`; `vc_kinds.adb:1202–1211`). |
| Log `timestamp`, debug timestamps, `Debug.Stats` timing differences/sums, report calendar end time | Separate clock fields. `get_timings` emits the Stats values separately; none is fed into the report's Max_Time conversion. Their accepted clock/Float/formatting premises remain necessary. No claim normalizes or newly bounds them. |

Thus this provides the reported-attempt-time domain, not a universal bound
for every clock or time-dependent native arithmetic in the tools.

## Open configuration and allocation joins

Adding timing records reverses the old deletion-only transfer. Define
`D_start` as an **additive resource vector**, from the first changed driver
byte through completed controller creation, containing minor words, major
words including headers/history, remembered entries, ephemeron/custom entries,
native allocation/stack and resource-fraction effects. Its disjoint owners are:

1. The changed line's lexer invocations, nine keyword/string tokens,
   `Buffer.create 128`/two-byte contents, located `TimeRegexp` AST values,
   persistent global-list construction, and additional parser stack cells and
   reduction/transition objects. The raw-offset shift can change refill
   boundaries are covered by charging the complete new common-file token
   segment. The installed coefficient is derived from its finite grammar
   and elementary-transition call graph in the packet, not token count alone.
2. Nine **fresh placeholder** regexp shells, their forced compilation and
   one failed search over two-byte input. This is the fixed `%\(.\)` path,
   with unanchored searching and different mutable scratch. The Start-owner
   theorem's coefficient cannot be substituted for it. The separately reviewed
   placeholder provider contributes4096 words per occurrence.
3. Nine `timeregexp` wrapper constructions: two refs, replacement and unit
   iteration closures, `global_substitute` closure/substring/list work,
   empty group array handling, returned records, and both accumulating and
   reversed timing-list spines. All remain charged even if later garbage;
   startup's no-collection proof cannot subtract dead objects. The attached
   native wrappers and source singleton/empty cases cost at most64 words per
   occurrence, including both timing-list spines.
4. Nine final Start-pattern regexp constructions, including private lazies.
   The native provider's128-word construction credit is before this cut.
   Its additional512-word first-force credit and256-word attempted-search
   credit are later: no proof result has been parsed before driver loading
   completes. Do not charge them as already initialized state at the cut.

The [allocation derivation](../evidence/retained-reported-time-capacity-20261024/allocation.md)
charges three complete common-file lexing/parser segments at their existing
lexbuf cuts. Their412 tokens,72 strings of at most121 source bytes and
depth-one comments give a finite grammar charge. The actual single-stream
import parser retains a deeper linked stack for the new globals; the argument
preserves old-token transitions and same-size old reductions through the root
EOF and charges the three new final reductions. It does not invent a fresh
standalone parser for the imported file. Native Menhir stack cells are linked
five-field records, not a growing array. The extra source-owned blocks all
have payload at most256 words, so the successful-prefix delta is
**91,752,681 minor words**, with zero additional major, remembered,
ephemeron/custom/dependent or resource-fraction demand. No extra file/channel
or foreign-buffer owner is introduced; the existing open/lexbuf construction
is outside this additional-work cut.

Let T count all `ProverFinished` result deliveries, including ordinary
nonempty-file results and empty-filename queued cancellations, with `o<=9`
lifetime owners. Primary timing searches perform at most three calls per
ordinary-file result and none per cancellation, so `q<=3T`. Later deltas also
include the `grep_time` ref/closure/Some allocations and any additional
smoothing copies caused by normalization. The controller can call
`fuzzy_proof_time` once per delivered result, including queued cancellations,
so at most T additional seven-word result copies are charged without assuming
that an old proof result is absent. The concrete extra post-cut allocation is
`512*o + 266*q + 7*T` words. `transfer.py` exports this function with keyword
`finished_results` separately from the startup delta. Its runtime/GC/remembered-write
owners remain under the existing general providers; startup's zero-remembered result does not
extend to later promoted owners. The result record's answer/status/output/model
fields have the same shape, but a changed conditional path cannot be declared
allocation-free merely because its eventual value has that shape. The raw
input can remain reachable from shared `Str.state`; its existing raw-input
owner must be retained until replacement. It is not a zero-byte retained
string because the match has length zero.

The existing common-path FileTags overcharge is used once. The new recipe
adds no filename, open occurrence, plugin, logical cache request, configured
prover key or transformation. It therefore needs no second full-table
FileTags credit. That observation does not cover regex/parser allocations,
new remembered stores, a shifted allocator threshold or stack growth.

For each R56 layout use its **already corrected R78** bounds plus D_start,
retaining the first-event/no-collection/contiguous-remnant induction. The
uniform sufficient strict margins are mechanically reattached to the saved
R56 projection:

| Additional component | Required strict upper bound |
| --- | ---: |
| Minor words |132,913,732 |
| Current major words |259,912,143 |
| All major words, including history |8,250,999 |
| Remembered entries |14,560,710 |

The numeric delta fits these margins: maximum minor use becomes227,274,405
words below2^28, leaving41,161,051 words. All major/history/reference/table
and resource-fraction bounds retain their R78 values. Together with the
individual small-request and young-owner source classification this excludes
the first extra collection. Native stack remains the existing sufficient
physical-stack premise plus the fixed new constructor chain; the parser's
tail dispatch/linked stack and fixed2/6-byte regexp inputs introduce no new
recursion depending on Main, output length or T. Captured stack bytes are
not equated and no aggregate physical-stack/RSS fit is asserted.
R78's interrupted/terminal-prefix theorem must receive the same added
constructor prefixes and physical-storage charges. Its two save-entering
callbacks, three saves and e<=2 remain one process-wide allowance.

For #202, let C be the cut after `create_controller`/driver loading and before
`add_file`. If the separately established source-independent old entry
provider at C is E_old, the new one uses `E_old + D_start` with the new
recipe identity and the added persistent timing owners. The baseline author
freeze `e45ee72a42` was independently accepted at `0116f0bee539`.
The packet's concrete `extend_entry_envelope` consumes that exact baseline
object and rejects a different configuration fingerprint. It recomputes all
counter/backing/scalar guards; its largest managed/static carrier is
**237,953,393 words** before later input-dependent demand. This is a monotone
source-prefix restriction, never subtraction of a
captured endpoint or reuse of an empty timing-list entry state. New clocks or
timing scratch are not charged to the current Main's JSON bytes.

The fixed recipe, time-origin/consumer induction, successful-startup vector,
later constructor interface and cut-C extension are concrete and checkable.
The remaining local obligation is independent review of their combined
source/configuration attachment. Subsequent whole-process runtime/GC/storage
composition, especially #201/#202, retains its existing open obligations;
this does not turn the new time domain into a complete #119 resource bound.
#206 remains In progress pending that review and owner/lead integration.
