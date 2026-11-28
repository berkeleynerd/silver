# Grouped and omitted-initializer declaration API

Linux x86-64 focused run `20261122T181003-7fb06463be5d` passed
`ApplicationNativeDeclarationLaws` and `ApplicationPackageNamesEquations`, with a
fresh audit of 20,074 declarations under the three approved foundations. The run
used two workers and two process threads within the shared eight-CPU allocation.

`Declaration.initial` is optional; `additionalNames` represents grouped names and
`constraint` represents a typed discriminant expression. Initializers resolve in
the incoming scope before the entire group is introduced. The syntax checks reject
omitted constant initializers, duplicate names and unsupported type spellings.
Explicit initializers may determine a discriminated object's constraint.

Omitted scalar initializers preserve every arbitrary incoming local value. The
initialization map sets only actual native record component defaults, including
partial `Procedures.Formal.Type_Id` initialization and the recursively initialized
components of `Parser_State`; it never substitutes Initial_State or Invalid_State
for an uninitialized parser state. The proof retains arbitrary active-table cells
and counts. For implicit discriminated application records, `Declaration.Allocated`
records the native allocation shape separately from component initialization.
The shared helpers restore hidden outer bindings after a nested declaration scope.

Core additions supply the three requested parse-context fields, fixed call-result
and application-call aggregates, scalar-flow indexing and the exact State_Index
quantifier. Aggregate discriminant equality and array index/capacity safety remain
explicit native representation obligations. Native type-declaration source checks
must bind the default-initialization equations at the complete source boundary.
This focused check does not establish that binding or complete #416 assurance.

Iteration first repaired record-update layout and one constructor-pattern typo.
The isolated simplifier diagnostic then showed that registering all equations of
the enlarged dependent evaluator exceeded an internal 200,000-heartbeat limit even
for a literal-zero projection; increasing the evaluator definition's heartbeat
context did not help and was removed. Fixed-tree `dsimp only` computation followed
by ordinary algebraic simplification checks the same four package-name equations
in 2.3 seconds. No helper meaning or quantified domain changed.
