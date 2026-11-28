# Bounded package retained-report capacity: integration ledger

2026-11-22, [#416](https://github.com/berkeleynerd/silver/issues/416).
The package audit subthread derived this account; the integration lead checked
the source-charge premises and independently recomputed both integer maxima and
the complete sum. The three arithmetic/schema tests passed in managed run
`20261122T134723-9709bfc7d061`. This is a source/producer shape
argument under the existing pinned tool assumptions; probes do not establish the
bound. Canonical native/Lean/source assurance remains separately required.

The selected application contains the original package spec, body and Main,
with a **shared 4,096-byte source limit** and the existing shared 63-operator
budget. Package bodies have scalar state, locals, finite control flow and calls
to earlier completed bodies. Main retains its existing grammar. No author
contracts, private types, arrays in packages, package elaboration statements,
recursive calls, access values, relaxed initialization, or type invariants occur.

The old complete 49,279,744-byte envelope remains a conservative allowance for
all ordinary records and metadata in either selected report, except for the
explicit additions below. The report buffer is reused for package and Main;
this is a bound on **each individual retained report**, not their sum and not
process peak memory. Runtime and null reports retain their 262,144-byte domains.

## New multiplicity: implicit state outputs

`flow-control_flow_graph.adb:6863-6948`, `Process_Subprogram_Globals`, reads the
inferred global sets and creates exactly one output vertex for each member of
`Globals.Outputs` at a call. It may also create input vertices, which do not
take the ineffective-output diagnostic route. `flow-analysis.adb:1844-1984`
visits vertices once; its global-parameter/output-view branch emits at most one
`"STATE" is set by "CALLEE" but not used after the call` message per state and
source call. Scalar state has no component splitting. Source loops do not
multiply the static call/output vertex set.

The producer revision for both files is
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`. The exact inspected files are retained in the
[producer packet](evidence/bounded-library-packages-416-20261122/report-producer/inputs.json).
Their immutable upstream source is [AdaCore/spark2014 at this revision](https://github.com/AdaCore/spark2014/tree/42554fc241fcd1fdf08d3a2feccb3f86912acbc0).

Let:

* `S = 4096`;
* `P >= 1` be package-name byte length;
* `K` be the number of distinct private scalar states potentially written by
  any package procedure;
* `C` be the total number of source procedure call sites, conservatively counting
  even calls with no hidden output or into the runtime.

The current admitted grammar gives the **disjoint** source charge

```text
5*P + 9*K + 2*C <= S.
```

The five package-name occurrences are the spec header/end name, body header/end
name and Main with-name. Both closing names are mandatory. The native parser
owner independently confirmed this premise on 2026-11-22.

Each state has a distinct declaration of at least seven bytes (`A:T:=0;`).
Each potentially written state also has at least one direct assignment or
explicit writable-actual occurrence somewhere in the finite earlier-completed
call chain. Reserve two bytes there: one target-identifier byte and either an
assignment-colon byte or its actual's preceding `(`/`,` delimiter. Different
states select disjoint occurrences. Read-only state is not included in `K`.
The call-site reservation uses one callee-identifier byte and its statement
semicolon, disjoint from every actual's reservation. Qualified and nonzero-
formal calls use additional bytes; `R;` explains the two-byte minimum. The
native owner confirmed there are no other admitted state mutation forms.

Use the existing maximal retained flow-schema serializer, with an empty state
and callee name, file `.adb`, and trace `__flow__2147483647.trace`. It occupies
526 bytes, including record indentation and separators and maximal-width
numeric fields. Reserve **768 fixed bytes per new record**. This also covers
the qualified-name dot and indexed trace suffix `~1` (three extra fixed bytes).
The package prefix can occur in both the source filename and trace filename,
so separately charge `2*P` per record. For Main this overcounts its fixed file
and trace prefix.

The exact finite integer maximum is:

```text
max K * floor((4096 - 5*P - 9*K)/2) * (768 + 2*P)
= 179,203,692 bytes, at P=17, K=223, C=1002.
```

The independently charged message-name payload is bounded as follows. Across
all state names in a single call, their distinct declaration spellings total
at most `S`; across `C <= S/2` calls this costs at most `S*S/2`. A callee name's
declaration spelling has the same length as its call spelling. The sum of those
spellings across source calls is at most `S`; repeating them for at most
`K <= S/9` states costs at most `floor(S*S/9)`. Main's additional qualified
package prefix is written at each relevant source call, so the same independent
bound applies to that payload. Package-internal state names are bare. All
identifier bytes are ASCII and require no JSON escaping. Thus reserve:

```text
S*S/2 + 2*floor(S*S/9) = 12,116,878 bytes.
```

The unqualified spec-case callee, body-case internal state, and lowercase
qualified state in Main are corroborated by the original producer probes;
different casing does not alter these lengths.

## Other package-specific additions

Ordinary package report records can contain the package prefix in `file` and
`check_file`, or in `file` and `tracefile`. Proof records do not carry flow trace
filenames. Put `T = S - 5*P`. Package bodies exclude Image and array-loop notes,
so there is no additional quadratic filename multiplier for those old classes.
An explicit ordinary-record count obtained by retaining even inapplicable old
scalar/index/loop allowances is:

```text
proof <= 3*floor(T/2) + floor(T/7) + 3*floor(T/15) + 3*63
flow  <= 2*T + 2*floor(T/7) + floor(T/2) + floor(T/32)
total < 5*T + 189 <= 7*T + 189.
```

The three half-source proof terms cover the joint ordinary expression roots,
the inherited extra index allowance (even though absent in packages), and
explicit writable-actual copyback conversions. The flow terms retain the old
`2*T` bucket, output initialization, new formal advisories, explicit unused
copyback outputs, and function termination. Hidden outputs are charged solely
in the new product term above. All those ordinary schema bytes are already
inside the complete old envelope. The original file/trace schema allowance has
ample fixed margin for the indexed suffix; only the variable prefix is added.

Hence reserve the following intentionally loose prefix maximum:

```text
max 2*P*(7*(4096 - 5*P) + 189) = 11,899,384 bytes, at P=412.
```

No additional hidden-state copyback *range* check is introduced: the original
Ada call writes the same global object, without an actual/formal subtype
conversion. `gnat2why-expr.adb:4334-4919` iterates explicit call parameters for
the conversion/copyback stores; `Transform_Call_With_Side_Effects` at
21035ff composes those stores with the actual call. Its extra invariant,
variant, tag, and exceptional routes require excluded constructs. The global
output loop at 12134-12213 inserts havoc only for relaxed initialization,
which is also excluded. Ordinary declared bounds and assignment checks are
already retained in the original root allowance. This argument concerns the
producer path, independently of semantic closure conversion.

Let `R` be the total declared routine count. Spec/body pairs and Main-local
routines each use more than 32 disjoint bytes, giving `5*P + 32*R <= S`.
The original routine metadata envelope still covers routine counts and numeric
IDs. A package prefix occurs in the routine entity name and defining filename;
timing and dependency keys are numeric IDs, and termination names are bare.
Conservatively reserve **40*P per routine** for all prefix text, including
unused margin for every old timing entry:

```text
40*floor(S*S/(4*5*32)) = 1,048,560 bytes.
```

Zero-formal calls raise the conservative caller/callee-edge count from
`floor(S/5)` to `floor(S/2)`. The same three Effects/AoRTE tokens per edge and
256-byte token allowance therefore add:

```text
(2048 - 819)*3*256 = 943,872 bytes.
```

Add a separate **65,536-byte** allowance for the package outer entity,
coverage, elaboration claims/timings and surrounding JSON. The old fixed
metadata ledger for eight entities and five owned scopes totals 55,712 bytes;
one extra package scope fits this additional complete fixed ledger. There are
no author postconditions, source instantiations or type-entity additions.

## Result and implementation

```text
old complete envelope            49,279,744
hidden schema and filenames     179,203,692
hidden message names             12,116,878
ordinary filename prefixes       11,899,384
routine metadata prefixes         1,048,560
additional dependency tokens        943,872
extra package outer metadata         65,536
TOTAL                           254,557,666
allocation (256 MiB)            268,435,456
headroom                         13,877,790
```

Set `Silver_Library_Reports.Max_Report_Length` and the shared
`Silver_Platform.Max_File_Length` to `268_435_456`. Keep one library-level
buffer, not one per original unit. The bounded offset arithmetic remains
below the 32-bit Natural ceiling but requires affected native contracts to be
checked at the new constant. Do not raise source budgets or add a new arbitrary
state/call-product admission cap.

Test recipe: retain the old `subprogram_envelope()` assertion, add this package
sum, independently enumerate the two small integer maxima, assert the 526-byte
hidden schema plus fixed dot/index margin fits 768, and check both configured
bounds. These arithmetic/schema tests guard the ledger, not producer correctness
or complete obligation discharge. Boundary reader tests should use the new
configured capacity, preserving independent runtime/null limits.

## Corroborating evidence scope

The [retained producer and mutation packet](evidence/bounded-library-packages-416-20261122/report-policy/README.md)
contains both probes' original units and reports. The first uses 1,381 original bytes.
Managed native probe `20261122T132325-ae27f95d774a` produced indexed package and
Main reports from unchanged original files. Three checks passed (two function
termination and one explicit output initialization), with ten advisories.
The local-warning probe uses 1,716 original bytes; managed probe
`20261122T132803-357d99db9c13` passed the same three checks with twenty advisories,
including body-local diagnostics and internal hidden outputs.

The native audit smoke retained in that packet passed eleven positive
and negative cases in `20261122T133535-ab4e5a7907bc`. The source-derived metadata
adapter then passed its canonical focused final-policy run
`20261122T133802-76f66a8b57a9`: 22 entities, 42 flow and 67 proof checks, automatic
eight workers on Linux x86_64. The larger auditor and projection contracts still
require canonical focused checking after the bound change.

## Inspected producer input identities

| File | SHA-256 |
| --- | --- |
| `flow-analysis.adb` | `10dab62c866ca03c5fd9dfefc2f70ea348797f18fb4703ffa69be1ceb9ff9c94` |
| `flow-control_flow_graph.adb` | `d6d903a8f15e645e1de51c2b74c8b61288885b34c88e9b2ac1f5469a801684b7` |
| `flow_error_messages.adb` | `b4ac784251b8cd4ea82dddabbc5e75edb2d0c2e838a7e4fc838461f23b06b7b9` |
| `flow_types.adb` | `8e123ecb1fe31bed685cc087caa458876f60ee6c6c5cdcc529bdd55fd9ec0cf9` |
| `gnat2why-assumptions.adb` | `c8ad7264625b572c6405319d599a9381c2cc1000dc51dea1e06e4301f54d01cf` |
| `gnat2why-expr.adb` | `750ed73091af62c0b522077c2e59e10f496b91a4bee323b3b822fba15094dd14` |
