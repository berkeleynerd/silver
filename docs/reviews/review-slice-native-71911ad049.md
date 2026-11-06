# B1/B2 independent native prototype review — 2026-11-05

**Result: PASS for the reviewed native prototype.** No concrete scanner bypass,
admission-rule mismatch or B1 bound defect was identified. This result does not
claim the unfinished native proof, Lean/source correspondence, documentation,
certificate or final resource checkpoint has passed.

## Identity, authorization and scope

- Reviewer: independent subthread `/root/assess_inherited_blockers`.
- Selected model/effort: GPT-6 Astra, Extra High. Runtime settings were not
  independently exposed; no runtime confirmation is claimed.
- Review interval: 2026-11-05 09:18:11–09:27:15 UTC, 544 seconds to the recorded
  clock checkpoint at report finalization. No token or cost measurements were
  available.
- Owner authorization: the lead assigned implementation review within the
  authorized interim-review repair round; PR #307 remains open.
- Exact reviewed commit: `71911ad04995842720a1e60dae50a3ac94e76544` in
  `/home/canto/src/github.com/berkeleynerd/silver/tmp/string-admission-repairs`.
- Exact changed files: `src/silver_output_profile.adb` and
  `tests/test_string_review_blockers.py` as committed at that revision. Review
  used `git show`, excluding concurrent uncommitted Lean work. Native source
  still matched that revision at the final check. Commit diff whitespace check
  passed.
- Additional read-only inputs: original B1/B2 report, existing lexical/scalar/
  String composition code, shared compile/audit/execute test helper, retained
  managed native test logs, and pinned GCC condition-tracking sources already
  retained in the separate B5 worktree.

Only this report was written by the reviewer. I requested one focused native
composition probe from the implementation worker, who coordinated and executed
it after its active Lean run. I ran no builds or proofs. The additional probe's
uncommitted test is distinguished below from the exact reviewed commit.

## B1: bounded inverted endpoint span

`silver_output_profile.adb:748–749` computes the subtraction after converting
both operands to `Scalars.Wide`. This avoids overflowing the checker itself.
For any represented endpoint values `l` and `u`, interval containment gives
`l-u <= Low.Bounds.Upper-High.Bounds.Lower <= Integer'Last`. The rejection sits
outside the existing always-null/potentially-nonnull split, so neither branch
can bypass it. Static literal endpoints receive the same restriction.

All originally reported equality-wrap triggers have inverted differences
greater than this bound. The rule is deliberately stronger than the sharp
4096-based threshold; this is an explicit conservative frontend restriction,
not an assertion that every excluded Ada source is erroneous. Existing
nonnull containment and maximum-length checks are unchanged.

Copies retain the checked source bounds. When concatenation returns a null
operand, it inherits that operand's checked bounds; when the result is
nonempty, its bounds follow the existing bounded-length rule. Literal and
normalized input bases do not create the extreme null gap. Ordinary object
assignment preserves the target's established bounds. I found no route in
these reviewed composition rules that creates the reported extreme gap after
the slice check. The committed native control exercises the admitted boundary
`L=2147483647, R=0`, copy, empty-left concatenation, equality and concatenation
with a nonempty suffix. It returned `NE` and `ok` through the full route.

## B2: token-context restriction

The implementation is the intentionally broad rule supplied for this review:
nonstatic slice endpoints are excluded throughout an unfinished source `if`
statement, including conditions and every arm; they are also excluded after
any `and`, `or` or `xor` token since the preceding statement/declaration
semicolon. This is broader than detecting only contradictory guards, and its
eventual language/catalogue description must say so explicitly.

The scanner at `silver_output_profile.adb:640–680` agrees with that rule on
valid admitted source:

- Whole identifiers are recognized before keyword tests, with case-insensitive
  equality. Keyword substrings in names cannot alter state.
- Existing trivia skipping handles comments and admitted CR/LF terminators.
  The `Ending` flag survives intervening trivia, so `end -- comment` followed
  by `if` closes the correct nesting level.
- String literals, including doubled quotes, and one-byte Character literals
  are skipped as units. Their keywords and semicolons cannot change nesting or
  clear the Boolean suffix.
- `elsif` and `else` remain under the original unfinished `if`. `end loop`
  does not reduce the conditional depth. A completed `end if;` restores the
  outer depth and clears the Boolean suffix at the actual semicolon.
- Both endpoint staticness flags are required. Existing scalar parsing keeps
  nonstatic snapshots, loop indexes and array reads nonstatic; identity
  arithmetic cannot manufacture Ada-static status merely by having a singleton
  interval. The check precedes returning any admitted slice value.

Each recursive step advances past a token/literal or one punctuation byte,
and the terminal check prevents stepping beyond the source/limit. I found no
valid-source lexical bypass. This static review does not replace the pending
SPARK termination/safety proof or a source-linked model of the scanner.

The retained pinned `Get_Current_Value_Condition` implementation restricts
facts to the enclosing IF/ELSIF or WHILE context and refuses facts when the
reference is outside that context. WHILE is not admitted here. The Boolean
suffix rule conservatively includes later operands that can become generated
conditional code. It intentionally also rejects some safe eager/closed
Boolean-expression compositions. No driver flags, source rewriting,
SPARK diagnostics or proof-policy relaxations were introduced.

I challenged one potential gap: a static guarded slice on a prefix created
earlier from a nonstatic endpoint. The worker tested
`S := Base(1..K)` followed by `if K=0 then ... S(1..2) ...`, together with an
intermediate copy and `S&""` concatenation. All three passed same-source proof,
native compilation, independent report auditing and execution. This resolves
the concrete probe, while remaining sampled evidence rather than a universal
frontend theorem.

## Evidence read and integration limits

| Managed run | Inspected result |
| --- | --- |
| `20261105T091243-b5a7a4df6c66` | All three committed admission test methods passed; 1.482 s unittest time |
| `20261105T091257-872ab4f8f1d1` | Both committed full-route controls passed; 22.834 s unittest time |
| `20261105T091557-bb46fc30852d` | All 59 sample sources admitted; admission evidence only |
| `20261105T092208-199d8a5e715c` | Requested prefix-snapshot/copy/concat probe method passed all three subcases; 35.813 s unittest time |

The last run uses an additional test method added after the reviewed commit;
native compiler source remained exactly `71911ad049`. Its source and assertions
were inspected separately. The worker also accepted suggestions for cheap
lexical regressions involving keyword-bearing names, doubled quotes, literal
semicolons and comments between `end` and `if`; those future additions/results
are not claimed by this report.

These tests cover the reported null/length/concatenation failures, reversed and
rewritten guards, nonstatic constants, counted/foreach indexes, array-derived
thresholds, Boolean initializer/assignment suffixes, reset behavior and retained
static endpoint controls. They are appropriate focused support for the selected
restriction. They do not establish a universal absence of unrelated frontend
failures, and B3 is explicitly separate and unimplemented in this snapshot.

Proceed with the assigned matching Lean/source work and final integration.
Required remaining work includes proving the actual scanner/model connection,
the strengthened B1 composition property, native verification, explicit
language/catalogue changes, certificates and the integrated checkpoint. The new
recursive scanner also belongs in the planned final stack assessment, including
a nonstatic slice late in a deeply nested admitted source. None of those
already-assigned obligations is reported here as an unexpected defect or as
completed evidence.
