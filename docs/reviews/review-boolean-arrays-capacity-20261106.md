# Boolean-array producer and report-capacity review

**No blocking finding in the capacity extension.** Under the inherited pinned
producer/frontend, check-identity grouping and retained-report projection
assumptions, Boolean components preserve the accepted Main obligation and
advisory classes and the **31,822,336-byte** envelope. The 32 MiB allocation
retains **1,732,096 bytes** of headroom. This is a source-derived capacity
conclusion, not feature approval or proof of automatic discharge.

This independent read-only review answers the bounded #297 question requested
by the lead. The target was the draft `docs/boolean-arrays-report-capacity.md`
and relevant native admission code in
`/home/canto/src/github.com/berkeleynerd/silver/tmp/boolean-arrays`.
Observed HEAD was `12811ed4a06375ae878b4906003d67bbc2447e4c`;
exact file identities below govern the review because the checkout had
uncommitted documentation/proof/test changes. Native source was held fixed.

## Findings and challenged cases

1. **Component and aggregate checks.** In pinned `gnat2why-expr.adb`, indexed
   reads at 14042–14089 and stores at 14287–14349 transform the sole index once
   and insert at most one index check. A store's final component conversion is
   simple. Aggregate collection at 16273–16600 maps each explicit component
   once; function translation at 15743–15843 evaluates each mapped argument
   once. The defining proposition reuses mapped values (17580–17650), so it
   does not create another executable traversal of each Boolean initializer.
   The predefined Boolean scalar conversion returns unchanged at
   `why-gen-expr.adb:2425–2439`, even with a check flag. No constrained Boolean
   subtype, predicate or relaxed-initialization wrapper is admitted. The
   aggregate root retains at most the existing constrained-target length
   check; static bounds and exact static singleton choices add no new root
   class. Positional signed-Integer indices without `others` and the
   one-dimensional shape exclude the additional choice/matching-bound routes.

2. **Embedded comparisons and disjoint bytes.** The draft correctly qualifies
   the old Integer-only statement that component values contain no comparisons.
   Boolean components need no conversion-record reservation, leaving their
   embedded comparisons free to use the inherited two-byte charge. For nested
   Boolean equality, a concrete disjoint assignment is: reserve both operator
   bytes when present; otherwise reserve the one operator byte and one token
   byte from the leftmost leaf of its right operand subtree. Distinct binary
   comparison nodes have distinct such leaf positions. Indexed-read and slice
   parentheses, declaration/store `:=`, and Integer component value/separator
   pairs remain separate. Integer component expressions contain no comparisons.
   The independent arithmetic and implicit element-reference buckets may
   overlap these reservations deliberately; they are conservative additions.

3. **Eager Boolean operations and xor.** A Boolean *cell* has scalar Boolean
   type, so 24501–24626 selects scalar `not`/`and`/`or`/`xor`, not whole-array
   logical operations. Equality/inequality at 21817–21837 and 21942–21966 uses
   each operand once. Xor copies already translated operand ASTs at
   `why-gen-expr.adb:5391–5424`; it can duplicate proof tasks, including an index
   task, but does not register another source check. `gnat_checks.ml:175–225`
   groups goals by check identity; 453–465 and 598–660 require the safety
   check's remaining goals to finish successfully. `gnat_report.ml:59–85,204–208`
   stores/emits one result per check. Existing projection removes the validated
   raw `check_tree`; raw formula/tree size is not this allocation. The native
   xor-operand restriction remains enforced for these conditions. No task is
   waived by this record-count argument.

4. **Frontend and retained metadata.** Exact pinned frontend `expander.adb`
   105–125 selects light SPARK expansion. `exp_spark.adb:549–595,919–946`
   introduces neither container-aggregate wrapping nor absent-initializer DIC
   calls for this syntax. `sem_ch3.adb:6724–6750,19097–19104` creates the same
   anonymous array type/subtype shapes as the Integer feature. Predefined
   Boolean components trigger none of `gnat2why-types.adb:1108–1141` or
   `spark_definition.adb:2313–2389`'s special type-VC/coverage cases. Why
   aggregate helpers are not new Ada callees; the dependency gate at
   `gnat2why-driver.adb:1086–1116` is unchanged. Existing library calls inside
   admitted conditions retain their existing callee/accounting rules. No new
   entity, coverage, timing, dependency, safety-rule or advisory class follows.
   The inherited maximum of two Image warning traversals per textual Image
   remains sufficient: the aggregate definition uses mapped component values,
   while a constant defining axiom can supply the inherited extra term traversal.

