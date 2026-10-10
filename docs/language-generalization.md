# Generalizing Silver's current features

Assessment on 2026-10-10 against implementation `d630229`, requested alongside
the next [roadmap item](../roadmap.md#input-dependent-branching). This is planning:
the seven productions in [language.md](../language.md) remain the complete
admitted language. No proposed example below has been implemented or validated.
The Oracle is unchanged.

## Recommendation

Several restrictions can usefully become composition rules. After the selected
input-dependent branching increment, prioritize **bounded String expressions in
existing output positions**, then **a fixed-length result selected by a branch
and printed once**. These make existing features work together without first
admitting arbitrary Ada statements, a general parser or a new string library.

Literals already admit arbitrary printable ASCII contents, empty strings and
doubled quotes. Names, case-insensitive binding, comments and whitespace already
vary under explicit rules. The checked-in sample texts are not special cases.
The main opportunity is broader composition, not more literal or naming examples.

The selected branching item can reuse the typed conditional interpreter in
[GuardedMain](../proof/Silver/GuardedMain.lean), but still needs String equality,
the new grammar and an input-dependent meaning in
[Current](../proof/Silver/Current.lean), connected to the actual source. That
does not require implementing the expression generalization first.

| Area | Useful generalization | Cost or reason to limit it | Recommendation |
| --- | --- | --- | --- |
| String output expressions | Literals, an existing bound name and flat `&` chains; include variables after assignment and repeated statically sized names | Explicit length accounting, intermediate Ada bounds and expanded source correspondence; new Main checks may appear | Best first follow-up to branching |
| Capacity guards | Permit an application-selected capacity no greater than the safe residual capacity | A smaller bound deliberately rejects more input, including possibly a long default; specified behavior must reflect it | Assess alongside dynamic expression rules |
| Conditional branches | Reuse the same admitted output expressions in either branch | Every path must retain its required validity/length facts and terminal effect | Compose once both capabilities are established |
| Fixed-length assignment | Assign equal-length values in either branch, then print the result once | Requires immutable input plus a distinct initialized result, binding and branch-join proofs | Best later behavior-oriented increment |
| More declarations and copies | Several initialized bindings; copies whose lengths match the target | Case-insensitive uniqueness, declaration order, mutability and per-object length tracking | Add when a concrete data-flow program needs them |
| Repeated assignments | A finite sequence preserving one object's fixed length | Repeated literal overwrites are unobservable before one final print; more dead-store diagnostics | Feasible but low priority alone |
| Repeated output | Multiple lines with a documented complete-program effect | Calls continue after a returning failure; per-call observations do not describe cumulative output | Separate later capability |
| More argv operations | Multiple positional inputs or other interpretations | New API domains, indexing, validity/failure rules and runtime correspondence | Defer until an application needs them |

## First follow-up: bounded output expressions

A small proposed grammar is:

```text
expression := operand { "&" operand }
operand    := string_literal | bound_string_name
```

Use it in the output positions of supported compositions, including conditional
leaves once branching is supported. Initially retain their existing declaration
and statement order. A nonempty operand sequence follows Ada's left association;
arbitrary parentheses, calls, indexing and conversions need not arrive with it.
For example, output following the current equal-length assignment could use:

```ada
Silver_IO.Put_Line ("Hello, " & Message & "!");
Silver_IO.Put_Line (Message & ": " & Message);
```

These are two **alternative proposed output statements**, not an admitted
two-call sequence. One expression rule covers absent decorations, literal-only
concatenation, variable output and repeated statically sized names. It avoids
adding an independently named whole-program template for every combination.

Infer each literal's decoded length and each literal-backed object's fixed
length, then sum operand lengths **with multiplicity**. Require the result to
fit the 4096-byte output domain and prove all intermediate operations safe.
Repeated names invalidate the existing shortcut that distinct source literal
spans bound the whole result. A short source referencing a 3000-byte value twice
can request more than 4096 output bytes. Do not rely on the output wrapper's
failure guard to make such a statically oversized expression a successful
admitted-output case.

For dynamic argv input, begin with one dynamic reference per expression and the
existing executable validity/capacity guards. Let `L` be the total length of its
literal decorations; a permitted capacity `C` must satisfy `C + L <= 4096`.
The current rule requires equality. Allowing smaller `C` would support a useful
limit such as 80 characters while preserving safety; the program's explicit
guard, including its rejection of an over-capacity default, determines behavior.
Use each branch's actual decorations when establishing its required capacity.
Check each terminal branch independently; one execution selects one output, so
its bound need not include the lengths of unexecuted branches. The current
[default-fits-capacity theorem](../proof/Silver/GuardedSemantics.lean) depends on
exact residual capacity. A tighter guard therefore needs the changed default
behavior above, or a separate admission condition requiring the default to fit.

Repeated dynamic references are a later extension. For `k` occurrences of the
same argument, the relevant bound is `k * length + L <= 4096`; a source-checked
constant guard could use `floor((4096 - L) / k)` when `k > 0` and `L <= 4096`.
This arithmetic describes a possible admission rule, not newly admitted Ada
arithmetic or a reason to evaluate an overflowing product before checking it.
Retain the verified one-based argument result and account for empty operands
and every intermediate String result. Multiple independent dynamic values need
a different combined bound.

There is useful existing theory in
[ConcatSemantics](../proof/Silver/ConcatSemantics.lean),
[AssignmentSemantics](../proof/Silver/AssignmentSemantics.lean) and
[GuardedObligations](../proof/Silver/GuardedObligations.lean). Their current
grammars, event shapes, source renderings and complete-program theorems still
target particular productions; a general-looking expression datatype alone
does not prove the broader language. This is a capability increment with real
proof work, not a recognizer-only relaxation.

## Later: compute a fixed-length result, then render it

The existing assignment rule can generalize from one literal replacement to
compatible expressions and control flow. A useful motivating body is:

```ada
-- Proposed: Command is immutable argv input; Result is an initialized
-- seven-character String variable. Neither declaration pattern nor this
-- composition is currently admitted.
if Silver_Arguments.Input_Is_Valid then
   if Command = "start" then
      Result := "started";
   else
      Result := "unknown";
   end if;
   Silver_IO.Put_Line ("State: " & Result);
else
   Silver_Arguments.Reject;
end if;
```

Both assignments preserve the result's fixed length. The join before output
must establish its initialization, length and selected bytes on either path.
This combines one immutable dynamic input with fixed mutable storage; changing
the length of an argv-initialized String is not a substitute. Ordinary Ada fixes
that object's bounds at initialization too.

General assignment compatibility can use the same length judgment as output:
the right-hand expression must equal the target's fixed length. But adding
arbitrary assignment chains before any observable use provides little benefit.
With only one variable, length-preserving self-concatenation is also very
restricted. Add extra bindings or statement sequencing to serve actual data
flow, with explicit name resolution and state semantics, rather than bundling
all variations into the first expression increment.

## Repeated I/O has a distinct effect contract

The actual [Put_Line body](../src/silver_io.adb) sets exit status 1 and returns
on a detected failure. A later successful call **does not reset that status**.
There is no established bug in the current terminal-call behavior.

Allowing a following call would nevertheless attempt more output. The wrapper's
Static byte transcript and success flag reset at each invocation, while
[OutputRuntime.completeMain](../proof/Silver/OutputRuntime.lean) currently
interprets one terminal call. Multiple calls need a cumulative trace and process
status argument, plus an explicit choice between continuing attempts and
stopping after the first failure. Successful later bytes after a failed earlier
line need not be a prefix of the complete intended output. Per-call bounds also
do not bound the total output when values can be reused. The
[trusted boundary](trusted-boundary.md#literal-output-boundary) already identifies
this composition obligation. Repeated I/O is useful but should have its own
multiline application and complete effect specification.

## Proof and implementation scope

Keep membership decidable from the actual source, independently of prover
success. Begin each authorized capability with native obligation experiments,
then establish universal semantics, automatic-discharge arguments and actual
source correspondence. Exercise maximum permitted expression/statement sizes;
finite source size alone does not establish external solver completion or that
the complete proof report fits the compiler's report buffer.

The current [assignment report policy](../src/silver_library_reports.adb)
requires empty safety-proof lists and at most one precisely classified
initializer advisory in its warning-bearing form. Mutable concatenation or
additional stores may generate different checks or diagnostics. Inspect and
model them explicitly; neither reusing a previous report policy blindly nor
accepting all warnings is justified. The existing compiler routes those modes
separately in [silver.adb](../src/silver.adb).

No new trusted dependency or Oracle amendment is indicated by these candidates.
Do not make parser replacement, certificate redesign or source partitioning a
prerequisite. Reuse small proof/recognizer components where the authorized
capability needs them, keeping specification and implementation arguments
independent. Retain the [proportionate validation cadence](../development.md#proof-loop-and-validation),
including complete local assurance at a capability checkpoint.

This assessment used source/document inspection and three focused reviews of
native behavior, proof reuse and development priorities. No native probes,
proof replay or benchmark was run, and no broader admission rule was installed.
