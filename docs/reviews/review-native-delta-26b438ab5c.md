# Native attribute, declaration and action delta review

2026-10-18. Refs #119. Frozen target: `26b438ab5c`.

No material finding in the reviewed delta. The new attribute, conversion,
declaration, placement and Boolean action-wrapper transfers hold under the
stated local premises and existing selected-language/type premises. This does
not close all native concatenation paths or derive a new admission rule.

## Scope and method

This review covers the additions after the previously reviewed `cbcd679320`
in [retained-native-expansion.md](../research/retained-native-expansion.md)
and its evidence:

| Commit | Scope |
| --- | --- |
| `61449fddd9` | Generated ordinary String First/Last/Length |
| `6883883936` | Syntax lists in range-check bound copies |
| `d151c1d5cb` | Generated same-type Integer conversions |
| `e97a3d78f4` | Collected scalar constant declaration skeleton |
| `822ccb1333` | Ordinary initial action placement |
| `26b438ab5c` | Boolean expression-with-actions wrapper |

Selected paths and supporting predicates were inspected in GCC Ada commit
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, from the retained source directory
`/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada`.
The submitted checker verified 52 sources and reproduced its local envelope
byte-identically, SHA256
`32397ecddd44e2d6e7d0a73194dbddc520bf6e873aebf8baaaec3758b72f629b`.
An [independent checker](../evidence/review-native-delta-26b438ab5c/check.py)
and [result](../evidence/review-native-delta-26b438ab5c/result.json)
retain selected source hashes, direct attribute sites and arithmetic sums.
Neither checker infers control-flow reachability or proves shape premises.

No compiler, native stress program, GNATprove, Lean, full suite or tool rebuild
was run. Existing reports, source, tools, issues and board state were unchanged
by this review. The installed producer's exact source identity remains a
separate unresolved premise.

## Attributes, copies and conversions

For the specified resolved/frozen ordinary String prefixes,
`Get_Actual_Subtype_If_Available` returns an existing subtype or Etype. It is
not the separate allocating actual-subtype constructor. With no dimension
argument, Set_Bounds simply retrieves the index range; the String-literal
subtype branch that manufactures a high bound is explicitly excluded.
The dereference helper does not insert a new dereference when the prefix
already has String type. Frozen referenced entities/types exclude additional
freezing work along this transfer.

First/Last semantic folding and the surviving native attribute-to-bound-name
rewrite are mutually exclusive. Each fits two ordinary nodes and one growing
event, with no new Uint. Unconstrained objects without a constrained actual
subtype return from evaluation without folding; native ordinary attributes
stay for the backend.

Length has a less obvious double path. A known-bounds fold computes
`1+(Hi-Lo)` but does not return. It subsequently calls Compile_Time_Compare
and may fold again using Diff+1. The report charges both folds, the first
subtraction/addition's three Uint appends, the later addition and the complete
comparison envelope. Hence `20*A+4` nodes, two growing events and `80*A+64`
Uint appends are sufficient. The selected native expansion has no packed,
access or minimized-overflow route, and its universal-attribute check returns
before allocation for the artificial/suppressed case.

The direct emitter contains six First/Last/Length attribute constructor sites.
Two require excluded shapes: the Character-operand First at line 2864 and
the constrained root-array First at line 3141. Standard String's active sites
give at most `n+2` First/Last attributes and n Length attributes. Summing the
local transfers therefore yields `20*n*A+6*n+4` ordinary nodes and `3*n+2`
growing events, with n copies of the Length Uint term.

The range-check extension correctly introduces a separate syntax-list count l.
An analyzed scalar conditional owns an Expressions list even when it has no
actions or owned type/entity. Copying both bound trees twice adds `2*l` list
headers, as well as the existing `2*b` ordinary nodes. This changes the class
from the earlier no-list premise; it does not contradict that earlier local
bound. The same list addend propagates into the suppressed subtype transfer.

For same-type Integer conversions, Analyze uses the existing type mark and
already analyzed child. Scalar suppression stops range/overflow check
construction. Same specific Integer type excludes the three simplification
cases. Semantic folding reads the existing integer value, or native expansion
removes the surviving conversion by relocation and Rewrite. Those routes are
mutually exclusive and fit the two-node/one-growing bound. The two direct
last-operand conversions therefore have the stated four-node/two-growing
initial-pass allowance after their attribute children are separately charged.

