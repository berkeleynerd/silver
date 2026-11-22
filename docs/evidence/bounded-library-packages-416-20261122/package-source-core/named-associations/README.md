# Native named associations and state aggregates

Linux x86-64 focus `20261122T181705-ff3c9b6fe7f8` passed the declaration laws and
package-name equations, freshly auditing 20,158 declarations with only the three
approved foundations. Allocation was two workers and two process threads under
the shared eight-CPU limit.

`Expr.namedApp label function argument` retains the original named association.
The structural guard rejects malformed or duplicated labels and positional
arguments after a named association. `Expr.namedCorrect` separately compares each
label with `FunctionParameters` at the actual call depth; this prevents a curried
positional meaning from being assigned silently to reordered named actuals.
Source interpretations using named associations must check this predicate and
bind the formal-name table to the actual callee headers. Declaration, Command
and Body traversals retain the check throughout nested expressions.

The fixed state-declaration aggregate renders all nine native named fields and
maps them to the corresponding model fields. The extension also includes mode
equality, fixed-state-set inequality and eager Boolean `or`; eager and short-circuit
logical chains have separate syntax checks. Native fixed-array shape, discriminant
consistency, actual type/header bindings and complete source interpretation remain
required at integration. This result is focused proof evidence, not complete
package capability assurance.

The first attempt found a documentation-comment placement error and missing
result-type annotations in two negative controls; both were repaired before this
successful check. No native source changed.
