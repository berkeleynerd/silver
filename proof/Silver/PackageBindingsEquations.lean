module

public import Silver.PackageBindingsExpressions

@[expose] public section

namespace Silver.PackageBindings.Native

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

/-- The existing lexical and interval operations retain their established
mathematical meanings. Equality is used only after both names pass Valid_Name;
no recognizer, lookup, effects or metadata invariant is assumed. -/
structure Primitives (calls : Calls) : Prop where
  letter : ∀ byte, calls.letter byte = Named.letter byte
  identifierCharacter : ∀ byte, calls.identifierCharacter byte = Silver.identifierCharacter byte
  isEmpty : ∀ bounds, calls.isEmpty bounds = bounds.isEmpty
  equalName : ∀ text left right, validName text left = true → validName text right = true →
    calls.equalName text.bytes left.first left.after right.first right.after =
      Named.equalName text.bytes left.first left.after right.first right.after

/-- Exact typed bodies and the source-checked static loop refinements. The
recursive lookups have only their declared limit preconditions; in particular
neither valid metadata nor a valid query name is assumed. -/
structure Equations (calls : Calls) : Prop where
  isIdentifier : ∀ name, calls.isIdentifier name = isIdentifierBody.eval calls ({sourceName := name} : Context).locals
  validName : ∀ text name, calls.validName text name = validNameBody.eval calls ({text,name} : Context).locals
  inUnit : ∀ name unit, calls.inUnit name unit = inUnitBody.eval calls ({name,unit} : Context).locals
  sameName : ∀ text left right, calls.sameName text left right = sameNameBody.eval calls ({text,left,right} : Context).locals
  union : ∀ left right, calls.union left right = unionBody.eval calls ({leftSet := left,rightSet := right} : Context).locals
  within : ∀ effect count, calls.within effect count = withinBody.eval calls ({effect,count} : Context).locals
  validMetadata : ∀ text info, calls.validMetadata text info = validMetadataBody.eval calls ({text,info} : Context).locals
  completeMetadata : ∀ text info, calls.completeMetadata text info = completeMetadataBody.eval calls ({text,info} : Context).locals
  exportLookupModel : ∀ text info name limit, limit ≤ info.exports.length →
    calls.exportLookupModel text info name limit = exportLookupBody.eval calls ({text,info,name,limit} : Context).locals
  stateLookupModel : ∀ text info name limit, limit ≤ info.states.length →
    calls.stateLookupModel text info name limit = stateLookupBody.eval calls ({text,info,name,limit} : Context).locals
  routineLookupModel : ∀ text info name limit, limit ≤ info.routines.length →
    calls.routineLookupModel text info name limit = routineLookupBody.eval calls ({text,info,name,limit} : Context).locals
  lookupExport : ∀ text info name, calls.lookupExport text info name = calls.exportLookupModel text info name info.exports.length
  lookupState : ∀ text info name, calls.lookupState text info name = calls.stateLookupModel text info name info.states.length
  lookupRoutine : ∀ text info name completedOnly, info.completed ≤ info.routines.length →
    calls.lookupRoutine text info name completedOnly =
      calls.routineLookupModel text info name (if completedOnly then info.completed else info.routines.length)

theorem isIdentifier_denotation (calls : Calls) (primitives : Primitives calls) (name : Text) :
    isIdentifierBody.eval calls ({sourceName := name} : Context).locals = isIdentifier name := by
  have last : (name.first + (name.bytes.length : Int) - 1 - name.first).toNat = name.bytes.length - 1 := by omega
  have current (index : Nat) : (name.first + (index : Int) - name.first).toNat = index := by omega
  have previous (index : Nat) : (name.first + (index : Int) - 1 - name.first).toNat = index - 1 := by omega
  have advancing (index : Nat) : (name.first + (index : Int) > name.first) ↔ 0 < index := by omega
  simp only [isIdentifierBody, conjunction, List.foldl_cons, List.foldl_nil, Expr.eval, Context.locals,
    Calls.get, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte,
    ApplicationUnits.Native.SourceValue.last, Int.sub_self, Int.toNat_zero, last, current,
    advancing, primitives.letter, primitives.identifierCharacter, isIdentifier]
  simp [Nat.succ_le_iff, previous]

