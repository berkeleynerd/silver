# Independent native review — #410 / draft PR #412

2026-11-21. Selected reviewer settings: GPT-6 Astra / Max; runtime model and effort were not independently exposed. Native Linux x86_64. Read-only review, with scratch-only admission probes; no builds, proofs, tracked edits, GitHub actions or memory updates. The live harness goal returned null.

Review target: native changes from `5f97477d5b` through integration `4199e0f33b76036d120218609f036ea2f4b6a7fb`, corresponding to frozen native `f57750fd90` / integration `4e44cc816d`. At final handoff integration HEAD was `d3956b1cc1dc587c416a00366744dccf10769a5d`; all 135 `src` files still matched the native worktree byte-for-byte, with no additional integration source files. All ten supplied owned-file hashes matched `/tmp/silver-native-410-native-hashes.json` in the earlier audit. Concurrent Lean and delivery-document changes were excluded from the native source verdict, except for the stack remedy reviewed below.

## Resolved finding: P2 — larger Linux x86_64 stack prerequisite

Locations: `src/silver_array_bindings.ads:13` (descriptor capacity), `src/silver_array_bindings.ads:67` (metadata), `src/silver_output_profile.adb:6556` (`Loop_Body.Inner` context copy). Setup text at the initial review target recommended 16 MiB only for ARM64 (`README.md:323`, `development.md:318`).

Increasing the array table from 170 to 585 entries and adding type metadata enlarges the context copied at every nested loop, including programs using only preexisting constructs. The frozen feature compiler raises `STORAGE_ERROR : stack overflow or erroneous memory access`, exit 1, at an explicit 8 MiB process stack on all three exact 4,096-byte fixtures below. All three return `Accepted: silver.`, exit 0, at 16 MiB.

| Scratch source | Nested levels | Form |
| --- | ---: | --- |
| `/tmp/silver-410-native-review-probes/old_counted.adb` | 142 | Existing counted loops and an indexed write |
| `/tmp/silver-410-native-review-probes/old_foreach.adb` | 159 | Existing singleton constant-array iteration |
| `/tmp/silver-410-native-review-probes/named_range.adb` | 128 | New named-array Range loops |

The first fixture reconstructs the same family as `tests/test_integer_arrays.py:190`. The main-checkout comparison binary accepts both old-form fixtures at 8 MiB. Its source checkout has no `src` differences from the review base; I did not independently audit that binary's build provenance.

DWARF reports array Metadata growing from 6,804 to 32,168 bytes and Body_Context from 38,900 to 64,264 bytes: +25,364 bytes per copied context. These are record sizes, not total dynamic frame sizes or a universal stack bound. Exact binary hashes and outcomes are in `stack.json` and `record-sizes.json` in the scratch directory. Feature binary SHA256: `2aa21a64455795ca6b5ced2cfc86954d74fa38cafdb7541c4f5c61348447c1f4`.

Recommendation: extend the measured 16 MiB invoking-shell prerequisite to Linux x86_64, retain these inputs and their actual stack limits, and complete managed compile/prove/audit/run observations plus source-limit controls at that setting. Keep the existing sufficient-stack environmental premise and unchanged source membership. No new language limit or speculative context redesign is needed for this finding.

Resolved: setup and trusted-boundary documentation now record the 16 MiB invoking-shell setting for Linux x86_64 as well as ARM64. The lead retained the reviewer inputs and measurements in `docs/evidence/named-array-parameters-410-20261121/stack/`, and `tests/test_array_parameters.py:27` adds `test_source_limit_loop_shapes_complete_the_native_route`. Corrected managed run `20261121T130801-77ed9650af68` passed all three full check/compile/prove/report-audit/run routes and rejected their 4,097-byte siblings (14.365 s test time; 15.760 s managed duration). I inspected the passing log and updated evidence description. The 16 MiB shell limit is a lead-recorded launch setting, not a field captured by the managed runner. The earlier run `20261121T130659-ca307255c345` remains failed because the test's audit helper used an invalid report-policy name after its compilations/proofs succeeded; the corrected test selects the existing `static` policy. This resolves the reported integration finding, without asserting a universal stack bound or a compiler-managed limit.

## Native semantic assessment

No additional actionable native admission or semantic defect was found in the reviewed changes and their callers. In particular:

