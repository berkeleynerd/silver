# #237 active scalar-flow interface

2026-10-26. Selected GPT-6 Astra, Extra High; runtime setting is not independently
exposed. Read-only follow-up to `tmp/guard-proof-design.md`. Inspection and
recording interval: 00:30:52–00:37:42 UTC (6m 50s); token/cost data unavailable.
Inputs: actual parser/scalar declarations at observed guard HEAD
`12dbab608b56`, `tmp/guard-discovery/frame-proxy/src/main.adb`, and
`frame-results/20261026T002820Z/{summary.json,main.su}`. No runner, source edit,
Git/GitHub mutation or delegation; this is the only owned/written file.

**Decision: use active-length discriminated records, caller-owned executable
condition results, and leaf-only read overlays.** There is no owner-reserved
blocker. Fixed 341-cell condition vectors are ruled out by the supplied proxy:
5,552-byte frames overflow the existing 8 MiB stack for `(count, depth)` values
`(1,1988)` and `(32,1760)`. Active records passed all four supplied cases, with
96 bytes of fixed frame plus dynamic storage. Those are proxy measurements,
not parser sufficiency evidence: its recursive function returns an integer,
whereas naive parser conversion would return/copy active records recursively.

## Types and contracts

Keep metadata in `Body_Context`, with the declaration-prefix count selected in
the preceding design. Define these types privately in `silver_output_profile.adb`
(interface sketch; no new public scalar-reader API is necessary):

```ada
type Interval_Vector is array (Positive range <>) of Scalars.Interval;
type Scalar_Flow (Count : Scalar_Expressions.Binding_Count) is record
   Path : Paths.Context;
   Values : Interval_Vector (1 .. Count);
end record;
type Condition_Result (Count : Scalar_Expressions.Binding_Count) is record
   After : Literal_Position;
   When_True, When_False : Scalar_Flow (Count);
end record;
type Body_Scan (Count : Scalar_Expressions.Binding_Count) is record
   Facts : Scalar_Flow (Count);
   -- Existing Position, Target, Capacity, Assigned and Output fields.
end record;
```

**No default discriminants.** Every native local is explicitly constrained by
its active extent, for example `Condition_Result (Scan.Count)`. Do not restore a
default merely to allow `Condition : Condition_Result;`: that permits an
unconstrained object whose storage strategy can defeat active sizing.
`Count = 0` is legal; `1 .. 0` is a null Positive-indexed array, as with empty
Strings. Iterate over `Values'Range`; access a cell only after proving
`Index in 1 .. Count`. No dummy live scalar or separate zero-count limit.

Use `Valid_Flow(Context, Flow)` to assert count equality, endpoint bounds,
mutable nonemptiness/inclusion in declared ranges, immutable declaration values,
and index inclusion in captured ranges. Preserve counts on *every* result,
including failure. Replace global invalid constants with extent-aware helpers:
`Invalid_Condition(Before)` has After zero, empty path facts and copies Before's
scalar vector into both outcomes; `Invalid_Body(Scan)` retains that extent and
scalar values while clearing the usual cursor/flags/path fields. Keeping scalar
values avoids making failure violate the nonempty-mutable invariant. Mirror
these exact failure values in the Lean model.

Helpers `Join_Into`, `Replace`, `Widen_Into` and `Copy_Into` require equal counts;
their contracts specify each cell and preservation of metadata. For loop entry,
guard `Count < Max_Bindings`, allocate a distinct `Inner_Scan (Count + 1)`, copy
the widened prefix, then set the last index cell. Loop exit writes into a distinct
outer `Body_Scan (Count)` and copies/restores only its prefix. Do not assign the
inner result wholesale to the outer constrained object, or change discriminants
in place. Use simple bounded loops instead of concatenation/whole-record delta
expressions where those would create avoidable vector temporaries.

## Prevent recursive vector and environment multiplication

The present parenthesis path is `Read_Condition → Condition_Model →
Read_Relation → Read_Primary → Read_Condition`. `Condition_Model` and
`Read_Primary` each bind a result that contains two outcomes; unconstrained
record return buffers can add more. Merely making those records active-length
does not justify applying the two-vector proxy to this four-function chain.

Keep pure functional condition equations as **Static ghost models**. The
executable worker writes a caller-owned constrained result:

```ada
procedure Read_Condition_Into
  (Text : String; Context : Body_Context; Position : Literal_Position;
   Before : Scalar_Flow; Result : out Condition_Result)
-- Pre: Valid_Context, Valid_Flow, valid cursor, Result.Count = Before.Count.
-- Post: same Count, valid outcomes/cursor, and Static equality to the model.
```

