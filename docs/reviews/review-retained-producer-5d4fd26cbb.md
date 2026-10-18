# Producer and parenthesis component review

2026-10-18, Linux x86_64, for
[#119](https://github.com/berkeleynerd/silver/issues/119).
Frozen target: `5d4fd26cbb`; producer delta since the previously reviewed
`0cd5b74cc7`. Later repair checked separately: `b6061a8458`.

**One low evidence finding, L1, corrected and independently rechecked. No
remaining material finding in the reviewed additions.** The producer's new
loop/frame, generated-declaration, entity/type, representation-attempt and
frontend-caller arguments are supported by the inspected sources under their
stated restrictions. The parenthesis bounds remain sound despite the original
inventory omission. These are component results: the complete capacity rule
and the installed producer's exact source identity remain unestablished.

Scope is the added portions of
[the producer derivation](../research/retained-producer-capacity.md) and
[the auxiliary parenthesis section](../research/retained-table-capacity.md#auxiliary-parenthesis-counts).
The older producer components retain their prior reviews. Later native-expansion
work is separate and receives no verdict here.

## L1 — Parenthesis inventory missed an aligned call

At the frozen target, `derive.py` searches for the exact string
`Set_Paren_Count (`. It therefore omits this valid call at pinned
`gcc/ada/atree.adb:2273`:

```ada
Set_Paren_Count     (Old_Node, Old_Paren_Count);
```

The reported nineteen calls plus two declaration/body headers should be
**twenty calls plus two headers**. A separate case-insensitive,
whitespace-tolerant scan of the complete Ada tree found all 22 sites; the
retained top-level inventory contained 21. This is an evidence completeness
defect, not a changed capacity result: the omitted `Rewrite` call restores an
old count and creates no increment beyond the existing value bound.

**Verified repair:** `b6061a8458` uses `\bSet_Paren_Count\s*\(` with case
insensitivity, including arbitrary spaces and newlines, regenerates the
inventory and updates the report. Executing that commit's exact script against
the pinned tree reproduces its corrected output byte-for-byte, and its 22
locations equal the independent full-tree scan. The repair changes no production
or proof source and does not alter the capacity formulas.

## Producer checks

The six retained producer outputs reproduce byte-for-byte. The source capture
checks 35 complete SPARK files against the retained archive. The new frontend
inventory checks all 2,319 `.adb`/`.ads` files against the prior complete GCC
manifest; an independent case-insensitive scan confirms all 37 constructor/helper
sites. Local review evidence and commands are
[retained separately](../evidence/review-retained-producer-5d4fd26cbb/README.md).

### Loop and frame costs

Checked ordinary range-loop setup, its program/term endpoint callers, the
eager unused iterator dereference, the range-index invariant, update/init/exit
expressions and `Wrap_Loop` against the generated Why schema. In particular,
the program-domain conjunction calls `Andb`; replacing its cost with the
smaller predicate connection would be incorrect. The report charges the
proper alternative.

The fixed allocation total `(69,23,43)` is consistent with the individual
builders and their list fields. Independent occurrence reconstruction gives
`Wrap_Loop = 105` and the complete fixed loop overhead **267**, keeping the
body, endpoint translations and frame snapshots separate. It includes the
otherwise filtered empty sequence/Void references and both potential warning
wrappers. `--no-loop-unrolling` prevents numeric trip counts from repeating
the source-body translation. An ordinary explicit range stays `N_Range`, so
the additional subtype-indication check is absent.

The four frame rows correctly distinguish `Entire_Object` from `Not_Written`.
`Only_Vars` defaults to true, preventing an uncharged bounds-preservation
branch for entire-object writes. Snapshot setup and binding still occur when
preservation simplifies to true. The String row includes the eager split-type
construction during the otherwise identity conversion. Ordinary roots have
no initialization/validity flags or borrower branches.

The four concrete Silver_IO globals fit one Character String and three scalar
rows. Checked both the direct abstract-state and expanded-constituent paths
for Ada.Text_IO.File_System: abstract state is not an object, and the selected
non-SPARK refinement is represented by magic strings. This supports its
exclusion from this frame helper only; call effects, symbols and dependency
translation remain separately charged. Repeated writes do not multiply the
set of roots.

### Generated declarations and entity passes

`Check_Scalar_Range` allocates each term endpoint once but serializes it twice,
and can additionally translate each source nonstatic endpoint in program
domain once. The stated `(17,7,10,69)` wrapper and endpoint formula include
both optional ignore/sequence wrappers. The static empty-or-in-range case
returns shared Void; the final location allowance `(1,0,0,5)` is sufficient
for the classified static subtype declarations.

The action preparation and binding passes each call `Mk_Item`; their stated
eleven-node allowance includes both calls. Declaration-list `Append` flattens
only the immediate statement sequence, so the `2d+1` element allowance and
the mixed source/generated list formula are consistent with these declaration
families. Their additional source-location wrappers are distinct from each
declaration's internal label.

The driver has single entity passes for registration, translation and
completion. Its hidden-global pass does not recreate Main-local object
definitions. The report's object maximum deliberately combines the independent
largest registration and theory rows, and separately charges loop-scope
exception theories. The frontend type-family coefficients and close counts
match the already priced type rows; the static Integer row dominates the
dynamic/empty index alternative.

`Create_Rep_Array_Theory_If_Needed` has one external caller, in `Translate_Type`.
The public overload retries the second representation only for init wrappers,
excluded from these Main types. Ordinary array helpers look up the maps rather
than invoking that constructor. Thus the attempt count follows array type
identities, with at most one rank-one Character cache miss; it does not need
a multiplier for every source expression or read. `M <= B_N` is also valid
under the report's explicit requirement that `B_N` includes cached module
creation even when triggered from a close; excluded include nodes are not
module nodes, so this substitution is not circular.

### Captures and Itype-reference exclusion

The scalar capture path relocates its expression into the new constant and
inserts that declaration before the loop. A for-range parent path does not
meet the while-condition or short-circuit-right-operand action branches.
The GNATprove dispatcher also bypasses ordinary transient-scope postprocessing.
This supports one program plus at most one term translation of the captured
initializer, followed by two generated leaf reads, rather than replaying the
original source expression at every endpoint use.

All 37 inventoried Itype-reference constructor/helper sites were checked
against the stated path exclusions. Their relevant routes require package
scope, access/record/concurrent/class-wide/modular-index families, native
array expansion or slices, none of which arises from ordinary Main under
this light-expansion grammar. The String `/=` delegation only rewrites to
`not (=)`. Raw node-kind mentions reveal no additional direct construction
route. The **zero Main Itype-reference translation count** is consequently
supported under this source/grammar premise; it does not exclude references
inside fixed library processing or native expansion.

## Parenthesis bounds and source-identity recheck

The auxiliary parenthesis table searches for an existing node identity before
appending. A reset leaves an old entry but cannot cause a second entry for that
identity. Copying may add a different identity, covered by cumulative node
allocation/copy events. Only four parser sites increase values; the other
sixteen calls copy, restore, reset or decrement them. The eight-byte
entry, initial ten-entry allocation, 200-percent increment and source-nesting
value bound agree with the pinned declarations. The result still requires the
whole-phase event count and does not cover parser stack capacity.

The existing source-identity verifier and all manifest hashes were rechecked
locally without another upstream search. They reproduce the recorded release,
recipe/job and installed-metadata relations, including the negative result:
the historical floating SPARK input is unidentified. This is a consistency
recheck of the earlier report, which this reviewer authored, not a claim of
independent authorship for that investigation.

No compiler, GNATprove, Lean, full suite, clean rebuild, kernel replay, macOS
validation or near-limit run occurred. Only this review and its evidence were
added in the review worktree. No reviewed source/report, issue, board, harness
goal or GitHub state was changed. After the separately verified L1 repair,
these additions can remain conditional inputs to #119; they do not unlock
expanded admission or establish completion of that package.
