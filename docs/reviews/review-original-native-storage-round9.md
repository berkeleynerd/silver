# Original native storage review, round 9

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Accepted for the stated direct-request interfaces and disjointness, after
the explanation-only String correction below. No unresolved material defect
was found in original Main. Complete original-gigi storage, shared backing,
collector and whole-pipeline capacity remain open.

Selected reviewer: GPT-6 Astra / Extra High, explicitly selected by the lead.
Runtime-setting confirmation and token/cost measurements are unavailable.
Review began at 21:53:33 UTC on Linux x86-64; source review and independent
checks completed at 22:00:12 UTC (399 seconds, excluding final report authoring).
This review uses retained source
and offline Python checks only; compiler, build, prover, solver, debugger and
full-suite executions are zero. No GitHub write was made by this reviewer.

The first exact review input is
`e652db280a429564fecd06a2b0988c4e9fa8b3c7`, specifically the cold String
source argument and its evidence packet. The accepted helper94 freeze
`db777735c45ccf7a070a1d7eeae5a1afdd4dc8fc` and corrected synthetic173 are predecessor evidence, not newly
repeated complete reviews. Relevant inputs also include the retained pool
lifetime review and callable, governing Oracle, assurance/trusted-boundary
claims, project workflow/model rules, and focused current #119 memory.

The String checker passed all 42 checks against the retained GCC source root
`/tmp/silver-backend-compose-20261018/full-source`, Ada source root
`/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada`, and matcher
`/tmp/silver-backend-compose-20261018/folding-sources/match.pd`. That replay
checks attachments and arithmetic; the following conclusions additionally
depend on the independent source inspection.

The residual and helper intervals are properly nested: residual216 excludes
the two entire allocating self_referential_size calls, including their
private copies, substitutions, type/name/call construction and shared demands.
It owns the original extent expressions and later XUT layout. Synthetic173
starts with the existing helper declarations/bodies. A later variable_size
visit strips unary and constant binary arithmetic to an existing CALL and
returns before constructing another helper.

The original folds charge both conditional arms before success, include the
L-minus-one candidate and cancellation, and permit comparison inversion.
The widening blocks multiply extraction across wrapping u64 arithmetic;
the zero arm prevents conversion pull-back. XUT charges the multiple-of
ratio, both AND probes, two discarded merge_sizes expressions and both
rounding passes. Exact aligned fixed-record constants return before a
rounding factory. The scalar rows include Positive's base-2^15 expansion,
record-position conversions and constant-result alternatives. Positive's
whole cold path is charged once, with Integer/Character associations supplied
by startup. Stub reuse, global declaration pushes and deferred-queue premises
match the selected type/context paths.

