module

public import Silver.ApplicationPackageRoutineSeedRanges
public import Silver.ApplicationPackageSourceFormalModes

@[expose] public section

/-! Final metadata validation supplies immutable scalar interface domains.
Completion changes body spans and effects only. The original declaration
projections transport these facts to each earlier routine frame without
requiring complete metadata validity at an intermediate body prefix. -/
namespace Silver.ApplicationPackageDeclarations
open PackageBindings

theorem declared_parameter_at {before after : Metadata}
    (same : after.parameters.map formalDeclaration = before.parameters.map formalDeclaration) (index : Nat) :
    formalDeclaration (after.parameterAt index) = formalDeclaration (before.parameterAt index) := by
  have project (rows : List Formal) : formalDeclaration (rows.getD (index - 1) {}) =
      (rows.map formalDeclaration).getD (index - 1) (formalDeclaration {}) := by
    simp only [List.getD_eq_getElem?_getD, List.getElem?_map]
    cases rows[index - 1]? <;> rfl
  simp only [Metadata.parameterAt, project, same]

theorem declaration_signature (info : Metadata) (item : Routine) :
    (routineDeclaration item).signature info = item.signature info := by
  cases kind : item.kind <;> rfl

theorem signature_of_declarations {before after : Metadata}
    (same : after.parameters.map formalDeclaration = before.parameters.map formalDeclaration) (item : Routine) :
    item.signature after = item.signature before := by
  have domains (index : Nat) := congrArg Formal.domain (declared_parameter_at same index)
  have formals (index : Nat) := congrArg Formal.semantic (declared_parameter_at same index)
  have inputs : (item.formals after).map Formal.domain = (item.formals before).map Formal.domain := by
    simp only [Routine.formals, List.map_map]
    exact List.map_congr_left (fun offset _ => domains (item.formalFirst + offset))
  have procedures : (item.formals after).map Formal.semantic = (item.formals before).map Formal.semantic := by
    simp only [Routine.formals, List.map_map]
    exact List.map_congr_left (fun offset _ => formals (item.formalFirst + offset))
  cases kind : item.kind <;> simp only [Routine.signature, kind, inputs, procedures]

structure InterfaceDomains (info : Metadata) : Prop where
  formals : ∀ formal ∈ info.parameters, formal.domain.Valid
  routines : ∀ routine ∈ info.routines, (routine.signature info).Valid

theorem InterfaceDomains.of_metadata {text : Text} {info : Metadata}
    (typed : info.Typed) (valid : validMetadata text info = true) : InterfaceDomains info := by
  constructor
  · intro formal member
    obtain ⟨index, inside, same⟩ := List.mem_iff_getElem.mp member
    have selected : info.parameterAt (index + 1) = formal := by
      simpa only [Metadata.parameterAt, Nat.add_one_sub_one, List.getD_eq_getElem?_getD,
        List.getElem?_eq_getElem inside, Option.getD_some] using same
    rw [← selected]
    exact formal_domain_valid (info.parameterAt_typed typed (by omega) (by omega))
      (validMetadata_parameter valid (by omega) (by omega))
  · intro routine member
    obtain ⟨index, inside, same⟩ := List.mem_iff_getElem.mp member
    have selected : info.routineAt (index + 1) = routine := by
      simpa only [Metadata.routineAt, Nat.add_one_sub_one, List.getD_eq_getElem?_getD,
        List.getElem?_eq_getElem inside, Option.getD_some] using same
    rw [← selected]
    exact routine_signature_valid typed valid (by omega) (by omega)

