# Fixed specification report composition

2026-10-24 UTC; owner-authorized #212 under #119. This first increment closes
the **report count and name domains** for the actual `Silver_Output_Libc` and
`Silver_Runtime` specification processes. It gives a useful conditional writer
and reader region. #212 remains incomplete: the two body processes, complete
path/configuration/native-service attachment and the five-report collector
composition still need work. This is not a new admission predicate.

`capacity.py` imports the accepted #193 and #194 functions unchanged. No
accepted packet, native tool, launcher, source pin or production code changes.
The one global e<=2 allowance, two save-entering callbacks and three saves are
unchanged. Physical memory, stack and disk remain separate premises.

`source-manifest.json` freezes the complete source files and accepted operands.
The SPARK revision is 42554fc241fcd1fdf08d3a2feccb3f86912acbc0; the existing
source/native behavior relation and selected GCC/target assumptions still
apply. No report observation or raw capture field supplies a new coefficient.

## Separate identity domains

| Process | Frontend A/E allocation domain | Source callables in analyzed unit | Analyzed graph upper bound |
| --- | ---: | --- | ---: |
| Silver_IO | 19,837 | package, Put_Line, Put | 3 |
| Silver_Arguments | 19,921 | package, Is_Message, Input_Is_Valid, First_Or_Default, Reject | 5 |
| Silver_Output_Libc | 18,575 | package, Put_Byte, Flush, Set_Exit_Status | 1 |
| Silver_Runtime | 1,510 | package, Argument_Count, Argument, Set_Exit_Status | 1 |

The first column is the accepted complete allocation-domain theorem, including
discarded nodes. The callable census follows the six frozen source files and
the accepted light-expansion exclusions: no generic instance, predicate, DIC,
task, protected type or inlined API body introduces another analyzed callable.
Is_Message's expression-function lowering retains one function identity.
`Analysis_Requested` first requires `Is_In_Analyzed_Files`
(`spark_util-subprograms.adb:52–89`); the latter selects only the current
compilation-unit spec/body pair (`spark_util.adb:3839–3854`). Imported runtime
bodies therefore do not add graphs. `flow.adb:1533–1590` recursively visits
the scope tree, requires a SPARK body for a subprogram, but only a SPARK
specification for a package. **The specification packages do get graphs.**

The two body rows are only this callable/graph census, not a claim that their
metadata can use those same small entity counts. Their imported callees can
enter claim tokens, and their generated locals and proof-reference constants
remain to be bounded. In particular the six global-effect identities from
the accepted incoming argument are unchanged; this packet never substitutes
them for the larger proof-reference domain.

## The two specification graph frontiers

The complete analyzed package declarations contain three imported subprogram
declarations and their aspects. Neither contains an object declaration,
executable statement, private part, package body, Initial_Condition,
Initializes, Refined_State or nested declaration body. Runtime additionally
has the one external abstract state `Exit_State`. Import, Convention,
External_Name, Global, Side_Effects, SPARK_Mode, Abstract_State, Pre and
Always_Terminates do not create a package statement that evaluates the
subprogram contract. There is no frontend assertion to insert in package
elaboration: the one Pre remains the imported Argument contract. Light mode
does not generate a predicate/DIC/contract callable for these signatures.

`Process_Statement_List` ignores subprogram declarations and freeze/itype
nodes (`flow-control_flow_graph.adb:114–148,7186–7215`). `Do_Pragma` creates
one null vertex for a nonflow pragma (`:5684–5750`); the applicable pragma
alternatives return False from `Pragma_Relevant_To_Flow` (`:8051–8362`).
Ignored nodes create no vertex. Generated nonflow pragmas are covered even
when their number exceeds the textual aspect count: each is an allocated
frontend node in the accepted A domain.

Create adds four start/helper/exceptional/end vertices and two null-export
initial/final vertices (`:8441–8460`). A package has no formal or result
vertices and these packages have no Initializes inputs (`:8464–8595`).
Runtime's one abstract state takes `Create_Initial_And_Final_Vertices`
(`:8623–8655`), giving two more vertices. The scalar abstract state is a
singleton, not an array/record expansion. The source has no Refined_State
constituents. The absent Initializes branch adds one null placeholder;
the absent initial condition and visible-list/outer joining add at most
three null joins (`:8742–8749,8925–8944,8984–9037`).

Consequently **all constructed vertices**, including later-cleared null
vertices, are at most `A_frontend+12`: at most one per nonflow pragma, the
six skeleton vertices, at most two state vertices, one placeholder and three
joins. This does not promote raw nlists values. There is one visited syntax
statement list, with at most A node occurrences. Header allocation elsewhere
in the frontend remains a separate unfinished obligation; the reporting
bound does not multiply by it. Graph container edges/copies and complete
frontend storage are not certified by this report-only result.

