module

public import Silver.ApplicationPackageImportModel
public import Silver.ApplicationNativeLoopFacts

@[expose] public section

namespace Silver.ApplicationPackageImport.Native
open Compose ApplicationNative

set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

/-- The two persistent scanner cells; block-local token readers are restored
before either loop continuation observes the cursor. -/
def cursor (locals : Locals) : Model.Cursor :=
  ⟨locals .number "position", locals .nameSpan "candidate"⟩

def withCursor (locals : Locals) (value : Model.Cursor) : Locals :=
  (locals.set .nameSpan "candidate" value.candidate).set .number "position" value.position

@[simp] theorem cursor_withCursor (locals : Locals) (value : Model.Cursor) :
    cursor (withCursor locals value) = value := by
  cases value
  simp [cursor, withCursor]

@[simp] theorem withCursor_current (locals : Locals) : withCursor locals (cursor locals) = locals := by
  simp [withCursor, cursor]

@[simp] theorem withCursor_shadow (locals : Locals) (first last : Model.Cursor) :
    withCursor (withCursor locals first) last = withCursor locals last := by
  unfold withCursor
  rw [Locals.set_commute_types _ .nameSpan .number _ _ _ _ (by decide)]
  simp only [Locals.set_shadow]
  rw [Locals.set_commute_types _ .number .nameSpan _ _ _ _ (by decide)]
  simp only [Locals.set_shadow]

@[simp] theorem withCursor_text (locals : Locals) (value : Model.Cursor) :
    withCursor locals value .source "text" = locals .source "text" := by
  simp [withCursor]

@[simp] theorem withCursor_clause (locals : Locals) (value : Model.Cursor) :
    withCursor locals value .truth "with_clause" = locals .truth "with_clause" := by
  simp [withCursor]

private theorem set_values_other (locals : Locals) (ty requested : Ty) (names : List String)
    (value : String → ty.meaning) (key : String) (absent : key ∉ names) :
    (names.foldl (fun current name => current.set ty name (value name)) locals) requested key = locals requested key := by
  induction names generalizing locals with
  | nil => rfl
  | cons name names ih =>
      simp only [List.mem_cons, not_or] at absent
      rw [List.foldl_cons, ih _ absent.2]
      exact Locals.set_get_other_name _ _ _ _ _ _ absent.1

private theorem declaration_other (calls : ApplicationNative.Calls Fn) (declaration : Declaration Fn)
    (locals : Locals) (ty : Ty) (key : String) (absent : key ∉ declaration.names) :
    declaration.eval calls locals ty key = locals ty key := by
  unfold Declaration.eval
  cases declaration.initial <;> exact set_values_other _ _ _ _ _ _ absent

private theorem declarations_other (calls : ApplicationNative.Calls Fn) (declarations : List (Declaration Fn))
    (locals : Locals) (ty : Ty) (key : String)
    (absent : key ∉ declarations.flatMap Declaration.names) :
    (declarations.foldl (Declaration.eval calls) locals) ty key = locals ty key := by
  induction declarations generalizing locals with
  | nil => rfl
  | cons declaration declarations ih =>
      simp only [List.flatMap_cons, List.mem_append, not_or] at absent
      rw [List.foldl_cons, ih _ absent.2]
      exact declaration_other calls declaration locals ty key absent.1

theorem restore_declarations (calls : ApplicationNative.Calls Fn) (declarations : List (Declaration Fn))
    (locals : Locals) :
    Declarations.restore declarations locals (declarations.foldl (Declaration.eval calls) locals) = locals := by
  funext ty key
  unfold Declarations.restore
  split
  · rfl
  · exact declarations_other calls declarations locals ty key (by assumption)

theorem restore_update (declarations : List (Declaration Fn)) (before after : Locals)
    (ty : Ty) (name : String) (value : ty.meaning)
    (outside : name ∉ declarations.flatMap Declaration.names) :
    Declarations.restore declarations before (after.set ty name value) =
      (Declarations.restore declarations before after).set ty name value := by
  funext requested key
  by_cases named : key = name
  · subst key
    simp [Declarations.restore, outside, Locals.set]
  · simp [Declarations.restore, Locals.set, named]

theorem restore_inner_cursor (calls : Calls) (locals : Locals) (value : Model.Cursor) :
    Declarations.restore innerDeclarations locals
      (withCursor (innerDeclarations.foldl (Declaration.eval calls.get) locals) value) =
      withCursor locals value := by
  unfold withCursor
  rw [restore_update _ _ _ _ _ _ (by decide +kernel),
    restore_update _ _ _ _ _ _ (by decide +kernel), restore_declarations]

end Silver.ApplicationPackageImport.Native
