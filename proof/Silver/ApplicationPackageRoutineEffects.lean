module

public import Silver.PackageEffectSummaries
public import Silver.ApplicationPackageSourceEffects
public import Silver.ApplicationPackageRoutineSourceChecking

@[expose] public section

/-! Original routine source supplies inferred effect membership in the native
footer summary. The conservative summary remains at its original identity. -/
namespace Silver.ApplicationPackageRoutineEffects
open Compose Predicate Packages Packages.EffectSummaries ApplicationPackages
open ApplicationPackageBodies ApplicationPackageBodies.Recursive ApplicationPackageBodies.SourceSyntax
open ApplicationPackageRoutineSources ApplicationPackageRoutineResults

export Packages.EffectSummaries
  (Included execute_local_summary append_respects_summary append_local_summary)

private theorem function_arguments_scalar {text context input info frame slots values}
    (source : Basic.FunctionArgumentsAt text context input info frame slots values)
    (closed : ClosedFunctionContext context.model) :
    values.all ScalarFunctions.scalarActual = true := by
  induction source with
  | nil => rfl
  | cons value rest ih =>
      rw [List.all_cons]
      exact Bool.and_eq_true_iff.mpr ⟨actual_source_scalar closed value, ih⟩

private theorem procedure_arguments_scalar {text context input info frame slots values}
    (source : Basic.ProcedureArgumentsAt text context input info frame slots values)
    (closed : ClosedFunctionContext context.model) :
    values.all ScalarProcedures.scalarActual = true := by
  induction source with
  | nil => rfl
  | value value rest ih =>
      rw [List.all_cons]
      exact Bool.and_eq_true_iff.mpr ⟨actual_source_scalar closed value, ih⟩
  | target mode target after rest ih =>
      rw [List.all_cons]
      exact Bool.and_eq_true_iff.mpr ⟨rfl, ih⟩

theorem basic_scalar {calls names source result item}
    (original : BasicCodeAt calls names source result item)
    (closed : ClosedFunctionContext source.context)
    (functions : source.catalog = {}) (procedures : source.procedures = {}) :
    ScalarProcedures.scalarStatement item = true := by
  cases original with
  | inherited selected returned reading =>
      rw [functions, procedures] at reading
      have primitive := reading.empty_primitive
      have shape := basic_source_scalar closed primitive
      cases primitive.payload <;>
        simp only [SourceStatement.lower, ScalarFunctions.frameStatement,
          ScalarProcedures.scalarStatement, ScalarProcedures.frameStatement] at shape ⊢ <;>
        exact shape.2
  | functionCall same selected returned reading =>
      obtain ⟨_, frame, entries, native, arguments⟩ := reading
      have nativeClosed := same.symm ▸ closed
      simpa only [ScalarProcedures.scalarStatement, ScalarProcedures.frameStatement,
        ScalarFunctions.scalarActual] using
        function_arguments_scalar arguments nativeClosed
  | procedureCall same selected returned reading =>
      obtain ⟨_, frame, entries, native, arguments⟩ := reading
      have nativeClosed := same.symm ▸ closed
      simpa only [ScalarProcedures.scalarStatement, ScalarProcedures.frameStatement,
        ScalarProcedures.scalarActual] using
        procedure_arguments_scalar arguments nativeClosed

private theorem scalars_append (first second : List Predicate.Statement) :
    ScalarProcedures.scalarStatements (first ++ second) =
      (ScalarProcedures.scalarStatements first && ScalarProcedures.scalarStatements second) := by
  induction first with
  | nil => simp only [List.nil_append, ScalarProcedures.scalarStatements,
      ScalarProcedures.frameStatements, Bool.true_and]
  | cons head tail ih =>
      simp only [ScalarProcedures.scalarStatements, List.cons_append,
        ScalarProcedures.frameStatements] at ih ⊢
      rw [ih, Bool.and_assoc]

private def ScalarArms (arms : List Statement.ArmCode) : Prop :=
  ∀ arm ∈ arms, ScalarFunctions.scalarCondition arm.1 = true ∧
    ScalarProcedures.scalarStatements arm.2 = true

