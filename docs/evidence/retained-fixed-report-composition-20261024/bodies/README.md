# Silver_IO report composition

2026-10-24 UTC, owner-authorized #212 under #119. This continuation specializes
the accepted #193 producer and #194 reader equations to the actual Silver_IO
sources. It closes the IO **report count, name and serialization inputs** at
the selected source boundary and computes a useful conditional path interval.
It does not close Arguments, concrete paths, native warning-location storage,
or the five-report composition. No admission predicate or production change is
introduced. Global e<=2, two save-entering callbacks and three saves remain
unchanged. Physical memory, stack and disk are separate premises.

The accepted first packet at 057d60cb8e1ff4938bf01667f643d35fc4eb7f0f, reviewed
by 7e6879b320f31d25f29a94067e9cabda07bc568b, is unchanged. This directory's
manifest verifies its six files and the research note's accepted prefix.
SPARK 42554fc241fcd1fdf08d3a2feccb3f86912acbc0, GCC
6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea, GNATCOLL
1d4374ae9187fd14d42ca99a3deb0ab2ff1ebc55, and the existing source/native,
selected target and successful typed-prefix premises apply. No raw graph or
report observation supplies a coefficient.

## Three different entity domains

The accepted whole-process allocation domain remains A_frontend=E_frontend=
19,837, including discarded/generated nodes and imported references. It is
not replaced by the small flow or metadata domains below. In particular,
Why/proof-dependency sets may retain constants excluded from normal flow.

The analyzed graph domain is the package elaboration, Put_Line and Put, as
established in the accepted first packet. Each procedure's normal-use object
roots are Item, Status, Index, Written_Bytes, Written_Count, Flushed, Succeeded,
and File_System. Keep Max_Length and System.Null_Address as two surplus roots.
Allow four scalar range-bound captures, making fourteen roots. Item contributes
one bounds facet; conservatively allow Written_Bytes another, and retain the
synthetic null. Thus F<=17. The package has its five declared objects, one
array bounds facet and null, hence F<=7. These are cardinalities of the union
of relevant normal-use roots/facets, not a count of all Flow_Id variants.

The justification is `flow_utility.adb:2836–2858,3380–3455,5335–5398,
5630–5648`: ordinary reference collection filters constants without variable
inputs and enumeration literals; quantifier traversal removes Offset before
returning its sets. Generated scalar captures can reference only the listed
roots. Get_Components/Flatten_Variable retains one whole object and at most
one bounds facet for these scalar/rank-one/non-discriminated types, as in the
accepted incoming proof. Callee formal identities in Parameter_Formal are
metadata, not additional variables (`flow-control_flow_graph-utility.adb:
371–546`). Their actuals and File_System globals supply the variable sets
(`:667–740`). The six-effect global universe from #193 remains unchanged;
each of these three particular callees uses exactly File_System. No runtime
body or external abstract-state constituent is traversed.

## Typed statement closure and constructors

| Source body | Ordinary assignments | Side-effect assignments | Procedure calls | Conditions | Returns | Range loops | Invariants |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 10 | 3 | 4 | 4 | 4 | 1 | 2 |
| Put | 8 | 2 | 3 | 3 | 3 | 1 | 2 |

Each body has one explicit Status declaration. The closure is structural,
independent of runtime iteration count, and includes unreachable source arms.
The relevant frontend routes are:

* `exp_spark.adb:118–205` is the light-expansion whitelist. Ordinary assignments
  are not expanded into statement blocks. Its aggregate branch only rewrites
  container aggregates (`:464–604`); these are ordinary Character arrays.
  Length/Pos/Val rewrites add conversions/check flags, not separate call bodies
  (`:772–881`). No DIC applies to Status (`:925–946`).
* Only `of` array-iterator loops take the expansion route (`:896–919`);
  `in Item'Range` retains its loop. Quantifiers are not expanded by that route.
  `sem_ch3.adb:22588–22835` may force the two bounds of each of the loop and
  quantified ranges. Each scalar capture is one initialized declaration
  (`exp_util.adb:12761–12824`). Its initializer is analyzed with checks suppressed
  (`:12723`), and a captured reference does not recursively recapture itself.
  The bound of four deliberately charges both bounds even when the literal,
  First/Last attribute, or safe-reference tests avoid a capture.