For reporting, use the smaller **eligible vertex** domain, V=6 for Libc and
V=8 for Runtime. `Simplify_CFG` clears every null vertex before Full_CFG is
saved (`:7962–7999,9044,9264–9265`). Restoration in `flow.adb:1492–1493` thus
does not resurrect its attributes. Clear keeps the native vertex identity
but empties its variable, call and loop sets and clears all program, assertion,
parameter, havoc, global and neverending flags (`:8388–8403`;
`flow_types.ads:803–857`). This is not a claim that All_Vertices shrinks.

The one flag that requires extra care is `Is_Original_Program_Node`:
Clear preserves it, and Find_Dead_Code tests it. It is initially False for
these null vertices; Prune_Dead_Paths explicitly ignores
`Is_Null_Node and Is_Program_Node` before assigning that flag
(`:7688–7723`). The straight-line empty elaborations have no branch, raise,
call or loop that could create an exceptional/dead path copy. Thus their
cleared vertices cannot trigger Find_Dead_Code either. All other vertex-based
emitting loops in the accepted table require one of the now-empty sets or
cleared flags. Trace searches start at a live/program/use vertex and cannot
reach the isolated cleared nodes. Their line domain is bounded by the same
six/eight eligible identities.

The initialization object set is synthetic null plus at most two facets of
Exit_State: F=1 for Libc, F=3 for Runtime. Formal objects of imported declarations
are not package locals; the `Number` formal used by the Runtime Pre belongs
only to the separate contract check below. The other imported effects are
not package elaboration calls. A_expr=0 denotes the relevant
expression/declaration/call-root domain in the accepted emitter table, **not
zero frontend nodes**. Check_Expressions traverses package declarations but
its declaration case ignores these imported subprogram declarations and
nonflow pragmas (`flow-analysis-sanity.adb:1067–1367,1463–1493`); no package
subtype constraint, object initializer or generic actual supplies a root.

Applying the accepted graph-emission equation with A_expr=0 gives

```
B_graph = 7*V*F + 12*F + 4*V + E_state + 6.
Libc:    B_graph=84,  trace attempts<=18, trace lines<=6.
Runtime: B_graph=243, trace attempts<=56, trace lines<=8.
```

This deliberately retains surplus checks, including exceptional/final-status
terms. It does not assert the actual flow arrays or warnings are empty.
The equations count attempts before deduplication and before trace-file
creation; no callback or counter allowance restarts at this boundary.

## Outside-graph checks and earlier warnings

Check_Specification_Contracts visits the three imported APIs of each selected
unit (`flow.adb:1662–1695`). All have explicit Global contracts.
Check_Required_Contracts returns on Is_Imported before looking for a body
Refined_Global (`flow-analysis.adb:7003–7010`).
Check_Constant_Global_Contracts can diagnose only an E_Constant input without
variable input (`:6836–6891`): Libc's input is the abstract File_System state;
Runtime's queries have null Global and its setter has output Exit_State.
There is no eligible constant and no classwide/handler source. These routes
produce zero messages, without assuming Global null erases proof references.

Check_Incomplete_Globals is a distinct, unfiltered translation-entity loop
(`flow_sanity.adb:257–277`). Libc's API declarations have no Pre/Post or
expression body. Runtime has exactly `Number <= Argument_Count` on Argument.
Get_Variables_For_Proof supplies its Number formal; Argument_Count has explicit
Global null and adds no object global. Proof_Context includes every formal,
so there is no missing variable (`:73–99,108–110,168–181,234–252`).
The imported type/state closure adds no additional relevant callable contract:
Interfaces.C.int is scalar, System.Address is the nondiscriminated private/
modular type, Ada.Command_Line.Exit_Status is scalar, and File_System is an
external abstract state. Marking a with-clause processes Initial_Condition,
not every declaration/body of the withed package
(`spark_definition.adb:4289–4308`); the selected specifications have no such
condition. There are no predicate/DIC/invariant helpers on these types.
This is the source dependency reduction, not a deduction from a small report.
Thus the complete outside-flow term for these two processes is zero.

The accepted incoming warning partition still applies. No analyzed package
contains a loop/assignment or an array actual/result pair, so the array
recognition and aliasing families have zero domain. **Keep** the complete
Why-allocation warning allowance, 8,714 / 7,376, for Image translation across
the imported translation prefix. Absence of source Image text alone is not
used to discard this allowance. The accepted 192-character template bound
and its no-surviving-placeholder result permit an empty serialized argument
array. Native warning location chains are not claimed to have depth one;
that separate diagnostic attachment stays open.

## Report identities, strings and composition

Each of these two reports has at most four entity identities: its package
and three declared APIs. Get_SPARK_JSON and VC generation filter to analyzed
files (`spark_definition.adb:2313–2389`; `gnat2why-driver.adb:1343–1375`).
No declared type here takes the extra type-check metadata branch. There are
no response files (accepted R/G/A/J=0), skip/Assume annotations or generated
package calls. Generate_Assumptions can register edges only for an analyzed
package/body's Generated_Calls (`gnat2why-driver.adb:1083–1117`); neither
package elaboration calls anything and imported API bodies fail that gate.
Consequently P_call=0 and claim edges=0. Allow all five Claim_Kind values for
each of the four identities, so claims<=20. A surviving flow row uses the
package FA.Spec_Entity; outside-flow rows are absent. Warning records leave
their entity empty. These cases cover the accepted nine Assumption-pool
callers and make E_report=4 independent of E_frontend.

