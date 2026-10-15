# Rosetta corrections from review-343c2f8

The owner authorized L8/#25, L9/#26, L10/#27 and L11/#28 repairs before further
feature work, recorded on `main` in
[`618c28a77c`](https://github.com/berkeleynerd/silver/commit/618c28a77cdf011f338a31fcb0e9022743a338de).
This is a targeted source review of the retained task revisions, not a new
corpus-wide model run or evidence that proposed programs prove automatically.
No new construct is marked supported.

## Faithful samples and selected scope

Colour bars/Display revision 415034 requires actual colour bars. Its former
labelled-character output did not meet that requirement. The replacement plan
writes a fixed PPM image containing black, red, green, blue, magenta, cyan, yellow
and white bars. It needs future file output with specified failure outcomes;
its fixed RGB strings and bounded loops do not need integer arithmetic. The
file-output progression stage retains this candidate.

The owner settled #34 in
[`39d0ad38e6`](https://github.com/berkeleynerd/silver/commit/39d0ad38e6): the next
milestone includes standard Integer `'Image` with the leading space. Loops/For
with a specified step revision 412896 now motivates constant declarations and
grouped multiplication together: print `Integer'Image ((I * Step))` for
`Step = 2` and `I` from 1 through 5. Loops/Downward for revision 412893 prints
`Integer'Image (I)` for `reverse 0 .. 10`; its former trimming and subtype
requirements were unnecessary. Nested Loops/For remains the loop-composition
driver. The [scope record](../docs/for-loops-integers.md) sets completion criteria.

Re-rendering places for loops in stage 2, integers/ranged subtypes/scalar images
in stage 3, procedures in stage 4 and arrays in stage 5. The selected milestone
covers an immutable Integer/Image fragment and stage 2, not all of stage 3.
The roadmap and stage issues preserve the remaining work.

## SPARK exception and goto rules

The pinned [SPARK 16.1 exception rules](../references/spark/16.1/docs/lrm/source/exceptions.rst)
permit exception declarations, handlers without a choice parameter, and
expected explicit raises. A local enclosing handler can make a raise expected;
propagation out of a program-defined subprogram requires `Exceptional_Cases`,
which Silver authors cannot supply. Raise expressions and unexpected raises
must be proved unreachable. Handlers do not discharge failed language-mandated
checks or failed contracts. The pinned
[statement rules](../references/spark/16.1/docs/lrm/source/statements.rst)
permit forward `goto` under their ordering restriction.

The rubric now distinguishes these rules from Silver's current scope.
`local-exceptions` is a planning construct explicitly excluded by current
coverage policy because its admission, initialization and path-fact composition
rules are not established. This is not a permanent Oracle conflict or admission
of handlers. Current `goto` scope likewise follows from missing control-flow
admission/composition rules, not an assertion that SPARK forbids every goto.

Targeted reassessments:

- **Exceptions**, revision 415544: declare, explicitly raise and locally handle
  one exception in Main. No author annotation or cross-call propagation is
  required. Excluded by current `local-exceptions` policy.
- **Search a list**, revision 411635: scan a constant bounded array in increasing
  order; print and return on the first match; otherwise explicitly raise and
  handle a declared exception within Main. The task requires a missing-needle
  exception but not a separate throwing function. Excluded by current
  `local-exceptions` policy, not an Oracle conflict.
- **Detect division by zero**, **Find limit of recursion** and **Integer
  overflow** retain their independent run-time-error conflicts; their redundant
  blanket handler claims are removed.
- **Exceptions/Catch an exception thrown in a nested call** retains the
  required unexpected exception outcome and now identifies cross-call
  propagation as an annotations conflict. **Rendezvous** retains its separate
  tasking conflict and identifies required propagation the same way.
- **Safe mode** and **Scope/Function names and labels** describe present Silver
  scope accurately instead of claiming a permanent SPARK prohibition.

The retained model attribution describes the original assessments. Entries
revised here carry a dated review reference and generated pages distinguish
that source review from the original model run.

## Deterministic rendering

Risk summaries count each obligation at most once per sample, then sort by
descending count and alphabetical obligation name before choosing the first
four. Equal counts and the four-item cutoff no longer depend on Python's hash
seed. `tests/test_rosetta.py` exercises duplicate risks and tied counts, and
runs the real render CLI against all retained assessments under seeds 1 and 2,
comparing every generated `silver.md`, `progression.md` and `rosetta.md`.

On Linux x86_64, `python3 scripts/dev.py test -- -p test_rosetta.py` passed both
tests (2.129 seconds): the two seeds produced identical bytes for all 1,784
generated Markdown outputs. `git diff --check` passed, and 6,828 local link
targets resolved in this worktree or the already published repair-authorization
commit. The root-owned capacity-correction anchor is checked at integration.
The [repair delivery record](../docs/review-343c2f8-repairs.md) and affected
issues identify the implementation and publication checkpoint. No compiler,
native proof or Lean result is claimed by these planning changes.