One explanation defect was found: precision at most 128 does not imply at
most two stored INTEGER_CST words. `tree.cc:1581–1589` adds an extension word
for high-bit unsigned values; the bitsizetype minus-32 mask needs three.
`tree-core.h:1565–1578` gives the 16-byte typed prefix, and
`tree.cc:2925–2930` allocates 24+(ext_len-1)*8 bytes. Three words therefore
still fit the already charged 40 bytes. The 216-event / 13,149-caller-byte /
17,112-rounded-byte result and combined 310-event totals are unaffected.
The lead confirmed this and filed
[#135](https://github.com/berkeleynerd/silver/issues/135). The exact correction
`341f9ff8aff91818fc473163fe95fb8a7b297dd5` replaces the false two-word
explanation and audit metadata and adds focused extended-word checks.
Independent inspection confirms that repair and byte-identical `derive.py`
and `interface.json`. The further checker-attribution correction
`c608e3873ea74874d795d1be86fa4dca68e03236` changes no allocation claim. The
original recorded checker result predates those changes; the lead's 45-check
correction replay is distinct from this reviewer's 42-check original replay.

For String216, helper94 and corrected synthetic173, pool-zero conclusions
come from the selected constructors and callees. TYPE_DECLs do not enter the
variable-initializer route, fresh fields use DECL_RTL_IF_SET, ordinary extent
folds introduce no aggregate address, and helper addresses designate
FUNCTION_DECLs. Absence of helper emission is not used to infer absence of
allocation. These results alone do not close the imported pool frontier:
the complete remaining Main/context/profile route must also be joined.

The second exact freeze is
`d528110ba9cdde4b1e7f961cab440ee88f790f23`, specifically
`docs/research/retained-literal-original-main-storage.md` and its evidence
directory. Its unchanged clean worktree passed 46 complete input identities,
315 arithmetic cases and six invalid-input cases. The independent checker
beside this report rereads its repository attachments from that exact commit,
verifies the retained source bytes, independently sums the String projection,
checks the extension-word repair, and checks 54 mixed-length/Main/I cases.
It passes 11 grouped checks. Its Main event projection is independently
simplified to `609C+24N+54D+284+I`; that is a conditional request ledger, not
a physical-memory or accepted-capacity formula. I=114 in a checker fixture
is an arbitrary supplied value, not a reviewed source bound on I.

The Main source inspection covered compilation-unit and subprogram scaffolding,
binding/group/list routines, empty elaboration, external profile construction,
type canonicalization/copying, namespace and target declaration hooks, literal
subtype and array layout, constant conversion/backannotation, constructor
sorting/validity, pointer/address conversion, names and alias accounting.
The following claims are supported:

- D, rather than C, bounds cold external profiles. Function-type candidates
  precede hash hits; canonical argument-list construction and one level of
  canonical recursion are allowed. Optional Ada type copies/payloads and
  pointer layouts have separate rows. Integer/Character/String cache references
  do not silently create another original-String interval.
- `R=164C+16D+8` conservatively covers the named scalar sites, including empty
  reversed ranges, size8L, both constructor sorts, and the UI conversion loops.
  Explicit conversion types prevent widening retries. Small-cache vectors and
  integer candidates are independently charged; aggregate hash growth is
  explicitly deferred. Constant nonnegative annotations do not enter Rep_Table
  or the expression annotation cache; their Uint/UI_Ints demands remain exported.
- The two constructor vectors each receive a 128-byte caller charge after
  vec's own rounding. Literal bytes are individual W+21C requests, including
  empty strings; the scratch heap threshold is exactly 1000. Scalar request
  slots use the safe 40-byte integer ceiling, including three extended words.
- C+3 bindings, C+2 possible BINDs, the explicit null-statement trees,
  language_function, elaboration record and two initial rounded stack backings
  are covered. The V allowance is restricted to named empty-return/freeze
  sites. H separately charges direct empty returns, empty groups and initial
  appends; statement-list splicing transfers links instead of duplicating them.
- The namespace map has one possible scalar finalizer. Its shared finalizer
  vector demand is retained. This is distinct from the assembler-name hash
  finalizer in the pool component. Main's local alias allowance and String's
  Positive/Integer alias allowance are also distinct.
- Fixed compiler-added implicit withs remain an explicit +I event/+32I caller
  term. Their `N_With_Clause` arm returns an empty list before namespace/entity
  translation. The count's unresolved value affects original storage closure,
  while its pool demand is zero for every value of I.

The source cuts are consistent across both packets. Main excludes the entire
cold String conversion, helper94, synthetic173's function structures/helper
gimplification, Main struct-function/CF/CFG/SSA and direct lowering, unsharing
and materialization, constant-pool objects, cgraph/dummy, warning/location and
shared backing. Its original STRING_CST and descriptor constructors precede
the pool10C objects; constructing an address or testing initializer constancy
does not itself insert that object into the pool. The historical null helper11,
null structural and null name/vector packets are nonadditive replacements,
not increments to this Main ledger. No published total in this review adds them.

The requested local pool disposition is **yes**: these source arguments can
restore the imported-constructor premise of `native_pool_lifetime` for this
selected family, once the aggregate actually binds their exact interfaces.
The prefix inventory remains the accepted D_in=39257 transfer; original
Main/context/profiles, String216/helper94 and synthetic173 add zero unowned
tree-pool demand. The accepted Main materialization/lifetime argument therefore
continues to cover at most 2C new entries and 3C insertion-capable lookups,
including pre-hit replacement work, with its existing retention/rebuilding
and counter checks. The symbolic I does not invalidate this local result.

This supports only that named pool condition, under the retained native flags,
source/installed-behavior premise and the component's explicit no-wrap/probe
checks. It does not establish global identifier/container storage, original
gigi storage with I supplied, global counter endpoints outside that component,
whole assembly/producer invocation correspondence, collector or process
capacity. The unknown broad frontier and remaining #119/#131 conditions must
not be changed merely because this one premise is now available. This review
does not review a future aggregate implementation or the lead's separate
implicit-with census.

To reproduce the independent retained checks from the repository root:

```sh
python3 -B docs/reviews/check-original-native-storage-round9.py
```

Round outcome: the two direct-request packets are accepted within their named
premises, one arithmetic-neutral explanation defect was repaired and confirmed,
and the previously missing imported tree-pool premise is supported. Native
execution time is zero; the original check replays took about 0.15 and 0.03
seconds respectively. Total elapsed above is observed wall time, not a claim
about model cost or comparative model quality.