Full_Source_Name, rather than Why Full_Name, joins Raw_Source_Name with `.`
until Standard (`spark_util.adb:2353–2365`). The explicit package/API list in
`result.json` therefore bounds the full name by 34 bytes for Libc and 30 for
Runtime. Their source locations are in the ordinary non-instantiated spec,
so metadata location_depth=1. That statement concerns these four identities,
not every source location in the process. Raw flow name components fit 19
characters (package/state/API spellings); the accepted canonical fixed-global
Common bound 760 applies to any magic form, using precisely the unchanged
fixed source/ALI domain in retained-producer-strings.md. No unpromoted name
vector or Why Full_Name estimate is substituted.

Let P bound every source/reference/auxiliary filename used by these report
rows and the report filename. The accepted additive message equation applies
to the fixed source-name spellings, which contain none of `&`, `%`, `#`, `@`:
M_flow=7894+5P. A changed source-name configuration must re-establish that
spelling premise or use the accepted unconditional fallback. The shape
continues to charge sixfold JSON escaping and twelvefold SARIF-message text
expansion. There is no tighter ad hoc serializer in this packet.

The callable composition uses the accepted array, metadata, report,
assumption_lifetime, representation and parsed_report functions. It retains
8 SPARK-status visits, 8 VC-timing visits, 20 claim conversions and every
bounded flow row, giving third-pool Finds<=2*(36+B_flow). Timing fields<=15
and timing entities<=5. No response duration or CP expression-image operand
is needed when R/G/A/J=0. Full and projected report shapes coincide.

The endpoint check establishes a **parametric useful region** for the actual
two source processes: 0<=P<=4096, 1<=native max-path<=4096 and
1<=native mmap page size<=65536 satisfy the listed writer/reader guards.
The affine pretty-byte formula and endpoint dimensions are in `result.json`.
These interval endpoints are sufficient conditions, not captured native
values or an attachment of the future common-path domain. Native max-path,
page size and all actual path roles still require their own binding.
The separate brief-flow line guard also holds over this P interval. There is
no claim here that all native warning locations or all collector/SARIF
aggregate storage fit. The full required five-report set is still mandatory.

## Prospective configuration overlay

`prospective_configuration` explicitly reconstructs the future GNATprove argv
from the accepted #194 shape, removing `--level=2`, selecting steps/time/memory
zero, adding `--counterexamples=off`, and replacing `-j0` by `-j<workers>`.
It preserves `--mode=all`, `--report=all`, `--warnings=continue`,
`--checks-as-errors=on`, all three provers, no loop unrolling, brief output
and the two compiler-forwarding arguments. It has 18 elements. Workers must
be a represented integer at least three; choosing/reserving host workers
remains separate. No existing command is mutated.

The serialization structure still follows `gnatprove.adb:719–789`: one
object directory, the actual argv, empty proof_switches, GPM_ALL and two
Booleans. The source project has no Prove.Switches attribute. The private
Why recipe from #206 cannot itself change these arguments. Configured project,
object, initial/saved cwd, generated filenames and source/runtime paths must
all be joined before using the configuration in the five-report composition.
Duration ceiling 1 remains available only under #206's exact future recipe
and startup/native premises; this packet does not invent another clock bound.

## Verification and remaining work

Run only this changed-input check:

```
python3 docs/evidence/retained-fixed-report-composition-20261024/check.py
```

It verifies complete-source identities and key source correspondences, then
checks the interval endpoints, affine arithmetic, imported guards and argv
serialization. Its small serialization witnesses check code; they are not
fixed-report evidence. The source classification above requires independent
review. It does not run predecessor checkers, a compiler, prover, capture,
native service probe or a production report audit.

Next, IO/Arguments need per-graph constructor/reference domains including
generated bound captures, quantifiers, expression-function lowering, extended
returns and imported contract references. The accepted whole-process A/E
captures do not separate those domains; no retained raw graph count is
promoted here. List-header lifetime, raw/generated name and Full_Source_Name
domains for body diagnostics, instantiation chains, expression primitives and
common paths remain explicit. Any further native capture needs a named source
relation and lead coordination; no such run is authorized by this packet.

Selected author setting: GPT-6 Astra / Extra High, as assigned by the parent;
runtime confirmation unavailable. Native host observed Linux 7.0.14 x86_64;
this work is source/Python evidence only. The packet clock was recorded at
2026-10-24 04:59:13 UTC; this is not the task's start time. Checker elapsed time
is measured in result.json. Total task elapsed time and token/cost measurements
are unavailable. Independent review and acceptance are pending at this freeze.