5. **Loop initialization warnings.** The warning route at
   `flow-control_flow_graph.adb:3648–3665,4015–4032` withholds a
   `Fully_Initialized` fact; it does not replace initialization checks. Boolean
   arrays still require explicit initialization before body execution. The
   recursive traversal at 4040–4117 visits an indexed write once per enclosing
   loop analysis; the three call sites are mutually exclusive. Thus repeated
   notes require the existing `L*W` bound. The 24-byte loop and eight-byte write
   lower bounds remain conservative for Boolean writes and existing Integer
   element loops. No new array-out-parameter route or Boolean element-loop
   syntax is admitted. The exact fixed warning schema occupies 430 bytes with
   Natural-width positions, within its 512-byte allowance.

## Independent accounting

For `S = 4096`, the inherited allowances give:

```text
checks = S//2 + 3*63 + S//7 + 3*(S//15) + S//2 = 5,689
notes  <= floor(S*S/(4*24*8)) = 21,845
```

The loop bound follows from `24*L + 8*W <= S` and
`4*(24*L)*(8*W) <= S*S`. Integer maximization of this relaxed source constraint
also gives 21,845 at `(L,W)=(85,257)`; the required source shell only reduces it.

| Retained allowance | Bytes |
| --- | ---: |
| Safety records: `5,689 * 2,048` | 11,651,072 |
| Ordinary flow and Image: `(2*S + 2*(S//16))*1,024` | 8,912,896 |
| Initializer-name payload | 8,192 |
| Fixed metadata | 65,536 |
| Nested-loop notes: `21,845 * 512` | 11,184,640 |
| Total | **31,822,336** |

The inherited record schemas and their executable capacity guard were inspected;
no test runner was invoked. The new checks retain existing index and scalar
success schemas. Boolean declarations/writes are no shorter than the existing
source minima; Integer/Boolean arrays share the descriptor and initialized-cell
tables. [arithmetic.json](../evidence/boolean-arrays-20261106/capacity-review/arithmetic.json) records the independent integer and
warning-schema calculation.

## Findings disposition and limits

- **Material defects:** none found in this bounded producer/capacity extension.
- **Missing corroboration:** no current Boolean-array producer probe results
  were supplied or claimed. Prepared probes remain to be run by the native
  lease owner. Retain that pending status; prior scalar/Integer observations
  are not current Boolean-array results.
- **Optional clarification:** add the concrete nested-comparison byte mapping
  and explicit frontend citations above to the draft if helpful. They clarify
  an already valid count and require no allocation or admission change.

No native build, GNATprove, Lean or test run was launched. This review does not
establish universal automatic discharge, full feature correctness, or actual
source/model correspondence. Every required native/Lean/source obligation and
all copied proof tasks remain required. It makes no binary-attestation claim,
raw-report-size bound, universal solver-time bound or measured-memory claim.

## Input identities and review record

[inputs.json](../evidence/boolean-arrays-20261106/capacity-review/inputs.json) contains absolute paths, byte counts and SHA-256 for
all governing/accounts/native/test-schema inputs consulted and all producer and
frontend files inspected. Its SHA-256 is
`15def71e774927bad214a0c1ae1bd0ce9dc402cb3bc69e18fc2b0d81a589559d`. All nine producer files match the provided retained
inventory at SPARK `42554fc241fcd1fdf08d3a2feccb3f86912acbc0` and Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`. Frontend revision is
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; the newly retrieved `exp_spark.adb`
and `expander.adb` match the inherited hashes. All inventoried bytes were
rechecked unchanged before this report was written.

| Key reviewed input | SHA-256 |
| --- | --- |
| Boolean-array capacity draft | `225a9430fd641c8f6b79eaba576c20212aaeba4e69244ddf768717a9dc50a684` |
| `language.md` | `b2808bcc4274f22778316c2f844f3db7b20370b75607719d1b708f7496ee792f` |
| `src/silver_output_profile.adb` | `6d68761cd1ebc82d81f694b198513b4896754baa7bb628066590498b7a79f50c` |
| `src/silver_array_bindings.ads` | `39ee0b705e340923abacd4d5d49667d8c4b08568cdede75c23ee4e13b473baf9` |

Selected reviewer settings: **GPT-6 Astra / Extra High**, confirmed from the
lead's explicit spawn configuration (`gpt-6-astra`, `xhigh`). Runtime model and
effort are not independently exposed/confirmed. Review started
**2026-11-06 19:09:06 UTC**, ended **2026-11-06 19:13:59 UTC**;
elapsed **293 seconds** including report preparation.
Token/cost measurements are unavailable. Host: Linux x86_64. No repository,
GitHub, native workspace or CLI-memory mutation was performed; only the allowed
scratch/report directory was written.
