# Reported-time representation: working derivation

2026-10-24 UTC, #119/#206. **Unreviewed and incomplete. No configuration is
adopted by this note.** The accepted #194 interface requires a source/configuration
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

These bullets are proof obligations, not accepted bounds. R71/R72's fresh
answer-regexp proof does not by itself establish this reused-regexp lifetime.
All nine timing records across the three selected driver loads need the same
argument; unselected configured drivers must remain outside attempted proof
selection, as in the existing controlled recipe.

## Result induction and observation boundary

Subject to that owner theorem, normal parsed results have time mu. The native
server's queued-removal path sends an empty filename and time zero
(`server-unix.c:536–545`), and the corresponding special result preserves zero.
Fresh Trivial results have time zero. A fresh session contains no imported old
proof times. `fuzzy_proof_time` copies only a stored prior time or the new one;
induction would keep all selected prover times in `{0,mu}`. A ceiling of one
would then satisfy #194's Integer conversion guard without restricting actual
elapsed proof time. Any replay/imported-session route needs its own premise.

`find_successful_proof` compares times **among already Valid results**
(`gnat_checks.ml:769–800`). Normalization can change which valid prover receives
credit and its max-step statistic. Each attempt's identity/answer/status record
is distinct, and time is not the proof-success criterion. This is the same
observation distinction already exposed by the accepted timing-configuration
record; a future wrapper must not present normalized figures as measured time
or use them as physical-resource attribution.

Other timing fields, including `Debug.Stats`'s top-level timings, remain
separate. No claim normalizes their native clocks. Identify every relevant
numeric conversion and preserve the existing finite Float/JSON bounds before
exporting a complete timing provider.

## Open configuration and allocation joins

Adding timing records reverses the earlier deletion-only transfer. Account for
TIME/STRING parser objects and stack growth, substitution-pattern construction
and search, empty unit arrays, persistent timing lists and per-record lazy
states. The primary timing search is forced later, at the first result.
Original prefix credits cannot be reused without a new additive or restrictive
source argument. No observed final heap can supply this delta.

The three search-start directives can share one physical line. Their exact
escaped bytes and any byte-offset delta still need to be frozen. Preserve
following token line/column identities, selected driver keys/commands, private
import resolution and all required semantic request/cache relations. Do not
equate raw lexer offsets or entire captured heaps after an edit.

#202's new pre-JSON entry-state function must consume the selected driver
configuration. Fixed-process R78 and later source/storage interfaces need the
same explicit delta and owner attachment. Until these joins, tiny-engine
isolation, complete time origins and independent review are finished, #206
remains In progress and supplies no accepted capacity input.