theorem interpreted_identifier (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (name : Text) : calls.isIdentifier name = isIdentifier name := by
  rw [equations.isIdentifier, isIdentifier_denotation calls primitives]

theorem validName_denotation (calls : Calls)
    (identifier : ∀ name, calls.isIdentifier name = isIdentifier name) (text : Text) (name : NameSpan) :
    validNameBody.eval calls ({text,name} : Context).locals = validName text name := by
  simp only [validNameBody, conjunction, List.foldl_cons, List.foldl_nil, Expr.eval, Context.locals,
    Calls.get, Field.get, identifier, ApplicationUnits.Native.SourceValue.last, validName]
  by_cases first : text.first = 1
  · have bound : ((name.after : Int) ≤ 1 + (text.bytes.length : Int)) ↔
        name.after ≤ text.bytes.length + 1 := by omega
    simp [first, Nat.succ_le_iff, Bool.and_assoc, Bool.decide_and, bound]
  · simp [first]

theorem interpreted_validName (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Text) (name : NameSpan) : calls.validName text name = validName text name := by
  rw [equations.validName, validName_denotation calls (interpreted_identifier calls primitives equations)]

theorem inUnit_denotation (calls : Calls) (name : NameSpan) (unit : UnitSpan) :
    inUnitBody.eval calls ({name,unit} : Context).locals = inUnit name unit := by
  simp [inUnitBody, conjunction, Expr.eval, Context.locals, Field.get, inUnit, Bool.decide_and, Bool.and_assoc]

theorem interpreted_inUnit (calls : Calls) (equations : Equations calls) (name : NameSpan) (unit : UnitSpan) :
    calls.inUnit name unit = inUnit name unit := by
  rw [equations.inUnit, inUnit_denotation]

theorem sameName_denotation (calls : Calls) (primitives : Primitives calls)
    (names : ∀ text name, calls.validName text name = validName text name) (text : Text) (left right : NameSpan) :
    sameNameBody.eval calls ({text,left,right} : Context).locals = sameName text left right := by
  simp only [sameNameBody, conjunction, List.foldl_cons, List.foldl_nil, apply2, apply3, apply4,
    Expr.eval, Context.locals, Calls.get, Field.get, names, sameName]
  by_cases a : validName text left = true
  · by_cases b : validName text right = true
    · rw [primitives.equalName text left right a b]
    · simp [Bool.eq_false_iff.mpr b]
  · simp [Bool.eq_false_iff.mpr a]

theorem interpreted_sameName (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Text) (left right : NameSpan) : calls.sameName text left right = sameName text left right := by
  rw [equations.sameName, sameName_denotation calls primitives (interpreted_validName calls primitives equations)]

theorem union_denotation (calls : Calls) (left right : StateSet) :
    unionBody.eval calls ({leftSet := left,rightSet := right} : Context).locals = stateUnion left right := by
  simp [unionBody, Expr.eval, Context.locals, Locals.set, stateUnion]

theorem interpreted_union (calls : Calls) (equations : Equations calls) (left right : StateSet) :
    calls.union left right = stateUnion left right := by rw [equations.union, union_denotation]

theorem within_denotation (calls : Calls) (effect : StateSet) (count : Nat) :
    withinBody.eval calls ({effect,count} : Context).locals = within effect count := by
  simp [withinBody, Expr.eval, Context.locals, Locals.set, within]

theorem interpreted_within (calls : Calls) (equations : Equations calls) (effect : StateSet) (count : Nat) :
    calls.within effect count = within effect count := by rw [equations.within, within_denotation]

/-- The guarded formal range is exactly Count elements, even when the rest of
metadata is malformed. The bound Count > 0 belongs to the source conditional. -/
theorem formal_range_length (first count : Nat) (positive : 0 < count) :
    first + count - 1 + 1 - first = count := by omega

theorem formal_range_all (first count : Nat) (predicate : Nat → Bool) :
    (!decide (0 < count) || (List.range (1 + (first + count - 1) - first)).all predicate) =
      (!decide (0 < count) || (List.range count).all predicate) := by
  by_cases positive : 0 < count
  · have length : 1 + (first + count - 1) - first = count := by omega
    rw [length]
  · simp [positive]

theorem validMetadata_denotation (calls : Calls) (primitives : Primitives calls)
    (names : ∀ text name, calls.validName text name = validName text name)
    (inside : ∀ name unit, calls.inUnit name unit = inUnit name unit)
    (same : ∀ text left right, calls.sameName text left right = sameName text left right)
    (effects : ∀ set count, calls.within set count = within set count)
    (text : Text) (info : Metadata) :
    validMetadataBody.eval calls ({text,info} : Context).locals = validMetadata text info := by
  simp only [validMetadataBody, conjunction, List.foldl_cons, List.foldl_nil, apply2, apply3,
    Expr.eval, Context.locals, Calls.get, Field.get, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte,
    ApplicationUnits.Native.SourceValue.last, names, inside, same, effects, primitives.isEmpty]
  by_cases first : text.first = 1
  · simp only [first]
    have endpoint : ((info.units .mainBody).after : Int) = 1 + (text.bytes.length : Int) ↔
        (info.units .mainBody).after = text.bytes.length + 1 := by omega
    simp [validMetadata, Metadata.unitLayout, exportValid, stateValid, parameterValid, routineValid,
      first, Nat.succ_le_iff, Bool.and_assoc, Bool.decide_and, Nat.add_comm, endpoint]
    simp only [formal_range_all]
  · simp [validMetadata, first]

theorem interpreted_validMetadata (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Text) (info : Metadata) : calls.validMetadata text info = validMetadata text info := by
  rw [equations.validMetadata, validMetadata_denotation calls primitives
    (interpreted_validName calls primitives equations) (interpreted_inUnit calls equations)
    (interpreted_sameName calls primitives equations) (interpreted_within calls equations)]

theorem completeMetadata_denotation (calls : Calls)
    (valid : ∀ text info, calls.validMetadata text info = validMetadata text info) (text : Text) (info : Metadata) :
    completeMetadataBody.eval calls ({text,info} : Context).locals = completeMetadata text info := by
  simp [completeMetadataBody, conjunction, apply2, Expr.eval, Context.locals, Calls.get, Field.get,
    valid, completeMetadata, Bool.decide_and, Bool.and_assoc]

theorem interpreted_completeMetadata (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Text) (info : Metadata) : calls.completeMetadata text info = completeMetadata text info := by
  rw [equations.completeMetadata, completeMetadata_denotation calls (interpreted_validMetadata calls primitives equations)]

theorem interpreted_exportLookup (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Text) (info : Metadata) (name : NameSpan) (limit : Nat) (bound : limit ≤ info.exports.length) :
    calls.exportLookupModel text info name limit = exportLookupModel text info name limit := by
  induction limit with
  | zero =>
      rw [equations.exportLookupModel text info name 0 bound]
      simp [exportLookupBody, lookupBody, Expr.eval, Context.locals, exportLookupModel, lookupFrom]
  | succ index ih =>
      rw [equations.exportLookupModel text info name (index + 1) bound]
      simp [exportLookupBody, lookupBody, apply2, apply3, apply4, Expr.eval, Context.locals, Calls.get, Field.get,
        interpreted_sameName calls primitives equations, ih (by omega), exportLookupModel, lookupFrom]

theorem interpreted_stateLookup (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Text) (info : Metadata) (name : NameSpan) (limit : Nat) (bound : limit ≤ info.states.length) :
    calls.stateLookupModel text info name limit = stateLookupModel text info name limit := by
  induction limit with
  | zero =>
      rw [equations.stateLookupModel text info name 0 bound]
      simp [stateLookupBody, lookupBody, Expr.eval, Context.locals, stateLookupModel, lookupFrom]
  | succ index ih =>
      rw [equations.stateLookupModel text info name (index + 1) bound]
      simp [stateLookupBody, lookupBody, apply2, apply3, apply4, Expr.eval, Context.locals, Calls.get, Field.get,
        interpreted_sameName calls primitives equations, ih (by omega), stateLookupModel, lookupFrom]

theorem interpreted_routineLookup (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Text) (info : Metadata) (name : NameSpan) (limit : Nat) (bound : limit ≤ info.routines.length) :
    calls.routineLookupModel text info name limit = routineLookupModel text info name limit := by
  induction limit with
  | zero =>
      rw [equations.routineLookupModel text info name 0 bound]
      simp [routineLookupBody, lookupBody, Expr.eval, Context.locals, routineLookupModel, lookupFrom]
  | succ index ih =>
      rw [equations.routineLookupModel text info name (index + 1) bound]
      simp [routineLookupBody, lookupBody, apply2, apply3, apply4, Expr.eval, Context.locals, Calls.get, Field.get,
        interpreted_sameName calls primitives equations, ih (by omega), routineLookupModel, lookupFrom]

def modelCalls : Calls where
  letter := Named.letter
  identifierCharacter := Silver.identifierCharacter
  equalName := Named.equalName
  isEmpty := Integer.Interval.isEmpty
  isIdentifier := isIdentifier
  validName := validName
  inUnit := inUnit
  sameName := sameName
  union := stateUnion
  within := within
  validMetadata := validMetadata
  completeMetadata := completeMetadata
  exportLookupModel := exportLookupModel
  stateLookupModel := stateLookupModel
  routineLookupModel := routineLookupModel
  lookupExport := lookupExport
  lookupState := lookupState
  lookupRoutine := lookupRoutine

theorem model_primitives : Primitives modelCalls where
  letter := fun _ => rfl
  identifierCharacter := fun _ => rfl
  isEmpty := fun _ => rfl
  equalName := fun _ _ _ _ _ => rfl

theorem model_equations : Equations modelCalls where
  isIdentifier := fun name => (isIdentifier_denotation modelCalls model_primitives name).symm
  validName := fun text name => (validName_denotation modelCalls (fun _ => rfl) text name).symm
  inUnit := fun name unit => (inUnit_denotation modelCalls name unit).symm
  sameName := fun text left right => (sameName_denotation modelCalls model_primitives (fun _ _ => rfl) text left right).symm
  union := fun left right => (union_denotation modelCalls left right).symm
  within := fun effect count => (within_denotation modelCalls effect count).symm
  validMetadata := fun text info => (validMetadata_denotation modelCalls model_primitives
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ _ => rfl) (fun _ _ => rfl) text info).symm
  completeMetadata := fun text info => (completeMetadata_denotation modelCalls (fun _ _ => rfl) text info).symm
  exportLookupModel := by
    intro text info name limit _
    cases limit <;> simp [modelCalls, exportLookupBody, lookupBody, apply2, apply3, apply4,
      Expr.eval, Context.locals, Calls.get, Field.get, exportLookupModel, lookupFrom]
  stateLookupModel := by
    intro text info name limit _
    cases limit <;> simp [modelCalls, stateLookupBody, lookupBody, apply2, apply3, apply4,
      Expr.eval, Context.locals, Calls.get, Field.get, stateLookupModel, lookupFrom]
  routineLookupModel := by
    intro text info name limit _
    cases limit <;> simp [modelCalls, routineLookupBody, lookupBody, apply2, apply3, apply4,
      Expr.eval, Context.locals, Calls.get, Field.get, routineLookupModel, lookupFrom]
  lookupExport := fun _ _ _ => rfl
  lookupState := fun _ _ _ => rfl
  lookupRoutine := fun _ _ _ _ _ => rfl

end Silver.PackageBindings.Native
