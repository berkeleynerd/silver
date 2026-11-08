# Named array hiding word tree check

Focused Linux run `20261107T222609-601d7f7b780d` passed `Silver.ComposeArrayDenotations`
and `Silver.ComposeEvaluation`: 115 build jobs and a fresh axiom audit of
20,013 declarations, using only `propext`, `Classical.choice`, and `Quot.sound`.
The run used two Lake workers, 22 Lean threads per process, and Lean 4.34.1.
Accepted cached dependencies were reused; no clean build or kernel replay is
claimed. The verbatim gzip records retain the input hashes, settings and logs.

Commit `22dada06af` adds the primitive `characterTypeWord` source expression and
its exact rendering, evaluation, primary category, scope and legality cases.
Exactly three hiding-word uses in the shared array declaration tree now render
Integer_Type_Word, Boolean_Type_Word and Character_Type_Word. The existing
model/executable denotation theorems still hold for arbitrary callees.
The evaluator baseline is the lead's validated `2603f6a800` version; local
import commit `24ec196ac6` is dependency-only and must not be reintegrated.

Commit `c23e4c4163` adds the exact `Character_Type_Word : constant String :=
"character"` declaration check alongside the existing Integer and Boolean
checks. That source candidate was intentionally not a target of this run:
this worktree still has the earlier native source and whole-file shape.
After integrating native source `f102afeeb0` and the final authoritative shape,
check ComposeHelperSourceCandidate (both array body shapes and the new literal
constant), its actual-source transports, and complete final validation.
This result is partial proof-layer evidence and makes no complete native or
source-correspondence claim for the changed Ada bytes.