* Remove_Side_Effects requires full analysis and a declaration/loop-bound
  context in GNATprove mode (`exp_util.adb:12618–12723`). The postcondition's
  slice is in the contract/preanalysis expression context, not such a new
  declaration. `sem_res.adb:11809–12015` resolves it, forces its scalar bounds
  subject to that same gate, and sets a slice subtype. It does not create a
  second executing loop or copy the body. Written_Bytes is already constrained;
  the access/discriminant branches do not apply.
* The range/index route creates at most one index itype per range
  (`sem_ch3.adb:20478–20761`). Allow four type/declaration positions per
  procedure: loop index, quantifier index, slice subtype and one surplus. The
  package's constrained Written_Bytes and Written_Count declarations have at
  most two subtype positions plus the array's index; four is again sufficient.
  Its bounds are static, so they add no variable captures. Captures themselves
  use existing scalar types. Abandoned query/check nodes remain charged to
  A_frontend. Insert_Range_Checks returns when expansion is inactive
  (`checks.adb:8117–8165`); quantified-expression statement checks are dropped
  (`sem_ch3.adb:22808–22818`). Those discarded trees are not new flow statements.

No exception handler, finally, extended return, record/access cleanup,
dispatching, inlining, generic instance, predicate, DIC or Loop_Entry introduces
another traversed statement subtree. This reuses the accepted selected-source
exclusions, not just a lexical absence argument.

Each call has one explicit actual, possibly a scalar result actual, and one
global. The accepted constructor row therefore becomes 5+2*4+2=15.
Initial/final construction is at most 2F after flattened-key deduplication
(`flow-control_flow_graph.adb:1506–1643`). The full conservative table is:

| Vertex term | Put_Line | Put | Package |
| --- | ---: | ---: | ---: |
| Fixed scaffolding | 10 | 10 | 10 |
| Initial/final | 34 | 34 | 14 |
| Ordinary assignments, five each | 50 | 40 | 0 |
| Calls, fifteen each | 105 | 75 | 0 |
| Conditions, three each | 12 | 9 | 0 |
| Range loop | 6 | 6 | 0 |
| Invariants | 2 | 2 | 0 |
| Simple procedure returns | 4 | 3 | 0 |
| Object declarations, five each | 25 | 25 | 25 |
| Type positions, four each | 16 | 16 | 16 |
| Abstract/refined postcondition allowance | 2 | 2 | 0 |
| Body/block overhead | 4 | 4 | 4 |
| Join allowance | 16 | 15 | 6 |
| **Eligible vertex upper bound V** | **286** | **241** | **75** |

The procedure joins charge declarations, main statements, each then-list,
loop body, four possible capture-action lists, the block join, loop-augmentation
join and three contract joins. The package has visible declarations, body
declarations/statements and three surplus joins. The fixed scaffolding also
charges empty contract joins. Constructor sources are the accepted #193 table:
assignments `:1995–2039`, conditions `:2730–2980`, loop `:3397–3454,4210–4353`,
objects `:4880–5202`, types `:6688–6735`, contracts `:6393–6433`, pragmas
`:5684–5750`, returns `:6442–6548`, block `:6556–6683`, calls `:6858–7087`,
lists `:7186–7215`, folded checks `:7339–7385`.

V covers substantive vertices including those later pruned or diagnosed as
dead. Nonflow pragmas/markers may construct further null vertices, so retain
**constructed vertices <= A_frontend+V per graph**, separately. As in the
accepted specification proof, Simplify_CFG clears their edges and attributes
before reporting. Separate_Dead_Paths explicitly skips Null_Node_Attributes
(`:7688–7725`); therefore these extra nulls do not acquire an original-program
flag preserved by Clear_Vertex_And_Attributes (`:8388–8403`). Cleared substantive
vertices that can retain that flag were already charged to V. Extra nulls
cannot fund variable/call/loop emitters or a trace traversal. The accepted
pruning/copy argument preserves this domain; there is no cleanup replay.

## Emitter attempts and incoming state

Do not assume sanity, initialization or proof succeeds. The accepted emitter
table specializes by source dispatch (`flow.adb:1745–1837`) as follows:

* For procedures, function-global-output and function-volatility branches are
  absent. Explicit user Global has no Proof_In, and the illegal-read checker
  requests `Use_Deduced_Globals => False` (`flow-analysis.adb:3642–3725`).
  Explicit Always_Terminates=False disables that loop (`:6442–6725`).
  There is no local abstract state. Retain eight subtype-constraint roots,
  six generated/declared-global sets, both sanity vertex scans, unwritten,
  unused, ineffective, dead, initialization and assertion-input rows.
  With C call nodes, their sum is `(4F+3)V + (11+8)F + 13C + 4`.
