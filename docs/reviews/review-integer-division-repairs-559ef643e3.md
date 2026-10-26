# Review: division proof repairs

2026-10-26. Bounded independent static review; selected GPT-6 Astra at Extra
High. Runtime model/effort were not independently exposed. Inspection interval:
00:24:48–00:26:18 UTC (1 minute 30 seconds); written handoff and retained-summary
identity check completed at 00:27:01 UTC (2 minutes 13 seconds total).
Token and cost measurements are unavailable.

Exact range: `14b9302a9783d171ac37f1ccf7f75f0ace845ab6` through
`559ef643e3baff045af67b475a245b26a1386e21`, restricted to:

- `proof/Silver/ScalarsNativeSourceChecks.lean`, repair
  `92a3791e2233571be611616e9639cffe13c0a12a`;
- `src/silver_library_reports.adb`, repair
  `1d9bc08382d6e49efc6cd47175060121b9df1406`;
- `src/silver_library_reports.ads`, final policy-comment correction at `559ef643e3`.

The earlier core review at `16d0f0cfaa` and integration review at `14b9302a97`
are retained without repeating their scope. Additional inputs were
`docs/integer-division.md`, `tmp/native-map-repair.md`, relevant Map/Member
definitions and contracts, the prior integration review, the report ghost-erasure
boundary, `scripts/check_lean.py`, the direct Lean source/certificate/pin files,
and the focused native evidence below. Governing AGENTS/Oracle/development rules
were already read in the preceding bounded design thread.

## Verdict

**No findings in the reviewed repair scope.**

- **Lean statements and coverage are unchanged.** At
  `ScalarsNativeSourceChecks.lean:47,81`, the patch introduces each conjunct with
  `And.intro` and proves every resulting goal with the same `decide +kernel`.
  `ExpressionTranslation`, `Headers`, their complete helper lists, the checked
  precedence premise, `CheckedSource`, reviewed token shape and proof resource
  settings are unchanged. The edit adds no axiom, assumed equality, unfinished
  proof or kernel bypass. Successful elaboration remains pending.
- **The native induction bridge is correct.** At
  `silver_library_reports.adb:1797`, the new ghost `Rest` is precisely the suffix
  formerly passed directly to `Advance_Map`. `Read_Member`'s unchanged contract
  identifies `M` with `Member_Spec(..., P)`; the existing name assertion and
  preceding guard establish the matching name and `Name /= Unknown`. One
  unfolding of `Map_From(..., P)` therefore gives the asserted record, including
  the original field order, suffix uniqueness and remembered entity. The
  unchanged `Advance_Map` postcondition gives the second asserted equivalence.
  The subsequent `Seen` and `P` assignments then preserve the original invariant.
- **Contracts, executable policy and assumptions are unchanged.** No guard,
  return, state update, required entity set, coverage rule, pre/postcondition,
  loop invariant or variant was weakened. All inserted computation is
  `Ghost => Static` or a Static assertion, under the existing documented erasure
  policy. Both assertions create proved obligations rather than assumptions.
  `Mixed_Map_From` and `Mixed_Map` retain their correspondence endpoints.
  The `.ads` edit is comment-only and correctly adds nonzero-divisor checks to
  the already-reviewed policy description.
- **No direct Lean source pin is missing.** The report unit is absent from
  `check_lean.py`'s certificate `CANDIDATES` and from the Lean source/certificate
  and reviewed-shape bindings; a proof-tree search found no report-unit or
  Map_OK/Map_From model. Its changed bytes are nevertheless included by
  `capture_shared_inputs`'s complete `src/*.ads`/`src/*.adb` capture. Final complete
  evidence must identify those bytes; manufacturing an unrelated token pin is
  unnecessary. The changed Lean proof uses the same scalar source certificate.

## Retained native evidence and limits

Inspected managed run `20261026T002009-46b35fbc8582`, including its `events.jsonl`,
`native.log`, and retained `exploratory-evidence/0/explore/map-repair/gnatprove/`
summary. Its run directory is under
`.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs/`. Also inspected root scratch
`tmp/map-repair-native/probe.gpr`, `focused-correct-selector.log`, and
`obj/explore/map-repair/gnatprove/gnatprove.out`.

The Linux x86_64 run selected `Map_OK` at line 1749, with the unchanged
`--mode=all --report=all --warnings=error --checks-as-errors=on --level=2
--prover=cvc5,z3,altergo --timeout=30`, and two workers. The project references
the canonical division source directory. It finished successfully in 189.154
seconds, proving all 39 checks: 4 flow and 35 prover checks, with no unproved or
justified checks. The log explicitly proves both new assertions at 1803 and
1808, invariant preservation at 1766 and the unchanged postcondition at 1752.
The summary reports no pragma Assume statements. The earlier incorrect selector
generated no checks and is not counted as successful proof evidence.

The captured report-body SHA-256 exactly matches the reviewed target:
`d6aed420059a23a962dcd52cade14bb079b0e68544008346e26d14ff467d4150`.
The captured `.ads` hash precedes the final comment-only change and therefore
differs from HEAD. This is successful focused evidence for the repaired body,
not complete evidence for every final input.

No native/Lean/test/build runner, commit, GitHub write or subdelegation was
performed by this reviewer. `git diff --check` passes for the reviewed files.
The original full native run still has the known failure on the unrepaired
Map_OK, and the repaired Lean target has not yet been checked while the original
long source audit is retained. Complete native coverage/provenance, final build,
and complete Lean/source/axiom validation on the final inputs remain required.
This review does not claim those checkpoints succeeded or close division delivery.
