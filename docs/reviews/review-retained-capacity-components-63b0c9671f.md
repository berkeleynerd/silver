# Review: retained capacity component checkpoint

2026-10-17, Linux x86_64. Independent focused review for
[#119](https://github.com/berkeleynerd/silver/issues/119), frozen integration
`63b0c9671f9322c03f961b6df410ba87330bc1e8`.

**No material finding within the reviewed components' stated domains.** Their
local bounds agree with the pinned source and retained arithmetic evidence.
This is not a review or completion of the whole capacity predicate. In particular,
the native concatenation report expressly leaves semantic/generated-action
closure open; this review preserves that qualification.

## Scope and checks

Reviewed these additions, without reopening the unchanged components covered by
the [earlier entity/producer review](review-retained-entity-producer-e00109d8a8.md):

- [Value capacity](../research/retained-value-capacity.md): normalized native
  Integer expansion, temporary scalar range inference, and the Main lexical and
  static String aggregate.
- [Main entities](../research/retained-frontend-entities.md): the new String-type
  induction under GNATprove light expansion.
- [Allocator capacity](../research/retained-table-capacity.md): exact generated
  node layout and Main physical-line/column additions.
- [Native concatenation](../research/retained-native-expansion.md): direct
  emitter bounds, the closed aggregate leaf-copy subset, local Uint work and
  the stated transitive exclusions.

The inspected GCC Ada source is
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Five outputs from the four relevant
evidence generators reproduced byte for byte. The independent checker verifies
27 directly reviewed files against the pinned complete-tree manifest, the eleven
layout-generator inputs and eleven retained generated outputs. It independently
parses the two generated size tables. No generator rebuild, compiler,
GNATprove, Lean, full-suite, macOS or CI run occurred. The correspondence between
inspected source and installed tools remains an explicit premise.

[Review evidence](../evidence/review-retained-capacity-components-63b0c9671f/results.json)
records hashes, reproduction outcomes and independent arithmetic discriminators.
Its adjacent `check.py` checks 240,100 endpoint/digit cases, 2,047 column
recurrences, seven concat-count instances and 216 concat-magnitude cases.
These are inexpensive mathematical corroboration; they do not prove caller
coverage or measure tool allocations. The target's existing value reproducer
also reran its bounded numeral/range discriminators. No large program probes
were made.

## Source conclusions

| Component | Reviewed argument and conclusion |
| --- | --- |
| Native scalar core | Strict overflow handling reaches the backend return before test-tree construction when the widening-parent case is excluded (`checks.adb:756–775,800–947`). Integer add/subtract simplifications rewrite once; multiplication by zero adds one literal and rewrites once; unary minus has no software-overflow expansion with backend checks (`exp_ch4.adb:7918–7978,9698–9738,9935–10156,10678–10725`). `Remove_Side_Effects` returns for the admitted pure scalar forms with its default variable-reference policy (`exp_util.adb:12693–12728,14429–14540`). The two-identity/nine-dynamic-slot maximum follows from the saved binary node and new literal; replacing it with a permitted scalar child cannot require growing slots. |
| Range magnitudes | `Determine_Range` really does retain disjoint computed endpoints (`checks.adb:5559–5618`). The exponent recurrence bounds all four multiplication products and both addition/subtraction endpoints, including reversed pairs. Its digit conversion includes the extra bit at exact powers of two. The multiplication count includes all four products and both save copies (`checks.adb:4845–4872`; `uintp.adb:719–762`). Capture initializer unfolding remains an explicit separate obligation (`checks.adb:5133–5159`). |
| String types | Nonstatic declaration initializers return before subtype construction in GNATprove (`exp_util.adb:5897–5899`). Static literals and aliases retain static constraints. The neighboring inherited `Actual_Subtype` path is scalar-only; the other path requires an aliased uninitialized record (`sem_ch3.adb:4823–4829,5320–5336`). Nonfolded concat results use the String base type, and the literal setters act on operands (`sem_res.adb:10767–10832`). No dynamic Main String constraint is introduced by these routes. Native expansion and library internals are correctly outside the invariant. |
| String aggregate | The earlier reviewed traversal multiplicity combines with the scanner charges as stated. The empty-left artificial parser concat reuses the right String value (`sem_eval.adb:2404–2405`); `Fold_Str` preserves the existing String_Id while resolving its replacement (`:5118–5144`). Thus `2S+P+A` descriptors and `3L+sum(len(a))` characters cover these Main value-producing routes. Diagnostic, dependency and native-generated Strings remain separate. |
| Layout | Retained outputs contain 242 node kinds with sizes 5–12 and 78 entity kinds with sizes 21–64. `N_Head=3`; `Size_In_Slots_To_Alloc` uses the maximum entity size (`atree.adb:2414–2446`). `Node_Header` has the additional offset and explicit 16-byte assertions (`atree.ads:705–731`). Full-size charges for new nodes and growing mutations cover both allocator branches. The local transfer is 9 ordinary or 61 entity dynamic slots per corresponding event, not per final node. |
| Lines and columns | `Skip_Line_Terminators` coalesces CRLF and only appends a physical-line entry beyond the greatest recorded position (`sinput.adb:870–919`), so parser rescans add no duplicate line entries. Initial capacity and growth support the factor-one doubling sequence; the signed bit-size intermediate limits its last local capacity to 65,536,000 (`sinput-l.adb:518–540`; `sinput.adb:109–155`). The post-character column test explains the 32765-character and 4095-tab boundaries (`scng.adb:129–195,2892–2936`). |
| Native concat | String's index base makes the local `To_Artyp`/`To_Ityp` helpers identities (`exp_ch4.adb:2725–2770,2790–2825`). Direct constructor regions sum to `25n+45`; the `n+2` closed leaf copies yield `26n+47`. Temporary entities, lists, remaining copies and duplicate calls match `2n+4`, `3n+11`, `4n+4`, `2n+2`. `New_Copy_Tree` preserves the external scalar entity/Uint references of aggregate leaves (`sem_util.adb:24481–24721,25096–25125,25237–25279`). General copy and immediate action analysis remain open. |
| Native Uint work | The explicit add/subtract sites fit `7n+6` retained entries; including up to `2n` first-index helper calls gives `13n+6`. The magnitude expression covers both ordinary lengths and accumulation of the 256 sentinel (`exp_ch4.adb:2925,3029,3054–3099,3243,3310,13542–13560`). Counting an empty/zero result as zero retained digits does not remove the temporary work-vector charges. |

## Integration cautions and remaining uncertainty

Keep the phase and shape premises attached to each formula. In particular,
source operator counts cannot replace actual expansion/query counts until the
caller multiplicity argument is complete. The scalar expansion formula excludes
semantic folding, range queries and observer state; the concat formula excludes
transitive generated declarations, runtime loading and final analysis.

The range-inference table uses its defined `k(e)`, which is always at least three
because leaves start with exponent 31. Preserve that premise when specializing
the bound: `UI_From_Int` has a fixed three-word conversion vector
(`uintp.adb:1486–1504`), even when a particular table-coded value has only two
digits. This does not invalidate the current formulas.

The native evidence inventory uses Python `splitlines()`; the inspected
`exp_ch4.adb` contains no form feeds, so its recorded source line numbers match
LF numbering. No repair is required for this frozen inventory.

Proceed with the remaining derivation. This review does not cover later commits,
producer changes beyond the earlier review, the source/binder closure, the new
names/serial component, backend/linker representations, or a complete admission
predicate. No numerical admission cap is selected and no guarantee for an
expanded language is established. #119 remains unfinished.

Only this review report and its evidence were added in the isolated review
worktree. No production edit, GitHub write, issue/board change or goal change was
made.
