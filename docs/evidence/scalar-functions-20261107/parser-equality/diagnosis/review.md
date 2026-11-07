# Array declaration equality diagnosis, 2026-11-07

Owner-authorized Silver #298. This bounded review was assigned GPT-6 Astra / Max
for the named failed `Array_Declaration_At` equality. The selected setting is
reported; independent runtime model/effort confirmation and token/cost measurements
are unavailable. Inspection was read-only outside this scratch directory: no
source edits, prover/compiler runs, cache changes, Git actions or extra agents.
`/root/function_lean_design` owns the parser implementation and next experiment.

## Recommended next experiment

Reuse `Integer_Type_Word` and `Boolean_Type_Word` in the paired hiding checks in
`Array_Declaration_Model` and `Array_Declaration_At`. Add the adjacent declaration

```ada
   Character_Type_Word : constant String := "character";
```

and use it in the corresponding two character checks. On the inspected source,
the existing constants are at 1879–1880, model checks at 1934–1936, and executable
checks at 2233–2235. This is one new constant and six literal replacements. Keep
the original assertion at 2268, equality lemma call, contracts and all branches.

This removes three observed generated-term differences using the project's
existing named-word pattern. It preserves the words, array bounds, behavior and
accepted domain. It is an evidence-backed next experiment, not a completed
repair. No new equality infrastructure or `Arguments` precondition is justified.

After the active independent Boolean check finishes and the source owner applies
the edit, run only `Array_Declaration_At`'s original required assertion first,
using `--limit-subp` plus `--limit-line` at the adjusted assertion location and
the established level-2, 30-second, CVC5/Z3/Alt-Ergo limits. Verify that the
selected report contains the required `VC_ASSERT` rather than accepting an empty
selection. Inspect regenerated terms to confirm all three paired calls now use
the same word symbols. If this passes, check affected model/executable obligations
and complete the required native and actual-source assurance on final bytes;
source-tree bindings must account for the named words and exact contents. The
Boolean initializer consumer and function-body/caller checks remain independent.

## Exact evidence

Retained failed run: `20261107T212806-7ec67439cb0b`. Its packet is
`tmp/scalar-functions-parser-repairs-298/tmp/parser-proof-repair/saved-after-helpers/`
relative to the main checkout. The supplied packet's recorded source and AST
hashes were checked against the bytes read:

| Input | SHA-256 |
| --- | --- |
| `silver_output_profile.adb` | `6cd94c08fbe6e20a3eea22d4f505bcac17a085227bf18a24973ab8b94c764d91` |
| `silver_output_profile__array_declaration_at.gnat-json` | `6b2c8f3ea1ed20c2b0811f754e633a21d3ef89daf6e756b436293331f2237742` |

The XML leaves `def'vc.380` and its introduced-premises child `def'vc.380.0`
unproved; their recorded solver outcomes are timeouts. The native report locates
the failed assertion at source 2268. Version-6 shape 610 gives the final logical
goal `result__ = array_declaration_model(text, state, arguments)` (with the
model's guarded call wrapper). This is the original required equality, not a
later goal that assumes it. The reported 57/58 successful checks do not discharge
this final assertion.

The complete source expressions are textually identical after substituting the
two initializer `At` names with their `Model` names. More strongly,
[compare_ast.py](compare_ast.py) compares the retained *generated* model and
runtime expressions and reports exactly three unmatched leaves in
[normalized-comparison.json](normalized-comparison.json):

| Word | Model symbol / `Name_Is` call node | Executable symbol / call node |
| --- | --- | --- |
| `integer` | `Temp___String_Literal_9365.temp___String_Literal_9365` / 377599 | `Temp___String_Literal_842.temp___String_Literal_842` / 387490 |
| `boolean` | `Temp___String_Literal_9369.temp___String_Literal_9369` / 377735 | `Temp___String_Literal_846.temp___String_Literal_846` / 387640 |
| `character` | `Temp___String_Literal_9373.temp___String_Literal_9373` / 377871 | `Temp___String_Literal_850.temp___String_Literal_850` / 387790 |

Each pair's defining axioms supplies the same character codes. Their `of_array`
wrappers have the same bounds, respectively `1..7`, `1..7`, and `1..9`. The
character sequences were read directly from the AST, not inferred from symbol
names. The new tests inspect `State.Hiding.Integer_Hidden`, `.Boolean_Hidden`,
and `.Character_Hidden`. Separate array-valued literal symbols block immediate
function congruence at the branch predicates, leaving the solver to recover
equivalent words through character-wise facts in a large context. This can
already affect the result's `Position`, before any final record comparison.

The comparison makes its diagnostic reductions explicit: 30 guarded epsilon
wrappers are reduced to their call terms, 40 program calls are matched to logical
calls, 11 checked range wrappers are removed, two reader calls are substituted
using their contracts, local bindings are expanded, and Boolean/proposition
encodings are normalized. It is an inspection aid, not a proof: it does not
independently discharge the guards, conversions or contracts. It preserves
other record/array conversion terms, so it found no additional unmatched
state-representation boundary after these reductions.

[read_ast.py](read_ast.py) prints the relevant theories and six literal axioms
into adjacent text files. The model definition is present at theory node 373733;
the executable target is at 383929. Both reader postcondition axioms explicitly
contain logical `result = ..._values_model(...)` separately from Ada record
`bool_eq`: integer reader theory 380304, Boolean reader theory 382098. Thus a
missing initializer logical refinement is not the observed gap. The wrapper's
`Values` binding and `Add_Array_Binding` call introduce no extra unmatched
`to_base`/`of_base` conversions in the inspected generated expressions. The
old condition-reader transport diagnosis is therefore a weaker first repair
candidate here than the three exact literal mismatches.

## Precedent and limits

The earlier bounded review at `tmp/boolean-array-native-eq-max/review.md` found
the identical issue in this same declaration's Boolean type-name test: separate
`"boolean"` literal symbols despite equivalent source, with reader logical
equality already available. This source now contains its named
`Boolean_Type_Word` solution; scalar-function hiding checks reintroduce the
same pattern at three new paired sites. The earlier integer declaration and
Boolean object work also used shared words. These records guide the next small
experiment, but their proof successes apply to their own inputs.

No counterexample or semantic mismatch was found. The retained artifact proves
the representation-level differences exist; it does not prove that eliminating
them is sufficient to finish the current VC. A failed focused trial should be
inspected before another complete run or resource change. This diagnosis gives
no reason to change behavior, restrict domains, suppress obligations, omit
source correspondence, or treat a pin update as that correspondence.

The independently active `Boolean_Array_Values_At` postcondition has no duplicated
model/executable hiding-word branch like this declaration. This finding supplies
no new diagnosis of that separate failure and does not justify changing it
before its current helper-enabled run completes.