* The package dispatch has no unwritten/unused/assertion-input/proof-in or
  function checks. Retain its sanity, ineffective, dead and initialization
  rows, four constraint roots and four constant allowances. It has no loop
  or call termination diagnostic (and no subprogram success message).
  Its bound is `4VF + 2V + (8+4)F + 4`.

These yield 20,724, 17,503 and 2,338 attempts. Outside the graph loop, allow two
Check_Required_Contracts attempts for Put/Put_Line. Imported callees are not
analysis-requested in this process, and the constant-global route has no
constant in an explicit Global (`flow.adb:1662–1695`,
`flow-analysis.adb:6836–7077`).

Check_Incomplete_Globals visits translation entities rather than analyzed
graphs (`flow_sanity.adb:175–277`). Its only nonempty selected contracts are
the two IO posts: there is no Pre, expression function, abstract subprogram or
imported callee contract. Reference closure marks the three imported calls
with their empty pre/post lists; builtin scalar/array operators add no such
contract. Mark_Entity's seen-entity gate and Entity_List insertion routes
(`spark_definition.adb:11834–11852,12208–12249,12873–12892`) prevent arbitrary
revisitation. Charge four abstract/refined positions and duplicate that bound
to eight, allowing both list-insertion routes even though the extra package
route fails the subprogram-kind filter. Each expression has at most eighteen
whole-object proof references: the fourteen-root procedure allowance plus
four surplus, with Get_Variables_For_Proof dropping bounds
(`flow_utility.adb:5653–5749`). This is a local expression-reference theorem;
the entire proof-reference allocation domain remains E_frontend. Outside
attempts <=2+8*18=146; the process flow total is **40,711**.

Keep the entire 16,547 Why-allocation warning allowance. For each body, the
array recognizer scans its single loop subtree (`flow-control_flow_graph.adb:
3609–3666,4007–4118`). Charge all assignments and one-actual procedure calls
in the entire body, plus four capture slots: 21 and 17. This includes
side-effect function assignments and overcharges operations outside the loop.
There is no nested executing loop. Retain generic alias warnings 13C=91/65,
even though actual scalar profiles are narrower. Thus warnings <=16,547+194=
**16,741**, without asserting that any Image or other warning is actually
emitted. The accepted warning exclusions and fixed 192-character text apply.

Trace attempts sum `V+2VF` over the three graphs; each trace has at most V
lines and P+12 bytes per line. Counter starts at zero in this phase-2 process;
phase-1 is a different process. The relative filename is `silver_io__flow__`
+ at most ten counter digits + `.trace`, at most 33 bytes. Retain native print
calls 3*flow+2*warnings, with native location-chain and initial-count attachment
still separate. Deduplication never reduces attempt/storage funding.

## Text and source-selected JSON schema

The checker freezes a literal census over every reached message-producing
procedure, with helper regions included. The largest sum is 1,189 bytes in
Check_Expressions. This deliberately includes alternative messages, Details,
Fix and SRM reference strings. All these template characters are printable
ASCII; the accepted fixed formatting introduces only printable ASCII or
standard two-byte JSON escapes. The maximum literal marker counts are fourteen
ampersands and one hash. The source classifier, not the scanner, establishes
which procedures are reached; `message-census.json` records its exact spans.

Raw source/generated names are bounded by 64 bytes: selected root names are
at most eighteen, the normal internal generator has one letter, at most ten
Nat digits and a spec/body letter (`tbuild.adb:55–99,719–726`); the selected
range names add at most `_FIRST`/`_LAST` to an existing scalar type name
(`exp_util.adb:12557–12611`). Allow the selected enclosing package/subprogram
qualification and one Nat homonym suffix as well. The existing serial/Nat
representability premise is not proved by this name bound. There is no
recursive generated-name expansion. This also bounds decoded CP names.
The accepted canonical generated-global spelling bound 760 dominates the
substitution expression `max(4*64+64,760+2)=762`.

There is no generic instantiation or inlining in the source locations used by
these graph messages, hence h=0 instantiation edges. With the accepted five
location substitutions bounded by P+64, raw message bytes are
`1189+12+11+3*762+5*(P+64) = 3818+5P`. The 12/11 allowances are the SPARK RM
wrapper and CWE suffix. Paths retain the accepted delimiter-free spelling
premise for the diagnostic marker language; concrete attachment remains open.
Names and paths therefore introduce no extra `&`/`#` markers.

