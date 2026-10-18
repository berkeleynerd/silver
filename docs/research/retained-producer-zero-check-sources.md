# Retained producer: concrete sources with no Main backend tasks

Source-derived component for [#119](https://github.com/berkeleynerd/silver/issues/119),
2026-10-18, Linux x86_64. This joins two actual admitted source shapes to exact
Main backend counts. It does not use a guessed allowance for the number of
formulas or identify a retained-artifact count with a universal bound.

The inspected SPARK source is revision
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`, in the previously retained
[frontend source archive](../evidence/unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz).
The existing source-to-installed-tool premise remains. The
[offline evidence](../evidence/retained-producer-zero-check-sources-20261018/README.md)
pins the input files, source fixtures and decisive guards. No compiler,
GNATprove, Why3, solver or Lean execution was performed for this result.

## The launch guard is before Why3 conversion

`Do_Generate_VCs` reads `Old_Num := Num_Registered_VCs_In_Why3`, constructs the
entity's native Why tree, and calls both `Print_GNAT_Json_File` and
`Run_Gnatwhy3` **only** when the registered count has increased
(`src/why/gnat2why-driver.adb:507–610`). The entity-selection wrapper runs this
for analyzed entities and skips imported entities outside analyzed files
(`:1341–1375`).

`Register_VC` increments that counter only when `Present_In_Why3` is true.
`Register_VC_Entity` inserts an entry into the separate entity/check-set map;
it does not increment the counter
(`src/why/gnat2why-error_messages.adb:1342–1375`). Empty check sets are marked
proved separately (`:475–485`). Native GNAT2Why construction and flow reporting
still happen when the launch guard is false.

Consequently a source proof of zero new registered Why3 checks gives a stronger
and simpler join than a hypothetical SP/WP estimate:

```text
new registered Why3 checks = 0
=> no per-entity .gnat-json file and no gnatwhy3 launch
=> emitted Main backend tasks G_Main = 0
=> Main backend response records R_Main = 0
=> Main solver launches and Main raw Why3-response bytes = 0.
```

Here the zeros describe the absent backend invocation. They do not assert that
the final `.spark` report is empty, that all native allocation disappears, or
that the raw-response schema has a zero-byte serialization for an invoked
process. No Why3 formula is passed to the converter on this path.

## Null source

The exact 64-byte fixture is:

```ada
procedure Main is
pragma SPARK_Mode (On);
begin
null;
end Main;
```

Silver first tests `Silver_Profile.Accepts`, and makes the output-profile test
conditional on that rejection (`src/silver.adb:449–450`). This fixture takes
`Output_Mode = False`. The project then names only `main.adb` in `Source_Files`,
and library capture/evidence checks are conditional on output mode
(`:107–110,320–321,356–357`). Thus this fixture does not select Silver's fixed
library verification processes merely because the Silver executable itself
depends on those libraries.

The Main-only producer path has these exclusions:

| Part | Why no check is registered |
| --- | --- |
| Source `null` | `N_Null_Statement` belongs to `N_Ignored_In_Marking`, hence `N_Ignored_In_SPARK`; statement translation returns `Void` (`src/spark/spark_util.ads:69–111`; `src/why/gnat2why-expr.adb:29498–29518`). |
| `SPARK_Mode` | The explicitly enumerated ignored pragma arm returns `Void` (`gnat2why-expr.adb:28195–28276`). |
| Statement-list wrapper | It adds a location label and sequence entry; the extra assertion route requires an Assert_And_Cut pragma, absent here (`:30068–30215`). There are no handlers or finally statements. |
| Body wrapper | It translates the declarations and handled statements, appends a synthetic return exception, catches that exception and finalizes locals (`gnat2why-subprograms.adb:5840–5905`). No owned locals exist; the return/handler are structural nodes without a check label. |
| Preconditions | Empty `Compute_Spec` returns Boolean True. Main's precondition helper explicitly returns `Void` when there is no precondition location (`gnat2why-util.adb:644–698`; `gnat2why-subprograms.adb:4649–4729,5362–5381`). `New_Ignore` itself does not register a VC (`why-gen-progs.adb:199–213`). |
| Postconditions | No postcondition location makes `Post_As_Pred` return `Why_Empty`; no refined postcondition or inline/logical-equality annotation exists (`gnat2why-subprograms.adb:5033–5107,5302–5357`). |
| Contract/exit cases and warnings | The contract-case lists and guard maps are empty; no Exit_Cases pragma exists. Inconsistent-pre/post warning helpers return `Void` for absent locations (`:2443–2570,3005–3020,5426–5505,5641–5701,6201–6260`). |
| Parameters, globals and type invariants | Main has no formals, global reads/writes or result. Input/moved-property traversals and output-initialization/invariant traversals therefore have no objects to check (`:1283–1353,1826–1934,4958–5030`; `gnat2why-expr.adb:14615–14858`). |
| Priority | The default priority expression is eagerly translated in the term domain, but the check constructor is called only in the empty protected-object locking loop (`gnat2why-subprograms.adb:513–862`). |
| Other entity checks | There are no declared types, nested subprograms or packages. Main has no variant, dynamic termination condition, borrowing, ownership, dispatch or LSP route. Imported predefined entities are not independently analyzed Main entities. |

The enclosing assembly is given at
`gnat2why-subprograms.adb:6201–6270`; the
[earlier wrapper derivation](retained-producer-capacity.md#enclosing-main-theories-and-vc-wrapper)
accounts for its native allocations, including discarded empty-contract work.
None of the selected paths registers a Why3 VC. The launch guard therefore
proves **`G_Main = R_Main = 0`** for this source. Since the source selects no
Silver library units, its whole selected GNATprove invocation has no Why3 or
solver subprocess to capacity-bound. Native frontend/flow state, orchestration,
final report storage, compilation and environmental assumptions remain separate
obligations; this result does not complete #119 for this source by itself.

## Literal output source

The second exact fixture is 95 bytes:

```ada
with Silver_IO;
procedure Main is
pragma SPARK_Mode (On);
begin
Silver_IO.Put ("a");
end Main;
```

This adds a static String literal, one public procedure call, its five global
effect roots and the fixed output-library project selection. The following
source paths preserve zero Main registered checks:

1. The frontend literal subtype has static lower bound 1, length 1, Character
   elements and parent Standard.String. The literal translator defines its map
   by axioms, then returns a call. In the program-domain range-check block,
   the static known-bound arm checks the source values internally and leaves
   `Checks = True_Pred`; the only registration site is guarded by
   `not Is_True_Boolean (+Checks)`
   (`gnat2why-expr.adb:30221–30666`). Here the last index is exactly 1 and lies
   within Positive's known upper bound. These internal Ada assertions are not
   registered source VCs.
2. The immutable `in String` formal translates the actual once at its expected
   type (`:4540–4601`). `Insert_Checked_Conversion` asks
   `Check_Needed_On_Conversion`. The literal's target is its unconstrained
   parent Standard.String, so the parent-type arm returns False
   (`why-gen-expr.adb:1518–1587`; `spark_util-types.adb:493–535`). No predicate,
   relaxed-initialization or unconstrained-update exception applies. All array
   check constructors are guarded by that false `Need_Check`
   (`why-gen-expr.adb:1116–1155,1298–1340,1449–1497`). Reconstructing the String
   record still allocates nodes, but adds no check.
3. Put has no explicit, classwide or inherited precondition. Those are exactly
   the conditions read by `Why_Subp_Has_Precondition`
   (`why-inter.adb:1639–1652`), so the procedure translator uses ordinary
   `New_Call`, not `New_VC_Call` (`gnat2why-expr.adb:21128–21152`). The
   [selected-call derivation](retained-producer-calls.md#reachable-branches)
   excludes the exceptional/exit, type-invariant, variant, dynamic termination,
   dispatch, ownership and reference-copyback check routes. Put's postcondition
   is a callee guarantee, not a Main assertion to establish here.
4. Main's four concrete output objects are ordinary String, Natural and Boolean
   values with no type invariant; opaque File_System state is skipped by the
   invariant traversal. `Check_Type_Invariants_For_Subprogram` asserts only
   non-True invariants (`gnat2why-expr.adb:14615–14858`). Input dynamic properties
   are assumptions. There are no formals, owned outputs or Main postcondition.
5. If the generated literal subtype is visited as an analyzed type,
   `Generate_VCs_For_Type` has no applicable default/private-view, iterable,
   access-subprogram, user-equality, aggregate-annotation or ownership check and
   returns immediately (`gnat2why-types.adb:1108–1151`;
   `spark_util-types.adb:835–873`). No new backend entity is introduced by the
   literal definition theory alone.

The unchanged null-source wrapper exclusions then give **`G_Main = R_Main = 0`**
for this useful source as well. The same argument composes for straight-line
sequences of Put/Put_Line calls whose arguments are static, valid ordinary
String literals, plus null statements, with no local declarations or other
constructs. Each literal and call contributes zero new Main VC registrations;
the enclosing global effect set remains the same five roots. This is a shape
result within the language and source-size constraints, not authorization to
admit a new restricted language or to discard other currently admitted forms.

Output mode nevertheless lists all six fixed library source files and invokes
GNATprove with `-U` (`src/silver.adb:107–124`). Even a single Put thus retains the
fixed library translations summarized in the
[composition evidence](../evidence/retained-producer-composition-20261018/result.json):
the retained fixed route has three Why3 files for Silver_Arguments and two for
Silver_IO, and no Why3 file for Silver_Output_Libc or Silver_Runtime. This
source result does **not** derive those five files' terminal task counts from
their source. The fixed library source-to-formula/transform/counter/solver joins
remain necessary before this complete output fixture can establish feasibility.

## Consequence for the remaining work

The null source supplies an exact zero-backend composition; literal output
removes variable Main formulas from a second concrete path. Neither needs a
worst-case SP/WP or splitter formula to establish its Main task count. For the
output path, the next producer join is therefore the **fixed selected library
bodies and their dependency contexts**, rather than another conditional Main
goal-headroom inequality. Programs with assignments, arithmetic checks,
branches or loops still require the previously developed transfer bounds.

Keep these domains distinct: native construction (even when discarded), raw
upstream responses of any launched fixed process, projected Silver reports,
Why3 lifetime identifier/hash-cons counters, each solver's own representations,
and environmental resource cost. A zero Main backend count removes only the
corresponding Main objects and counters; it supplies no aggregate-RAM admission
rule and pays none of the fixed-library domains by proxy.

An independent focused source review checked the driver/counter join, wrapper
assembly, generated-type early return, static literal check and parent-type
conversion against the pinned sources. It found no material discrepancy. This
was a source sanity review, not an exhaustive re-verification of all earlier
selected-call exclusions, and ran no compiler or proof tool.
