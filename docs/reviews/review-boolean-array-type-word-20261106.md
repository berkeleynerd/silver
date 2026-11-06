# Boolean type-word repair: bounded independent review

**Verdict: static review passes; no required code correction found.** This
approves the bounded repair and its matching pin/certificate integration, not
completion of #297 assurance. Complete native/Lean validation remains outstanding.

Reviewed on 2026-11-06, 22:54:14–22:58:16 UTC (242 seconds through the final
pin comparison, including initial report preparation). Reviewer setting selected by the lead:
**GPT-6 Astra, Extra High**. Independent runtime confirmation of that setting
and token/cost measurements were unavailable. No proof/build job was launched
by this reviewer; existing evidence was inspected. The live harness goal was
absent. Authorization is the owner's #297 Boolean-array work, active draft
PR #335, as supplied by the lead; no Oracle amendment is proposed.

Exact review targets:

- Native commit `b47bee6f2b03702fa6766bb8ec2014d9b9503341`, against parent
  `25e6fe06a3f4b2029c1c7a860c379fa47d290c9d`.
- Lean commit `5d0ff14bc7a5acf634af317a3a3d72f99ecf40d4`, against parent
  `b6ae02b78b6a58446c0cba75d972e7769e23d1a7`; the complete four-file diff.
- Native validation commit `780efdeebf54b85de863bf79ec0dabedaff4db19`.
  Its `src/silver_output_profile.adb` is byte-identical to the native target:
  SHA-256 `1686b0b61da8c684ce185995621fb08bc5a6932893d2cc859a82ced9922ce4e8`.
- Integrated Lean commit `27fcd2e77b2b45dd61521de74d81440f093087d9`, followed by
  pin/certificate commit `1b7140d90ba2e34e9ed7b5e058fd53aab31b49c6`.

The applicable Oracle requirements are unchanged behavior, complete obligation
discharge, and correspondence to authoritative Ada/SPARK. I read repository
`AGENTS.md` (including the worktree variation), `oracle.md`, the relevant
validation/review sections of `development.md`, the array/source-correspondence
sections of `docs/assurance.md`, and the trusted-boundary/agent-reporting guidance.

Scoped findings:

1. **Runtime and name resolution are preserved.** The native diff adds only
   `Boolean_Type_Word : constant String := "boolean"` and replaces the same
   literal in the model and executable declaration rejection tests
   ([native source, lines 1801, 1839 and 2133](https://github.com/berkeleynerd/silver/blob/b47bee6f2b03702fa6766bb8ec2014d9b9503341/src/silver_output_profile.adb#L1801)).
   The package-level constant has the same `String` type, lower bound 1,
   length 7 and characters as the contextual literal; neither use is shadowed.
   `Name_Is` compares length and case-folded source characters, so its result
   and existing preconditions are unchanged
   ([definition](https://github.com/berkeleynerd/silver/blob/b47bee6f2b03702fa6766bb8ec2014d9b9503341/src/silver_output_lexical.ads#L134)).
   Source-language hiding tests and short-circuit order are untouched.

2. **The Lean constant is semantically complete for this use.**
   `booleanTypeWord : Expr .spelling` renders `boolean_type_word`, evaluates
   to `"boolean"`, is primary/well-formed/scoped, and has the matching legal
   and lexical-evaluation cases. It follows the existing Integer constant
   route; the precedence fallback functions retain its primary status.
   Both executable/model trees share the replacement in
   [ComposeArrayExpressions.lean:167](https://github.com/berkeleynerd/silver/blob/5d0ff14bc7a5acf634af317a3a3d72f99ecf40d4/proof/Silver/ComposeArrayExpressions.lean#L167).
   Their evaluations are unchanged by reduction. Existing array scope and
   precedence checks cover both trees.

3. **The added correspondence requirement is substantive.**
   [ArrayHelperTranslationFor](https://github.com/berkeleynerd/silver/blob/5d0ff14bc7a5acf634af317a3a3d72f99ecf40d4/proof/Silver/ComposeHelperSourceCandidate.lean#L25)
   now requires the unique declaration to be exactly
   `constant string := "boolean"`, alongside exact model and ordinary-wrapper
   bodies and unchanged contracts. Its kernel decision feeds the existing
   [authoritative transport](https://github.com/berkeleynerd/silver/blob/5d0ff14bc7a5acf634af317a3a3d72f99ecf40d4/proof/Silver/ComposeSourceChecks.lean#L36)
   and `CheckedSource.arrayHelpers`. `Source.declaration` rejects duplicate
   matches. The complete-shape premise remains required; this introduces no
   assumed source equality, axiom, or pin-only bypass.

4. **The original refinement obligation remains.** The exact
   `Same_Parser_State` assertion, equality lemma call and model-equality
   postcondition remain in Ada, and the ordinary-wrapper render still checks
   their tokens
   ([wrapper](https://github.com/berkeleynerd/silver/blob/5d0ff14bc7a5acf634af317a3a3d72f99ecf40d4/proof/Silver/ComposeArrayDeclarationSource.lean#L20)).
   Neither commit weakens domains, contracts, assertions or proof options.

Retained Linux evidence: inspected managed run
`20261106T224718-9374c3fb5301`, its captured source hash, command, final event,
native log and [focused result](../evidence/boolean-arrays-20261106/shared-type-word/focused-assertion-result.json).
It succeeded in 45.32789313 seconds; the log reports three checks proved and
the original assertion at `silver_output_profile.adb:2179:32` proved. The
selected scope was that line/subprogram, with level 2, 30 seconds, 1000 MiB,
the normal three-prover portfolio and four workers. Z3 discharged the assertion;
the other recorded attempts were signaled. This is focused, cache-enabled
evidence, not a full native audit. Both commit whitespace checks passed.

The initially missing pin was integrated during review at `1b7140d90b`.
I independently confirmed that its native body is byte-identical to the native
review target and all four Lean files are byte-identical to `5d0ff14bc7`.
The old reviewed pin equals the generator's tokenization of the old native
body, and the new pin equals its tokenization of the exact one-declaration,
two-use repair: 53,290 → 53,297 tokens. Independently regenerating in memory
reproduced the committed reconstruction certificate and all eight line modules
exactly, without writing implementation files. The only changed line modules
are 0, 1 and 6: one new constant, one shared replacement line used twice, and
removal of its former literal-bearing line. The generator is unchanged by the
pin commit. This confirms bounded generation correspondence; it is not Lean
kernel validation of the generated proofs.

**Remaining obligation:** complete the already pending broader native/model
checks and authoritative source/axiom audit on the integrated inputs. No
additional semantic repair or Oracle change is indicated by this bounded review.