theorem InterfaceDomains.of_declarations {before after : Metadata} (known : InterfaceDomains before)
    (parameters : after.parameters.map formalDeclaration = before.parameters.map formalDeclaration)
    (routines : after.routines.map routineDeclaration = before.routines.map routineDeclaration) :
    InterfaceDomains after := by
  constructor
  · intro formal member
    have original : formalDeclaration formal ∈ before.parameters.map formalDeclaration := by
      rw [← parameters]
      exact List.mem_map.mpr ⟨formal, member, rfl⟩
    obtain ⟨prior, declared, same⟩ := List.mem_map.mp original
    have domain := congrArg Formal.domain same
    change prior.domain = formal.domain at domain
    exact domain ▸ known.formals prior declared
  · intro routine member
    have original : routineDeclaration routine ∈ before.routines.map routineDeclaration := by
      rw [← routines]
      exact List.mem_map.mpr ⟨routine, member, rfl⟩
    obtain ⟨prior, declared, same⟩ := List.mem_map.mp original
    have signature : prior.signature before = routine.signature before := by
      simpa only [declaration_signature] using congrArg (fun item => item.signature before) same
    rw [signature_of_declarations parameters routine, ← signature]
    exact known.routines prior declared

theorem InterfaceDomains.routine_inputs {info : Metadata} (known : InterfaceDomains info)
    (modes : DeclaredFormalModes info) {item : Routine} (member : item ∈ info.routines) :
    ∀ binding ∈ ApplicationPackageInitializers.routineInputs info item, binding.Valid := by
  intro binding selected
  obtain ⟨formal, present, rfl⟩ := List.mem_map.mp selected
  apply ApplicationPackageInitializers.formalInput_valid
  have included := (ApplicationPackageFormalStorage.chosen_sublist false info
    (ApplicationPackageBodies.formalIndices item)).subset present
  obtain ⟨index, active, rfl⟩ := List.mem_map.mp included
  obtain ⟨offset, inside, rfl⟩ := List.mem_map.mp active
  have bounded := modes item member offset (List.mem_range.mp inside)
  have inTable : info.parameterAt (item.formalFirst + offset) ∈ info.parameters := by
    have index : item.formalFirst + offset - 1 < info.parameters.length := by omega
    simp only [Metadata.parameterAt, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem index, Option.getD_some]
    exact List.getElem_mem index
  exact known.formals _ inTable

end Silver.ApplicationPackageDeclarations

namespace Silver.ApplicationPackageBodies
open Compose PackageBindings ApplicationPackageDeclarations
open ApplicationAdmission (BodyResult ParsedPackage)

theorem CompletionFrames.body_interfaces {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (known : InterfaceDomains info) : InterfaceDomains frames.signature.info := by
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have tables : CompletedTables info frames.signature.info := signed ▸ readSignature_tables text globals info
  exact known.of_declarations tables.declared tables.routineDeclarations

theorem RoutineHistory.interfaces {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {before : UnitState} {rows : List RoutineRead} {result : BodyResult}
    (history : RoutineHistory (bodyReaders reader calls) text before rows result)
    (final : InterfaceDomains result.info) :
    InterfaceDomains before.info ∧ ∀ row ∈ rows, InterfaceDomains row.before.info ∧ InterfaceDomains row.result.info := by
  have first := final.of_declarations history.coverage.formalDeclarations.symm
    history.coverage.routineDeclarations.symm
  refine ⟨first, ?_⟩
  induction history with
  | finished => simp
  | @added row later result phase pending read advanced rest ih =>
    have following := final.of_declarations rest.coverage.formalDeclarations.symm
      rest.coverage.routineDeclarations.symm
    intro seen member
    rcases List.mem_cons.mp member with rfl | later
    · exact ⟨first, following⟩
    · exact ih final following seen later

theorem original_interface_domains {reader completion calls sources result}
    (parsed : ParsedPackage reader completion calls sources result)
    (typed : parsed.body.info.Typed) :
    InterfaceDomains parsed.body.info ∧
      ∀ row ∈ parsed.history.rows, InterfaceDomains row.before.info ∧ InterfaceDomains row.result.info := by
  have final := InterfaceDomains.of_metadata typed (Bool.and_eq_true_iff.mp parsed.complete).1
  exact ⟨final, (parsed.history.completions.interfaces final).2⟩

end Silver.ApplicationPackageBodies