Use analogous primary/relation workers. Grouping forwards the **same** output
buffer through the recursive call and then changes only After. Negation forwards
that buffer and swaps outcomes cell-by-cell, using one interval/path temporary;
it does not retain a whole extra flow. Plain forwarding wrappers own no vectors.
Inputs and outputs must be distinct under SPARK's anti-aliasing rules: never pass
`Result.When_True` as Before while also writing the containing Result.

Place short-circuit continuation in a separate `Read_Chain_Into` helper, called
only after a chain token was found. It owns one `Right : Condition_Result (Count)`
and iterates through the flat chain, retaining the existing same-operator rule.
Read RHS with Before referencing the selected **left** outcome and output Right;
then update/join the left result in place. A nested RHS chain owns another Right,
but pure parentheses never allocate that scratch. Keep the recursive ghost
`Condition_Tail` equation and prove the loop's equality to it, following the
existing executable `Expression_At`/ghost `Expression_Tail` pattern.

At the statement layer retain the current function boundary where useful, but
make executable `Body_Tail` a loop over one constrained Result, with its existing
recursive equation retained as a ghost model. This prevents every sequential
`null;` or assignment from retaining another flow vector. Conditional/elsif/loop
frames may retain the genuinely necessary alternate/entry states; count those
explicitly in the final frame calculation. Do not rely on tail-call optimization.

**Confine full scalar environments to two nonrecursive wrappers**:
`Read_Scalar_In_Flow` returns `Scalar_Expressions.Expression_Result`;
`Read_String_In_Flow` returns the existing small String `Expression_Result`.
Each builds one local full `Environment` overlay and invokes the existing reader.
Only mutable/index Bounds are overlaid; staticness and immutable snapshots are
unchanged. Give these wrappers `pragma No_Inline` under the existing GNAT toolchain
and verify the generated frame placement. Do not pass `Reading_Names(...)`
directly from a recursive predicate function: its full-environment temporary can
live in that function's frame through the later group fallback.

Neither scalar reading nor `Expression_At` calls predicate/body parsing. Thus
the wrapper's environment is released before predicate recursion resumes.
String Image reads already pass the same Scalar_Names to `Image_At` and the
scalar reader, so one String wrapper supplies all nested Images without another
overlay. Bounds, assignments and predicate operands all use these wrappers;
declaration elaboration stays unchanged. This is smaller than adding a flow
parameter to every scalar/String recursive reader and avoids duplicating their
arithmetic proofs. Existing full `Body_Context` copies in `Loop_Body` remain a
separate measured contribution; they do not occur once per parenthesis.

## Feature-local stack argument and implementation checkpoint

Use the combined source budget, not `341 × maximum_depth`. Every simultaneously
active scalar identity consumes at least 12 distinct source bytes in its
declaration or loop introduction. Each additional pure parenthesis level consumes
two distinct bytes. Therefore `12B + 2P ≤ 4096`, and the coarse product bound is
`B·P ≤ 4096² / 96 ≈ 174,763`. A naive two-vector-per-level design can consume
about 2.8 MB in vector payload alone; multiplying that by the existing forwarding
layers is precisely the risk the proxy does not test.

In the selected implementation **P contributes fixed frames, not vector payload**.
Payload is charged to semantic state owners: one initial result, one two-vector
scratch per simultaneously nested chain, and the explicit choice/loop states.
Each chain owner has its own written `or else`/`and then` (at least seven bytes),
so `12B + 7C ≤ 4096` gives `B·C ≤ 4096² / 336 ≈ 49,932`; the chain scratch
contribution is at most about 0.8 MB before layout overhead. If/elsif/loop owners
must similarly be charged to their own distinct keywords/closing syntax, with
the actual number of retained vectors taken from the implementation. Linear
statement and Boolean tails contribute only constant live scratch after the
recommended loops. These inequalities are conservative payload calculations,
not a completed 8 MiB total bound.

At the stable implementation, inspect actual compiler `.su`/generated frame
information and measure the supplied full-size sources plus mixed parentheses,
short-circuit RHS, nested choices/loops and zero-scalar cases. Account for primary
and secondary-stack return storage, baseline scalar-expression recursion,
loop metadata copies, input buffers and fixed wrapper frames. Verify the pinned
compiler passes the worker's constrained result buffer without recursive copies;
Ada semantics alone do not establish the native frame layout. Verify no full
Environment appears in a predicate forwarding frame, and that vector extents
are active counts. Distinguish malformed 4,097-byte early rejection from admitted
4,096-byte parsing. Final measurements and the source/frame accounting establish
the feature-local resource claim; proxy success alone cannot.

This representation requires actual-source correspondence for new procedure
outputs, the two executable tail loops and ghost-model equalities, plus active
array projection/append/removal contracts. It does not change language meaning,
source/operator bounds, stack settings, tool pins or deferred #119 work. Proceed
with this bounded interface; no general storage framework is required.
