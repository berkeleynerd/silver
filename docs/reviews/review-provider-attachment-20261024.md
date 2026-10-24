# Review: concat provider attachment and hereditary lower-one layout

**Repair required: one confirmed medium finding, F1 / [#218](https://github.com/berkeleynerd/silver/issues/218).**
Author `e363118b9343dbae72127411f9bc21cc199e2070` does not establish its claimed
hereditary **frontend-known literal lower 1** partition. The direct receiving
identity count and the native graph arithmetic do not repair that missing
source bridge. Do not integrate the hereditary layout/Length/query exports as
an accepted source-attached result yet. #201 and #119 remain open.

The accepted #217 correction remains intact: repair author
`df7c4491200dbb56642c56b28f9f8341189f967d`, independent review
`10a9004c0f6115fd26c574fc9ca13e903338ece2`, corrected original-layout
C184/U126/B138/T112, 22,288 raw bytes and 738 operand slots. This finding does
not dispute that conditional MAX/conversion allowance.

## Inputs, method and measurements

The exact target consists of twelve new provider-attachment files and the
research-note append; its seven earlier `repair*` files are immutable inputs.
The independent [receipt](../evidence/review-provider-attachment-20261024/current.json)
records every target file's SHA-256 and checks its bytes against the author
commit. It also binds the accepted original and #217 repair review blobs and
the unchanged repair files. The author receipt is reused as historical
evidence; neither it nor a predecessor checker was replayed.

Selected reviewer: **GPT-6 Astra / Extra High**. Runtime model/effort
confirmation, tokens and monetary cost are unavailable. First review clock:
2026-10-24 08:36:30 UTC. The successful focused audit completed on Linux x86_64
at 08:51:01.855672 UTC, taking **1.768407 seconds**; elapsed review time through
that audit was **871.855672 seconds**. Report preparation is additional wall
time. Native compiler/prover/Lean
execution time was zero; no generated matcher, native target or service ran.

I read the applicable agent/Oracle/review requirements, all new packet text
and data, the checker as text, the changed research note, the relevant accepted
transfers and the archived GCC source. The decisive missing sources were
retrieved at the same pinned GCC commit
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`: `sem_eval.adb` and `checks.adb`.
Their complete hashes match the existing retained manifest; the full sources
are preserved in this review's [evidence](../evidence/review-provider-attachment-20261024/README.md).
The new audit checks 31 complete source identities and 64 LF-delimited spans.
Its initial lexical assertion mistook `Attribute_First_Bit` for
`Attribute_First`; exact token boundaries fixed that audit-only false match
before the successful run. No successful check was replayed.
Its small stage model and arithmetic checks corroborate this source reading;
they are not compiler execution or a universal producer proof.

## F1 / #218: nullable concat loses frontend-known literal-one provenance

The target [README, lines 156–193](../evidence/retained-general-native-capacity-20261024/provider-attachment/README.md#3-hereditary-literal-lower-one-providers)
defines the recursive family using actual frontend-known literal lower 1,
then says nullable `IF(1,1)` contracts to 1, aliases preserve the property,
and every subsequent scalar event has `s=m=0`. Those statements conflate two
different compiler stages.

Consider the source-derived structural witness, with nonstatic mutable `I`
and the accepted Image provenance retained by `Saved`:

```ada
Saved : constant String := Integer'Image (I);
Inner : constant String := Saved & Saved;
Outer : constant String := Inner & "x";
```

This is a witness to the relevant expansion branches, not a report of running
the compiler or a complete admitted test program. The current String grammar
admits these expression/declaration forms; any surrounding admission and
runtime checks retain their existing obligations.

Both operands of `Inner` have dynamic length and literal lower 1. The source
does not use Image's semantic nonemptiness to clear `Result_May_Be_Null`.
`Get_Known_Bound` can choose 1 for this event, but `exp_ch4.adb:3273–3281`
subsequently constructs the lower bound

```
if G_inner = 0 then 1 else 1
```

The native fold of that expression is 1. The frontend does not establish the
same literal identity:

- `sem_eval.adb:2541–2553` makes `Eval_If_Expression` return unless the
  condition and both arms are static. The dynamic aggregate test fails that
  prerequisite. There is no equal-arm exception.
- `exp_ch4.adb:5944–5975` folds a condition known at compile time; it does not
  fold a dynamic condition merely because both scalar arms are equal. The
  ordinary no-actions case returns for gigi at `6629–6633`.
- `Compile_Time_Known_Value`, `sem_eval.adb:1812–1918`, handles literals and
  recursively known constant values, but has no `N_If_Expression` case. The
  surviving conditional therefore returns false. The relaxed range-bound
  Force_Evaluation path does not manufacture a literal either.

Consequently `Outer` cannot inherit the claimed actual literal bound through
the frontend fast path at `exp_ch4.adb:2968–2978`. It falls back to a First
attribute at `2984–2989`. Comparing that expression with the fixed operand's
literal 1 does not supply the claimed equality proof: an untyped expression
is rejected by `Compile_Time_Compare`; when typed, `Compare_Fixup` exposes the
conditional, and `Is_Same_Value` rejects its kind mismatch with the literal
(`sem_eval.adb:986–1072,1172–1182`). `Determine_Range` has neither an IF
refinement nor an Attribute_First/Last refinement (`checks.adb:5071–5650`),
so it does not restore a singleton-one result. Its base signed type range is
not the singleton needed by the equality branch.

The resulting `Get_Known_Bound` branch creates a selected-low IF at
`exp_ch4.adb:3194–3206`, then the selected-low constant M at `3215–3228`.
Thus a later event can have `s=1,m=1` even though its seed ancestry consisted
entirely of the claimed literal-one providers. Further aliases do not change
this frontend fact. Gigi may later fold M's initializer and inline a constant,
but that needs a source argument and construction accounting; readonly or
runtime equality alone does not establish either.

This breaks the stated hereditary induction premise and its unconditional
`s=m=0` scalar-event attachment. It also leaves the claimed native grammar's
attachment to this recursively defined source family unproved. It is not a
counterexample to the numerical graph formula for a tree already known to
have the asserted native grammar, and it is not evidence of a runtime bug.
The finite depth-128 graph checks start from that grammar; they cannot detect
the omitted frontend-to-native transition.

Required repair: establish the actual frontend/native bridge for the intended
recursive source family, including selected-low M, constant-declaration
substitution if relied upon, their source occurrences and all allocated or
discarded work. Reconcile the family definition, scalar charge, provenance
induction, static-max routing and exports with that bridge. Narrowing the
claim to individual events whose incoming lows are already frontend literals
would avoid this false induction but would leave the intended hereditary
continuation unfinished; it must not be presented as completing it.

## Static-max qualification and other reviewed checks

The same stage distinction matters before allocation-high replacement.
`exp_ch4.adb:3302` tests `Compile_Time_Known_Value(Low_Bound)` after constructing
the nullable low IF, and before gigi. A finite maximum from a direct Image's
fixed buffer is insufficient by itself to make a **nullable** event pass that
low-known gate. Direct Image can still take static replacement in a nonnullable
event, for example with a positive fixed operand such as
`"x" & Integer'Image(I)`. The earlier existential statement that direct Image
“can” take static replacement remains valid with this qualification. The
named `Saved & ""` original-allocation witness remains valid, and #217's
native correction is unchanged.

The independent source inspection supports the following separate results;
none is a substitute for F1's required bridge:

- Direct expansion events consume disjoint left-spine concat operators.
  `sum(n_e-1)<=C`, `E<=C`, `R<=E`, `M<=R` and `A<=sum_real n_e` give
  `R+M+A+D<=4C+D`. NN<=1 early returns precede saved-action insertion;
  the O0 runtime-call path zeroes NN and emits no assignment slices. There
  is no nine-operand admission cap. Natural Character/String assignment
  reaches the backend return before frontend copy-loop subtypes.
- Fresh range and slice sites produce one array and one signed index;
  ordinary completed-provider aliases can add one array while reusing the
  index through subtype-mark constraints or copied First_Index. This count
  concerns the direct constructors, not all gigi type/metadata variants.
- For the stated native spine, constant-other distribution follows only one
  recursive arm at each selector. W's wider-than-word pull-out uses plain
  builders and returns; provisional conversions/conditionals are retained
  in the cost. Repaired depth-zero MAX/conversion work must remain included.
  Signed Length can retain NON_LVALUE on declaration arms, unlike a terminal
  Image NOP view. Its maximum query must preserve the MAX-root fallback,
  and the first assignment high can expose W1's Length initializer.
- The coefficient arithmetic yields 22,288 layout bytes / 738 slots per
  `(t+1)`, 2,720 Length bytes per `(t+1)`, and 72,752 assignment layout plus
  annotation bytes. These are arithmetic/conditional native-grammar checks,
  not acceptance of the disputed source attachment.

One initially questioned coefficient does not itself require another finding.
The predecessor's literal count J is not operand count n. For an event that
really has `s=m=0`, however, its endpoint literals are only 0/1; aggregate
construction has another owner, and a fixed nullable final operand is empty.
`cuintp.cc:59–90,152–160` uses one constant request for each such supplied-type
literal, rather than the general thirteen-request allowance. Then
`J<=4+5r<=9<=13n` for every real event `n>=2`, so the displayed 520n literal
allowance remains conservative on that actual premise. F1 requires proving
or revising the premise; this observation does not extend it to events with M.

## Remaining boundary and handoff

Preserve `complete_native_capacity_result=false`. General input-low nesting,
executable/call/check construction, pointer/fat-pointer adaptation, global
metadata/type variants, shared/dynamic backing, incoming states and downstream
process joins remain open. The local layout and annotation counts are raw
caller requests, not a whole native-capacity result.

Fixed representable helper frames and finite traversal retain the physical-
stack premise. No cumulative compiler RAM/stack gate is introduced. Genuine
dynamic requests/backing, representability and generated-program frame/encoding
obligations remain. The e<=2, two save-entering callbacks and three saves remain
once per Why process. Oracle, admission, production and tool pins are unchanged.
This reviewer made no GitHub, goal, memory or publication writes; root owns
#218 disposition, author repair, integration and publication.