To_SARIF_Msg_Text (`errout_wrapper.adb:698–737`) expands an ampersand to
`{counter}`; counters 0..13 add at most three bytes each. A hash adds eight
bytes as `[here](0)`, and quoted-marker handling cannot increase this charge.
Keep surplus50 rather than assuming Compute_Message removed every marker.
Decoded text <=3868+5P. Escape_String (`gnatcoll-json-utility.adb:87–146`)
charges the fixed/template/name portion at factor two and every path byte at
factor six. Encoded text, including quotes, is **7738+30P**. No ASCII-path
premise is introduced; UTF-8 validity remains the accepted premise.

The flow constructor (`flow_error_messages.adb:300–499`) sets E, Msg, Tag,
severity, span, tracefile and PC_Flow. Create has empty Names and no secondary
location, so the message has no argument array or relatedLocations. The
remaining response fields are defaults. Add_Json_Msg (`errout_wrapper.adb:
76–190`) therefore omits VC location/file, editor, counterexample and stats
fields. Check_Tree is `{}` and unproved status is `{status:"unknown"}`.
The source has no Annotate suppression; charge optional warning suppression
as an empty string. Details/Fix/Continuations are native terminal owners, not
serialized fields. Include optional tracefile and msg_id conservatively.

Warning_Msg_N (`errout_wrapper.adb:874–918`, record defaults in `.ads:101–128`)
leaves E empty and has no response/trace/secondary-location fields. Its reached
fixed warning texts contain no surviving placeholder, so To_JSON omits Names
even when Add_Default_Name supplies a native display name. Keep p.string(192)
with generic escaping and PC_Trivial. No generic twelvefold SARIF multiplier
is needed for these fixed templates. Both overlays preserve actual JSON shape
dimensions using the accepted Shape/container helpers.

## Proof rows, metadata and conditional interval

Retain the accepted IO R/G/A/J=40/117/309/2, never multiplying global G or A by
R. Current printed CP roots have no String literal; source attributes are at
most six characters and decoded/generated names at most64. The accepted
stored-Uint q18 image bound550 therefore gives W550, CP15581 and proof text
31439. Source-copy allocation still requires the independent source-span
guard; this returned-image theorem does not close that storage owner. Reuse
canonical_proof unchanged, including its conservative full response schema.

The report identity domain is the six names in capacity.REPORT_NAMES. Flow
messages attach FA.Spec_Entity or the two contract owners. Warnings have no E.
Get_SPARK/timings select analyzed entities; proof rows belong to the two
procedures. Claim registration can add the three imported callees through
the two callers' six distinct call pairs (`gnat2why-assumptions.adb:116–188`).
No operator, generated subtype or imported package becomes a report entity.
Allow thirty claims, forty-two edges, seven timing entities and seventy-one
timing fields. Full_Source_Name is at most34 bytes, metadata location depth
one. Neither bound is applied to all frontend identities or warning chains.

The focused checker computes the affine full/projected byte bounds and the
maximal sufficient integer P within 0..4096 under native max-path<=4096 and
page-size<=65536. It checks both interval endpoints, affine arithmetic and the
first failing successor, if any. All guards are monotone in P; the xstring
bucket rule and integer alignments are nondecreasing. The resulting interval
is conditional, not a claim that the current common P lies in it. Common P
must cover project argument, initial/saved cwd, object directory, all source/
reference/sloc paths and generated report/config filenames. Native max-path
and page size are separate operands. No independent native packet is imported
or claimed reviewed here.

## Verification and residual work

Run the new focused check, with an already acquired complete GCC source root:

```
python3 docs/evidence/retained-fixed-report-composition-20261024/bodies/check.py \
  --gcc-source /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada
```

It verifies whole-file identities against the retained complete-source
manifests, the new source correspondences/literal census, source-body census,
numeric bounds and a small independent JSON escape witness. It imports only
accepted capacity functions and the lexical scanner definition, never their
checkers' top-level programs. It is neither an Ada reachability prover nor a
compiler/prover/native capture. Source classification needs independent review.

Remaining: Arguments source composition; actual common paths/configuration;
native warning-chain/initial-counter/storage joins; syntax-header lifetime;
source-span and private failed-fix storage; source/native/service attachment;
and complete five-report collector/SARIF integration with Main. The existing
failure handling and physical-resource premises remain separate. This packet
does not complete #212 or #119.

Selected author setting: GPT-6 Astra / Extra High, as assigned; runtime
confirmation unavailable. Elapsed checker time and exact inputs are in
result.json/round.json. Total task elapsed time and token/cost measurements
are unavailable. Review is pending at this freeze.
