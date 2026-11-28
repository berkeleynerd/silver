module

public import Silver.ApplicationNativeCommands

@[expose] public section

/-! Universal local-storage and scope laws used by source interpreters. No
uninitialized scalar receives a chosen numeral or Boolean value. -/
namespace Silver.ApplicationNative

variable {Fn : Ty → Type}

theorem restore_current_binding (locals : Locals) (ty : Ty) (name : String) :
    locals.set ty name (locals ty name) = locals := by
  funext requested key
  by_cases same : ty = requested
  · subst requested
    by_cases named : key = name
    · subst key
      simp [Locals.set]
    · simp [Locals.set, named]
  · simp [Locals.set, same]

theorem restore_current_bindings (locals : Locals) (ty : Ty) (names : List String) :
    names.foldl (fun current name => current.set ty name (locals ty name)) locals = locals := by
  induction names with
  | nil => rfl
  | cons name rest ih =>
      simp only [List.foldl_cons, restore_current_binding]
      exact ih

theorem uninitialized_numbers_arbitrary (calls : Calls Fn) (locals : Locals)
    (name : String) (moreNames spelling : List String) :
    Declaration.eval calls locals
      ⟨.number, name, spelling, false, none, moreNames, none⟩ = locals := by
  exact restore_current_bindings locals .number (name :: moreNames)

theorem uninitialized_booleans_arbitrary (calls : Calls Fn) (locals : Locals)
    (name : String) (moreNames : List String) :
    Declaration.eval calls locals
      ⟨.truth, name, ["boolean"], false, none, moreNames, none⟩ = locals := by
  exact restore_current_bindings locals .truth (name :: moreNames)

theorem implicit_procedure_formal (calls : Calls Fn) (locals : Locals) (name : String) :
    Declaration.eval calls locals
      ⟨.procedureFormal, name, ["procedures", ".", "formal"], false, none, [], none⟩ =
      locals.set .procedureFormal name {locals .procedureFormal name with typeId := 0} := rfl

theorem leave_scope_restores_local (declarations : List (Declaration Fn)) (before after : Locals)
    (ty : Ty) (name : String) (localName : name ∈ declarations.flatMap Declaration.names) :
    Declarations.restore declarations before after ty name = before ty name := by
  simp [Declarations.restore, localName]

theorem leave_scope_preserves_other (declarations : List (Declaration Fn)) (before after : Locals)
    (ty : Ty) (name : String) (otherName : name ∉ declarations.flatMap Declaration.names) :
    Declarations.restore declarations before after ty name = after ty name := by
  simp [Declarations.restore, otherName]

/-- A grouped initializer resolves all names in the incoming scope, before the
group shadows them. -/
theorem grouped_initializer_scope (scope : Scope) (writable : List String)
    (ty : Ty) (name : String) (moreNames spelling : List String) (constant : Bool)
    (initial : Expr Fn ty) :
    (Declaration.scan scope writable
      ⟨ty, name, spelling, constant, some initial, moreNames, none⟩).1 = initial.scoped scope := by
  simp [Declaration.scan]

end Silver.ApplicationNative
