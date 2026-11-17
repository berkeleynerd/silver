module

public import Silver.PredicateAssociationHelpers
public import Silver.PredicateNativeHelpers
public import Silver.ComposeCoreHelperEquations
public import Silver.ComposeModelCalls

@[expose] public section

namespace Silver.Predicate.AssociationNative
open Compose

variable {domain : Expressions.StateDomain}

structure ImportsLinks (calls : Calls) (inherited : Expressions.Calls) (predicate : Native.Calls) : Prop where
  skip : calls .skip = predicate.skip
  nameAfter : calls .nameAfter = predicate.nameAfter
  equalName : calls .equalName = predicate.equalName
  token : ∀ text position token, CursorDomain text position ∧ token = .symbol "=>" →
    calls .token text position token = inherited.function .takeToken text position token

theorem imports_meaning {calls inherited predicate}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (helpers : Native.HelperMeaning predicate) (links : ImportsLinks calls inherited predicate) :
    ImportsMeaning calls where
  skip := by
    classical
    funext text position
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      rw [links.skip]
      exact helpers.skip text valid.1 position valid.2
    · rfl
  nameAfter := by
    classical
    funext text position
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      rw [links.nameAfter]
      exact helpers.name text valid.1 position valid.2
    · rfl
  equalName := by
    classical
    funext text first after otherFirst otherAfter
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      rw [links.equalName]
      exact helpers.equalName text valid.1 first after otherFirst otherAfter valid.2.1 valid.2.2
    · rfl
  token := by
    classical
    funext text position token
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      rw [links.token text position token valid]
      rcases valid with ⟨cursor, rfl⟩
      rw [Expressions.interpreted_take inherited source text cursor.1 position (.symbol "=>") cursor.2
        (by unfold Expressions.ValidToken; decide +kernel)]
      rfl
    · rfl

theorem markFormal_meaning {calls : Calls} (defs : DefinitionEquations calls)
    (seen : FormalSet) (formal : Nat) (valid : MarkDomain formal) :
    calls .markFormal seen formal = markFormal seen formal := by
  have result := congrFun (congrFun (normalized_markFormal defs) seen) formal
  simpa only [totalizeCalls, modelCalls, valid, ↓reduceIte] using result

theorem functionAssociation_meaning {calls inherited predicate}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (helpers : Native.HelperMeaning predicate) (links : ImportsLinks calls inherited predicate)
    (defs : DefinitionEquations calls) (text : Source) (position : Nat)
    (catalog : FunctionBindings.Metadata) (first last ordinal : Nat) (named : Bool)
    (valid : FunctionAssociationDomain text position catalog first last ordinal) :
    calls .functionAssociation text position catalog first last ordinal named =
      functionAssociation text position catalog first last ordinal named := by
  have result := congrFun (congrFun (congrFun (congrFun (congrFun (congrFun (congrFun
    (normalized_functionAssociation (imports_meaning source helpers links) defs)
      text) position) catalog) first) last) ordinal) named
  simpa only [totalizeCalls, modelCalls, valid, ↓reduceIte] using result

theorem procedureAssociation_meaning {calls inherited predicate}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (helpers : Native.HelperMeaning predicate) (links : ImportsLinks calls inherited predicate)
    (defs : DefinitionEquations calls) (text : Source) (position : Nat)
    (catalog : ProcedureBindings.Metadata) (first last ordinal : Nat) (named : Bool)
    (valid : ProcedureAssociationDomain text position catalog first last ordinal) :
    calls .procedureAssociation text position catalog first last ordinal named =
      procedureAssociation text position catalog first last ordinal named := by
  have result := congrFun (congrFun (congrFun (congrFun (congrFun (congrFun (congrFun
    (normalized_procedureAssociation (imports_meaning source helpers links) defs)
      text) position) catalog) first) last) ordinal) named
  simpa only [totalizeCalls, modelCalls, valid, ↓reduceIte] using result

theorem model_imports_links : ImportsLinks modelCalls Expressions.modelCalls Native.modelCalls where
  skip := rfl
  nameAfter := rfl
  equalName := rfl
  token text position token valid := by
    rcases valid with ⟨_, rfl⟩
    rfl

end Silver.Predicate.AssociationNative