- Named identity is an ordered positive type-table index. Initialized objects copy the selected type's index and component bounds; array actuals require that exact positive identity. Equal shape and anonymous arrays cannot substitute. Closed callable frames retain type metadata while discarding Main objects.
- Array formals have immutable symbolic views with zero physical offset and no stored-cell charge. `Read_Bounds` uses the full declared component interval for a view even when `Elaborating` is true. Component reads remain nonstatic and retain nonempty/index-containment checks in unreachable code.
- Formal parsing and writable-actual selection reject array output modes. Existing scalar input containment, incoming-state evaluation, output initialization, alias checks and copy-back range checks remain on their original paths. Bare read-only actuals support repeated and forwarded inputs.
- First/Last/Length use fixed metadata and wide length arithmetic; Range enters the existing counted-loop transfer. Scalar shadowing and binder masks are checked before metadata fallback. The three component-read modes preserve shape queries in subscripts and counted bounds without admitting nested element reads or read-only component loop bounds.
- The new table capacities follow disjoint source spellings. The explicit 1..2048 type cardinality rule is checked even for unused types; it does not charge collective formal lengths against physical cells. The generic physical-declaration guard rejects a symbolic-view frame in both model and executable reader without narrowing the helper's original precondition.

An additional 23 admission-only scratch controls all matched the specified outcomes. They cover full-domain formal arithmetic, procedure-prefix queries, nominal forwarding mismatch, predefined-name hiding, dead-loop hiding, static declaration and singleton queries, endpoint overflow, read-only loop exclusions, and alias handling that distinguishes attribute labels from actual scalar index reads. Sources and exact results are in `/tmp/silver-410-native-review-probes/admission.json`. These controls support the review; they are not universal evidence.

## Focused readiness audit and accepted caller follow-up

I independently audited all 27 retained successes listed in `/tmp/silver-native-410-focused-successes.json`, using the managed ledger and `FocusedProof.check_report` on each run's retained `focused-evidence/0`. Every run was successful under `final-policy`: 130 flow checks and 963 proof checks, 1,093 in total. The report checks passed complete selection and ownership coverage, required discharge, absence of skipped/assumed/suppressed checks, and successful SARIF matching the actual GNATprove invocation. No prover was rerun. The audit summary is `/tmp/silver-410-native-review-probes/focused-reaudit.json`; the managed-status snapshot contains no outstanding diagnostic recurrence.

The selected complete unit or helper declaration/body text matches the current frozen source for all 27 runs, as recorded in `/tmp/silver-410-native-review-probes/focused-current-inputs.json`. The four complete binding/expression units are unchanged since their selected successes; subsequently changed imported files are not their callees. Earlier output-profile helper blocks match the identified source snapshots. The two later symbolic-view guards have fresh successful checks for both declaration readers, `Loop_Body`, and the outer function/procedure declarations. The later catalogue change still belongs in complete native integration validation.

The original inventory did not exhaust direct affected callers. The lead accepted the following as #410 readiness follow-up and is queueing canonical full-subprogram checks. This is a coverage prerequisite, with no failed selected obligation, mismatching selected source, or additional semantic defect found. I have not audited results of these subsequent runs.

All locations below are in `src/silver_output_profile.adb`:

| Supplemental gate | Reason |
| --- | --- |
| `Declaration_At:2610` | Direct caller of the new array type declaration reader |
| `Scalar_Declaration_At:1616`, `Subtype_Declaration_At:1560` | Callers of the array-aware scalar constraint reader |
| `Call_After:609`, `Image_At:1022`, `New_Name_Allowed:1361`, `Scalar_Type_At:1450`, `Character_Declaration_At:1666`, `String_Declaration_At:1709`, `Boolean_Atom_After:3618`, `Boolean_Declaration_At:2578` (body at 4827), `Callee_At:5494`, `Procedure_Callee_At:6133`, `Function_Type_At:6731` | Direct callers of the new `Lookup_Type` operation |
| `Actual_Model:5133` | Ghost caller of the new array actual reader |
| `Same_Parser_State:1868` | Logical equality now includes type metadata |
| `Procedure_Prefix_Step:7229` | Changed array-aware parameter flow |

`Append_Parameter:6992` and `Append_Procedure_Parameter:7153` are expression wrappers without explicit contracts; their operational paths are covered by the passed frame gates, and they were not counted as additional required standalone gates. The lead had started the first three supplemental checks and accepted the remaining fourteen. Wider unchanged transitive compiler checks belong to the integrated audit. Completion of these supplemental gates is required before treating focused readiness as complete.

## Producer and retained-report capacity

