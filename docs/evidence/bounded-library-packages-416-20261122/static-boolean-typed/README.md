# Static Boolean typed helper checkpoint — 2026-11-22

Focused Linux x86-64 check `20261122T165852-065ddd016cab` passed
`Silver.StaticBooleanNative` and its dependencies with a fresh axiom audit of
12,579 declarations, using only propext, Classical.choice and Quot.sound.
It used two Lake workers and two threads per process under the shared eight-CPU
allocation, reused matching objects, and took 21.884 seconds in total
(6.870 s build, 4.755 s audit). No clean rebuild or kernel replay was run.
Selected proof role: GPT-6 Astra Max; live settings and whole-team token/cost
measurements are not independently exposed.

`StaticBooleanModel` records all four native helper equations with arbitrary
imported/recursive calls. Its exact loop relation proves unique results and
termination when the recursive reader preserves the native finite cursor bound;
there is no arbitrary fuel cutoff. `StaticBooleanNative` supplies typed operands,
local declarations, assignments, branches and renderers for complete Primary and
Factor bodies, and proves their interpretations equal those equations for every
import/call/frame argument. Render precedence checks also pass.

This is a typed-model checkpoint, not actual-source correspondence. Relation and
condition-loop typed bodies, complete contract/domain interpretation, concrete
import witnesses, source-token binding and the evaluator-to-source reading
argument remain outstanding. In particular, success of the Static reader alone
does not assert Predicate admission under arbitrary colliding scalar/Boolean
tables; Package_Object_At also checks Boolean_Initializer_After, and the final
source argument must connect those readers without narrowing native domains.

Earlier focused failures remain in the managed ledger. They comprised incomplete
shared prerequisite snapshots, optional-argument eta-expansion, local tactic
normalization and typed-constructor binder/layout errors. The final shared
prerequisites match the lead's snapshot; no native source or declared domain was
changed by these proof repairs. Compressed evidence retains exact tools, inputs,
module closure and producer output.
