module

public import Silver.ComposeStringBoundSafety
public import Silver.ComposeCharacterReading
public import Silver.StringFreezing

@[expose] public section

namespace Silver.Compose
open Bindings StringObjectBounds

/-- Lookup facts discarded by Shape: encoded slice/index bases belong to the
selected source object. They do not constrain scalar stores or flow ranges. -/
def FixedStringOrigin (names : BindingEnvironment) (target : Nat) (base : Int) : Prop :=
  ∃ info, names.get target = some info ∧ info.dynamic = false ∧
    info.isCharacter = false ∧ base = info.firstIndex

def CharacterOrigin (names : BindingEnvironment) : Character.Expr → Prop
  | .literal _ => True
  | .reference index => ∃ info, names.get index = some info ∧ info.isCharacter = true
  | .indexed target base _ => FixedStringOrigin names target base
  | .parenthesized inner => CharacterOrigin names inner

def Operand.BoundsOrigin (names : BindingEnvironment) : Operand → Prop
  | .reference index => ∃ info, names.get index = some info ∧ info.isCharacter = false
  | .slice target base _ _ => FixedStringOrigin names target base
  | .character expression => CharacterOrigin names expression
  | .replace target base _ replacement =>
      FixedStringOrigin names target base ∧ CharacterOrigin names replacement
  | _ => True

def Expression.BoundsOrigin (expression : Expression) (names : BindingEnvironment) : Prop :=
  ∀ atom ∈ expression, atom.BoundsOrigin names

def BoundsNamesExtend (before after : BindingEnvironment) : Prop :=
  ∀ index info, before.get index = some info → after.get index = some info

theorem fixedStringOrigin_extends {before after target base}
    (extension : BoundsNamesExtend before after) (origin : FixedStringOrigin before target base) :
    FixedStringOrigin after target base := by
  obtain ⟨info, found, rest⟩ := origin
  exact ⟨info, extension _ _ found, rest⟩

theorem characterOrigin_extends {before after expression}
    (extension : BoundsNamesExtend before after) (origin : CharacterOrigin before expression) :
    CharacterOrigin after expression := by
  induction expression with
  | literal => trivial
  | reference index =>
      obtain ⟨info, found, typed⟩ := origin
      exact ⟨info, extension _ _ found, typed⟩
  | indexed => exact fixedStringOrigin_extends extension origin
  | parenthesized inner ih => exact ih origin

theorem Operand.boundsOrigin_extends {before after : BindingEnvironment} {atom : Operand}
    (extension : BoundsNamesExtend before after) (origin : atom.BoundsOrigin before) :
    atom.BoundsOrigin after := by
  cases atom with
  | literal | argument | image => trivial
  | reference =>
      obtain ⟨info, found, typed⟩ := origin
      exact ⟨info, extension _ _ found, typed⟩
  | slice => exact fixedStringOrigin_extends extension origin
  | character => exact characterOrigin_extends extension origin
  | replace => exact ⟨fixedStringOrigin_extends extension origin.1,
      characterOrigin_extends extension origin.2⟩

theorem Expression.boundsOrigin_extends {before after : BindingEnvironment} {expression : Expression}
    (extension : BoundsNamesExtend before after) (origin : expression.BoundsOrigin before) :
    expression.BoundsOrigin after := fun atom member => Operand.boundsOrigin_extends extension (origin atom member)

theorem characterOrigin_freeze {names expression} (snapshot : Integer.Store)
    (origin : CharacterOrigin names expression) : CharacterOrigin names (expression.freeze snapshot) := by
  induction expression with
  | literal | reference | indexed => exact origin
  | parenthesized inner ih => exact ih origin

theorem Operand.boundsOrigin_freeze {names : BindingEnvironment} {atom : Operand} (snapshot : Integer.Store)
    (origin : atom.BoundsOrigin names) : (atom.freezeImages snapshot).BoundsOrigin names := by
  cases atom with
  | literal | reference | argument | slice => exact origin
  | image => trivial
  | character => exact characterOrigin_freeze snapshot origin
  | replace => exact ⟨origin.1, characterOrigin_freeze snapshot origin.2⟩

theorem Expression.boundsOrigin_freeze {names : BindingEnvironment} {expression : Expression} (snapshot : Integer.Store)
    (origin : expression.BoundsOrigin names) : (expression.freezeImages snapshot).BoundsOrigin names := by
  intro atom member
  obtain ⟨original, present, rfl⟩ := List.mem_map.mp member
  exact Operand.boundsOrigin_freeze snapshot (origin _ present)

theorem value_boundsOrigin {text names position value result scalarNames integerHidden arrays initials elaborating}
    (parsed : ValueAt text names position value result scalarNames integerHidden arrays initials elaborating) :
    value.BoundsOrigin names := by
  cases parsed with
  | literal | image => trivial
  | reference _ _ _ _ _ found typed _ => exact ⟨_, found, typed⟩
  | slice _ _ source => exact ⟨_, source.selected, source.fixed, source.stringTyped, rfl⟩

theorem character_boundsOrigin {text names scalarNames arrays initials elaborating position expression result}
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result) :
    CharacterOrigin names expression := by
  induction parsed with
  | literal => trivial
  | reference _ _ _ _ found typed _ => exact ⟨_, found, typed⟩
  | indexed _ _ _ source => exact ⟨_, source.selected, source.fixed, source.stringTyped, rfl⟩
  | parenthesized _ _ _ _ ih => exact ih

theorem expression_boundsOrigin {text names position expression result scalarNames integerHidden arrays initials elaborating}
    (parsed : ExpressionAt text names position expression result scalarNames integerHidden arrays initials elaborating) :
    expression.BoundsOrigin names := by
  intro atom member
  obtain ⟨position, result, source⟩ := expressionTail_sourceAtoms parsed atom member
  exact value_boundsOrigin source

theorem Operand.freezeImages_objectBounds (atom : Operand) (snapshot after : Integer.Store)
    (names : BindingEnvironment) (input : Source) :
    (atom.freezeImages snapshot).objectBounds names input after = atom.objectBounds names input snapshot := by
  cases atom <;> rfl

def GroupedExpression.freezeImages (snapshot : Integer.Store) : GroupedExpression → GroupedExpression
  | .atom value => .atom (value.freezeImages snapshot)
  | .concatenate left right => .concatenate (left.freezeImages snapshot) (right.freezeImages snapshot)
  | .parenthesized inner => .parenthesized (inner.freezeImages snapshot)

theorem GroupedExpression.freezeImages_flatten (grouped : GroupedExpression) (snapshot : Integer.Store) :
    (grouped.freezeImages snapshot).flatten = grouped.flatten.freezeImages snapshot := by
  induction grouped <;> simp [freezeImages, flatten, Expression.freezeImages, List.map_append, *]

theorem GroupedExpression.freezeImages_objectBounds (grouped : GroupedExpression)
    (snapshot after : Integer.Store) (names : BindingEnvironment) (input : Source) :
    (grouped.freezeImages snapshot).objectBounds names input after = grouped.objectBounds names input snapshot := by
  induction grouped <;> simp only [freezeImages, objectBounds, Operand.freezeImages_objectBounds, *]

theorem GroupedExpression.freezeImages_boundsSafe (grouped : GroupedExpression)
    (snapshot after : Integer.Store) (names : BindingEnvironment) (input : Source) :
    (grouped.freezeImages snapshot).BoundsSafe names input after ↔ grouped.BoundsSafe names input snapshot := by
  induction grouped <;> simp only [freezeImages, BoundsSafe, Operand.freezeImages_objectBounds,
    freezeImages_objectBounds, *]

end Silver.Compose