No numerical capacity defect or allocation change was identified. The existing 49,279,744-byte retained-report envelope within the 67,108,864-byte allocation leaves 17,829,120 bytes of headroom and remains conservative for this capability under the existing producer premises. I inspected the scalar-function, scalar-procedure, fixed-array, constant-iteration and Boolean-array capacity records, the shared report-capacity record and its tests, and the retained producer routes below. A feature-local record connecting the new syntax to this accounting is still needed before delivery; its absence need not prevent the frozen compiler's full native audit after the caller prerequisites pass.

The inherited array-warning term `floor(S*S/(4*24*8))` bounds enclosing foreach loops times indexed writes under `24*L + 8*W <= S`. Here 24 is the minimum complete foreach loop syntax (15-byte prefix plus 9-byte `end loop;`), not an array declaration size. The new 11-byte named-object declaration therefore does not invalidate that denominator. New Range loops are longer, and immutable array actuals add no array writes or array-output warning route.

The inspected producer routes support the existing accounting:

- `gnat2why-expr.adb:4393–4592` transforms each actual once; the array actual is a bare constrained nominal object, with no output reconstruction or copy-back. The formal-type transformation is at 4579–4585. `why-gen-expr.adb:1155–1164` immediately returns for a conversion with matching entity/type/wrapper status. Even the conservative distinct constrained-target route at 1448–1464 adds at most one Length check, within the existing per-actual two-byte reservation. Qualification, sliding, predicates and relaxed initialization are outside this capability.
- `gnat2why-expr.adb:19903–20095` handles First/Last/Length. Type prefixes select `Get_Array_Attr` in the term domain; an object prefix transforms a simple identifier, not its components. Length uses mathematical Integer; the extra modular route does not apply to the signed Integer index domain. Existing outer scalar-conversion and counted-loop bound-root allowances cover applicable checks.
- `gnat2why-expr.adb:22890–23008`, `gnat2why-types.adb:1108–1141` and `spark_definition.adb:2313–2389` show no independent new type-root obligation or owned type entity for these static named array declarations. The selected syntax supplies none of the private/default, access-subprogram, iterable-aspect, nonstandard-equality or aggregate/ownership-annotation triggers, nor nonstatic index/component subtype indications.
- `flow-analysis.adb:1210–1268` and 1372–1445 account for imports/objects as Entire_Var sets and emit at most one ineffective-import warning per member. Array bounds do not multiply formal names or warnings. `flow-control_flow_graph.adb:4015–4032` is the existing loop array-initialization warning route; closed subprogram bodies add no writable array route.
- The source lower bounds used for formal, subprogram and call counts remain valid (formal at least 7 bytes, complete function/procedure more than 32, call at least 5); bodies are not inlined. Named-array syntax does not reduce the existing scalar-site or loop minima. Initializer/index sites retain their joint `floor(S/2)` reservations. Formal component counts do not multiply reports: reads are counted by source site and no array copy-back/default-initialization wrapper is selected.

The six retained producer files match the documented SHA256 values at SPARK revision `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`. The first four are under `tmp/scalar-procedures-native-370/tmp/procedure-probes/producer/`; the last two are under `tmp/empty-loop-repair/tmp/boolean-array-producer/upstream/`:

| Producer file | SHA256 |
| --- | --- |
| `gnat2why-expr.adb` | `750ed73091af62c0b522077c2e59e10f496b91a4bee323b3b822fba15094dd14` |
| `why-gen-expr.adb` | `9891d54331f76713685fce8f21501d549485a46c35593ac68ba572c9f0f5a432` |
| `flow-analysis.adb` | `10dab62c866ca03c5fd9dfefc2f70ea348797f18fb4703ffa69be1ceb9ff9c94` |
| `flow-control_flow_graph.adb` | `d6d903a8f15e645e1de51c2b74c8b61288885b34c88e9b2ac1f5469a801684b7` |
| `gnat2why-types.adb` | `3b4b21d00eb4d14a4f7966c097f215217ea54183be4048a5d9bbd98ccdb3663d` |
| `spark_definition.adb` | `d8d9203d847f4673be7be8bef8f006d90e5d0da9365e30e2eed311540bda934e` |

The existing fifteen feature tests (including five full routes) and the repaired three source-limit loop routes corroborate the route assessment; they do not supply a universal producer bound.

## Final disposition

The stack P2 is resolved. No additional actionable native semantic or numerical report-capacity defect was found. Complete the accepted direct-caller checks and feature-local capacity account as part of #410. This native-scope review does not assert complete native verification, Lean/source correspondence, automatic-discharge completeness, or approval to merge. Those and final regression/provenance checks remain the lead's shared checkpoint. No tracked files, issue state, CLI memory or live goal were changed by this reviewer.