private theorem lower_arms_scalar {arms : List Statement.ArmCode} {otherwise : List Predicate.Statement}
    (checked : ScalarArms arms) (alternative : ScalarProcedures.scalarStatements otherwise = true) :
    ScalarProcedures.scalarStatements (Statement.lowerArms arms otherwise) = true := by
  induction arms with
  | nil => exact alternative
  | cons arm rest ih =>
      have first := checked arm (List.mem_cons_self ..)
      have later := ih (fun seen member => checked seen (List.mem_cons_of_mem _ member))
      simp only [ScalarFunctions.scalarCondition, ScalarProcedures.scalarStatements] at first later
      simp only [Statement.lowerArms, ScalarProcedures.scalarStatements,
        ScalarProcedures.frameStatements, ScalarProcedures.frameStatement, first.1, first.2,
        later, Bool.and_self]

/-- Scalar-body membership follows from the original source tree and closed
routine frame, including every conditional arm and loop body. -/
theorem tail_scalar {readers : Readers} {names source stop required seen result code}
    (original : TailCodeAt (sourceReaders readers) names source stop required seen result code)
    (closed : ClosedFunctionContext source.context)
    (functions : source.catalog = {}) (procedures : source.procedures = {}) :
    ScalarProcedures.scalarStatements code = true := by
  apply TailCodeAt.rec
    (motive_1 := fun source _ code _ => ClosedFunctionContext source.context →
      source.catalog = {} → source.procedures = {} → ScalarProcedures.scalarStatements code = true)
    (motive_2 := fun source _ _ arms _ => ClosedFunctionContext source.context →
      source.catalog = {} → source.procedures = {} → ScalarArms arms)
    (motive_3 := fun source _ code _ => ClosedFunctionContext source.context →
      source.catalog = {} → source.procedures = {} → ScalarProcedures.scalarStatements code = true)
    (motive_4 := fun source _ _ _ _ code _ => ClosedFunctionContext source.context →
      source.catalog = {} → source.procedures = {} → ScalarProcedures.scalarStatements code = true)
    ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ original closed functions procedures
  · intro source result item _ _ _ _ _ reading closed functions procedures
    simp only [ScalarProcedures.scalarStatements, ScalarProcedures.frameStatements,
      Bool.and_true]
    exact basic_scalar reading closed functions procedures
  · intro source state result codes alternative _ _ arms otherwise closing armsIH elseIH closed functions procedures
    exact lower_arms_scalar (armsIH closed functions procedures) (elseIH closed functions procedures)
  · intro source iteration result lower upper body _ _ _ header kind bounds inside insideIH closed functions procedures
    have localClosed : ClosedFunctionContext (loopChild (sourceReaders readers).statement source iteration).context :=
      ⟨closed.pure, closed.noArguments, closed.noNames, closed.arrayViews⟩
    have bodyScalar := insideIH localClosed functions procedures
    have endpoints := bounds.source_frame closed
    change ScalarProcedures.frameStatements [] body = true at bodyScalar
    simp only [ScalarProcedures.scalarStatements, ScalarProcedures.frameStatements,
      ScalarProcedures.frameStatement, endpoints.1, endpoints.2, bodyScalar, Bool.and_self]
  · intro source iteration result body _ _ _ header kind _ _ closed _ _
    have impure := (Statement.arrayHeader_accepted (Statement.forHeader_array kind header.header)).1
    rw [closed.pure] at impure
    contradiction
  · intro source before read after condition body _ guard _ _ insideIH closed functions procedures
    intro arm member
    have same := List.mem_singleton.mp member
    subst arm
    exact ⟨condition_source_scalar closed guard, insideIH closed functions procedures⟩
  · intro source before read after final condition body rest _ guard _ _ _ insideIH restIH closed functions procedures
    intro arm member
    rcases List.mem_cons.mp member with rfl | later
    · exact ⟨condition_source_scalar closed guard, insideIH closed functions procedures⟩
    · exact restIH closed functions procedures arm later
  · intro source state _ closed functions procedures
    simp only [ScalarProcedures.scalarStatements, ScalarProcedures.frameStatements]
  · intro source state body _ _ insideIH closed functions procedures
    exact insideIH closed functions procedures
  · intro source stop required seen _ _ _ closed functions procedures
    simp only [ScalarProcedures.scalarStatements, ScalarProcedures.frameStatements]
  · intro source stop required seen first result head rest _ _ _ _ _ _ headIH restIH closed functions procedures
    rw [scalars_append, headIH closed functions procedures, restIH closed functions procedures]
    rfl

end Silver.ApplicationPackageRoutineEffects
