module

public import Silver.ApplicationPackageDeclarationsControl

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.Control
open ApplicationNative ApplicationPackageProcedure

variable {Fn : Ty → Type}

/-- Observing the result of a statement commutes with all three continuations,
including early returns from a nested declarative block. -/
theorem Statement.eval_map (functions : Calls Fn) (procedures : ProcedureCalls) (backing : Backing)
    (statement : Statement Fn) (locals : Locals) (next returned exited : Locals → α) (observe : α → β) :
    observe (statement.eval functions procedures backing locals next returned exited) =
    statement.eval functions procedures backing locals (observe ∘ next) (observe ∘ returned) (observe ∘ exited) := by
  induction statement generalizing locals next returned exited with
  | nothing | returned | exited | assign | resize | call | annotate => rfl
  | exitWhen test => simp only [Statement.eval]; split <;> rfl
  | choose test yes no ihYes ihNo =>
    simp only [Statement.eval]
    split <;> first | apply ihYes | apply ihNo
  | sequence first rest ihFirst ihRest =>
    dsimp only [Statement.eval]
    rw [ihFirst]
    congr 1
    funext current
    exact ihRest current next returned exited
  | block declarations body ih =>
    dsimp only [Statement.eval]
    exact ih _ _ _ _

def Transfer.resume (next returned exited : Locals → α) : Transfer → α
  | .next store => next store | .returned store => returned store | .exited store => exited store

theorem Statement.resume_step (functions : Calls Fn) (procedures : ProcedureCalls) (backing : Backing)
    (statement : Statement Fn) (locals : Locals) (next returned exited : Locals → α) :
    (statement.step functions procedures backing locals).resume next returned exited =
    statement.eval functions procedures backing locals next returned exited := by
  simpa only [Statement.step, Function.comp_def, Transfer.resume] using
    (Statement.eval_map functions procedures backing statement locals Transfer.next Transfer.returned Transfer.exited
      (Transfer.resume next returned exited))

end Silver.ApplicationPackageDeclarations.Control