## Declaration skeleton and placement

The direct declaration count is `n+(n-1)+1 = 2*n`: operand lengths, aggregate
lengths and the selected lower bound. Defining entities/names and input syntax
were already in the direct emitter envelope.

The zero-additional-allocation declaration skeleton does not require
Assignment_OK. Native Check_Initialization's limited and
`not Expander_Active` scalar cases do not apply to Standard Integer. After
charging the initializer's analysis, the remaining semantic path only updates
completion, validity and type fields. Suppression with no pending range check
returns before numeric range analysis; identical entity-initializer types
stop In_Subrange_Of at its identity guard. Constants do not receive
Current_Value from the variable-only branch. The stated shape excludes all
native array, controlled, accessibility, renaming, return-object and delayed
freeze additions.

The ordinary Insert_Actions placement paths move an existing list: before
the nearest statement/declaration list member, into an unanalyzed
short-circuit's right-operand actions, into an unanalyzed conditional branch,
or into elsif condition actions. Existing nonempty action lists are spliced;
no new list header is allocated by movement itself. List analysis is an
explicit separate charge. Kill_Current_Values and Kill_Checks clear existing
fields/records rather than appending. The excluded transient, record and
already-analyzed expression paths explain the local zero-allocation claim.

## Boolean expression-with-actions wrapper

The direct wrapper costs at most three ordinary nodes: EWA construction,
relocation of its expression and the saved original. Its Rewrite adds at most
one growing event. The existing actions list is moved, not copied.

Analyze_Expression_With_Actions creates a fresh E_Block entity/name even for
generated code. Push_Scope may add one Uint for depth+1 and one live scope
stack entry. It initializes pending-list fields to empty. With already
analyzed actions/child and the stated empty pending-freeze/use state, End_Scope
and Pop_Scope restore fields and visibility without further allocations.
The scope charge is a peak live-stack increment, not one permanently retained
entry per wrapper. The generated Resolve path avoids declare-expression
hidden maps.

If a known Boolean expression and suitable static actions let resolution fold
the wrapper, the replacement costs at most two ordinary nodes and one growing
event. Otherwise a non-name Boolean expression with actions is captured in a
new constant. Its declaration, type occurrence, relocated initializer, final
flag occurrence and possible saved original cost five ordinary nodes, with
one entity/name and one growing event. The appended declaration uses the
existing actions list. These alternatives justify the total envelope of eight
ordinary nodes, two entities/names and two growing events.

The capture's semantic and native range checks need not be suppressed:
Determine_Range uses Standard Boolean's existing 0..1 bounds for comparisons,
short-circuit/not, calls and EWA nodes. It does not recursively inspect their
Integer/String children. Known literal/name chains reuse existing enumeration
positions. The interval is contained in the target Boolean range, so both
checks return without constructors or new numeric values. Native
Check_Initialization is again nonlimited and expansion-active. A Boolean
function call is not the explicit-dereference shape required by the captured
function renaming helper.

The final flag occurrence is a bound constant name; Eval_Entity_Name updates
staticness and returns. Its artificial reference does not create source
visibility records, and it has no variable/renaming/Current_Value expansion.
The finalization predicate stops at false Needs_Finalization for the ordinary
Integer/Boolean/String or access-to-String action objects. It consequently
does not invoke the allocating transient worker. This does not exclude an
enclosing secondary-stack placement obligation.

The current language also makes the enclosing short-circuit result type
Standard Boolean, so the wrapper route's final Adjust_Result_Type is a no-op.
Making that type premise explicit beside the local EWA transfer would make
the paragraph easier to reuse independently; this is a clarification, not a
count defect under the report's selected-language premises.

## Remaining limits

These are specified local transfers. First analysis of children/actions,
nonfrozen copied types, enabled plain-storage checks, transient placement,
source-to-shape derivation and compilation-wide reanalysis multiplicity remain
additional. Wrapper stack backing-table growth and Uint cache/digit/working
storage need their stated separate representations. The result does not close
native compilation, backend/linker capacity or installed-source correspondence,
and does not unlock broader Silver admission by itself.
