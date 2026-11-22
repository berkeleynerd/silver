module

public import Silver.CallableTypeHistory
public import Silver.ComposeNativeStateBounds
public import Silver.ProcedureMetadataSemantics

@[expose] public section

namespace Silver.Compose
open Predicate Silver.Compose.Expressions

/-- Ordinary declarations retain both callable pools and only append named
array types. The relation records source history, not native validity. -/
structure NoncallableTypeExtension (before after : ParserState) : Prop where
  functions : after.functions = before.functions
  procedures : after.procedures = before.procedures
  typePrefix : ∃ more, after.arrayNames.types = before.arrayNames.types ++ more

theorem declarationAt_noncallable_fields {text state arguments}
    (noFunction : (functionDeclarationAt text state arguments).position = 0)
    (noProcedure : (procedureDeclarationAt text state arguments).position = 0)
    (accepted : (declarationAt text state arguments).position ≠ 0) :
    NoncallableTypeExtension state (declarationAt text state arguments) := by
  have noCallable := (callableDeclarationAt_zero_iff text state arguments).mpr ⟨noFunction, noProcedure⟩
  rw [declarationAt_callable_equation, ite_eq_right (not_not_intro noCallable)] at accepted ⊢
  split at accepted
  · rename_i positive
    rw [ite_eq_left positive]
    have source := array_type_declaration_sound text state arguments positive
    have fields := array_type_declaration_fields source
    refine ⟨?_, ?_, ⟨_, array_type_declaration_types source⟩⟩
    · rw [fields]
    · rw [fields]
  · rename_i noType
    rw [ite_eq_right noType]
    split at accepted
    · rename_i positive
      rw [ite_eq_left positive]
      have source := subtype_declaration_sound text state arguments positive
      generalize nextEq : subtypeDeclarationAt text state arguments = next at source ⊢
      cases source
      exact ⟨rfl, rfl, ⟨[], (List.append_nil _).symm⟩⟩
    · rename_i noSubtype
      rw [ite_eq_right noSubtype]
      split at accepted
      · rename_i positive
        rw [ite_eq_left positive]
        obtain ⟨declaration, source⟩ := scalar_declaration_sound text state arguments positive
        generalize nextEq : scalarDeclarationAt text state arguments = next at source ⊢
        cases source
        exact ⟨rfl, rfl, ⟨[], (List.append_nil _).symm⟩⟩
      · rename_i noScalar
        rw [ite_eq_right noScalar]
        split at accepted
        · rename_i positive
          rw [ite_eq_left positive]
          refine ⟨arrayDeclarationAt_functions positive, arrayDeclarationAt_procedures positive, [], ?_⟩
          rw [List.append_nil]
          by_cases kind : (arrayDeclarationParts text state).isBoolean = true
          · exact boolean_array_declaration_types (boolean_array_declaration_sound text state arguments kind positive)
          · obtain ⟨declaration, source⟩ := array_declaration_sound text state arguments
              (Bool.eq_false_iff.mpr kind) positive
            exact array_declaration_types source
        · rename_i noArray
          rw [ite_eq_right noArray]
          split at accepted
          · rename_i positive
            rw [ite_eq_left positive]
            have source := boolean_declaration_sound text state arguments positive
            generalize nextEq : booleanDeclarationAt text state arguments = next at source ⊢
            cases source
            exact ⟨rfl, rfl, ⟨[], (List.append_nil _).symm⟩⟩
          · rename_i noBoolean
            rw [ite_eq_right noBoolean]
            change (objectDeclarationAt text state arguments).position ≠ 0 at accepted
            change NoncallableTypeExtension state (objectDeclarationAt text state arguments)
            obtain ⟨declaration, source⟩ := declaration_sound text state arguments accepted
            generalize nextEq : objectDeclarationAt text state arguments = next at source ⊢
            cases source with
            | string _ source => cases source; exact ⟨rfl, rfl, ⟨[], (List.append_nil _).symm⟩⟩
            | character source => cases source; exact ⟨rfl, rfl, ⟨[], (List.append_nil _).symm⟩⟩

theorem NoncallableTypeExtension.callableTypesKnown {state next}
    (extension : NoncallableTypeExtension state next) (known : CallableTypesKnown state) :
    CallableTypesKnown next := by
  obtain ⟨more, types⟩ := extension.typePrefix
  constructor
  · intro formal member
    rw [extension.functions] at member
    rw [types]
    exact Nat.le_trans (known.functions formal member) (by simp)
  · intro formal member
    rw [extension.procedures] at member
    rw [types]
    exact Nat.le_trans (known.procedures formal member) (by simp)

theorem NoncallableTypeExtension.catalogs {text state next}
    (extension : NoncallableTypeExtension state next) (valid : ValidState text state)
    (known : CallableTypesKnown state) :
    catalogSignatures next.functions next.arrayNames.types = catalogSignatures state.functions state.arrayNames.types ∧
      ProcedureBindings.catalogSignatures next.procedures next.arrayNames.types =
        ProcedureBindings.catalogSignatures state.procedures state.arrayNames.types := by
  obtain ⟨more, types⟩ := extension.typePrefix
  rw [extension.functions, extension.procedures, types]
  exact ⟨catalogSignatures_typePrefix _ _ _ valid.functions known.functions,
    ProcedureBindings.catalogSignatures_typePrefix _ _ _ valid.procedures known.procedures⟩

end Silver.Compose
