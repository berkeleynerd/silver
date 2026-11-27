module

public import Silver.ApplicationPackageRecursiveScope

@[expose] public section

namespace Silver.Packages
open Predicate

theorem FrameLayout.GlobalAgreement.local_iff {left right : FrameLayout}
    (same : left.GlobalAgreement right) (slot : Nat) :
    (∃ identity, left.integers slot = .local identity) ↔
      ∃ identity, right.integers slot = .local identity := by
  have equal := same.integers slot
  cases l : left.integers slot <;> cases r : right.integers slot <;>
    simp_all [Address.globalIdentity]

mutual
  theorem FrameLayout.GlobalAgreement.localBinders {left right : FrameLayout}
      (same : left.GlobalAgreement right) (item : Predicate.Statement) :
      statementLocalBinders left item ↔ statementLocalBinders right item := by
    cases item with
    | choice condition yes no =>
      simp only [statementLocalBinders, same.localsBinders yes, same.localsBinders no]
    | forLoop index reverse lower upper body =>
      simp only [statementLocalBinders, same.local_iff index, same.localsBinders body]
    | simple | scalarAssign | booleanAssign | callAssign | procedureCall | arrayAssign | booleanArrayAssign | reject | arrayLoop =>
      simp only [statementLocalBinders]
  termination_by sizeOf item

  theorem FrameLayout.GlobalAgreement.localsBinders {left right : FrameLayout}
      (same : left.GlobalAgreement right) (items : List Predicate.Statement) :
      StatementsLocalBinders left items ↔ StatementsLocalBinders right items := by
    cases items with
    | nil => simp only [StatementsLocalBinders]
    | cons head tail =>
      simp only [StatementsLocalBinders, same.localBinders head, same.localsBinders tail]
  termination_by sizeOf items
end

theorem checkPackageStatements_append {earlier : EffectEnvironment} {layout : FrameLayout}
    {analysis : Integer.Analysis} {booleans : Boolean.Analysis}
    (first rest : List Predicate.Statement) (before : Flow) :
    checkPackageStatements earlier layout analysis before booleans (first ++ rest) =
      (checkPackageStatements earlier layout analysis before booleans first).bind
        (fun middle => checkPackageStatements earlier layout analysis middle booleans rest) := by
  induction first generalizing before with
  | nil => simp only [List.nil_append, checkPackageStatements, Option.bind_some]
  | cons head tail ih => simp only [List.cons_append, checkPackageStatements, ih, Option.bind_assoc]

theorem StatementsLocalBinders.append {layout : FrameLayout} {first rest : List Predicate.Statement}
    (left : StatementsLocalBinders layout first) (right : StatementsLocalBinders layout rest) :
    StatementsLocalBinders layout (first ++ rest) := by
  induction first with
  | nil => exact right
  | cons head tail ih =>
    simp only [StatementsLocalBinders] at left
    simp only [List.cons_append, StatementsLocalBinders]
    exact ⟨left.1, ih left.2⟩

end Silver.Packages

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate Recursive ApplicationPackageFrameLayout

set_option backward.dsimp.instances true

structure PackageChecked (bound : Nat) (source : Statement.Input)
    (result : ApplicationScan) (code : List Predicate.Statement) : Prop where
  form : StatementsWellFormed source.context.hasArguments source.context.names.shape code
    (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames))
  check : Packages.checkPackageStatements (ApplicationPackageCalls.completedEnvironment source.info)
    (layout bound source.info source.context) source.context.analysis (source.context.flow source.input.scan.facts)
    (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)) code =
      some (source.context.flow result.scan.facts)
  binders : Packages.StatementsLocalBinders (layout bound source.info source.context) code
  hidden : HiddenRanges bound source (source.context.flow result.scan.facts)

theorem PackageChecked.empty {bound source}
    (hidden : HiddenRanges bound source (source.context.flow source.input.scan.facts)) :
    PackageChecked bound source source.input [] := by
  exact ⟨by simp only [StatementsWellFormed], by simp only [Packages.checkPackageStatements],
    by simp only [Packages.StatementsLocalBinders], hidden⟩

theorem PackageChecked.append {bound source middle result first rest}
    (left : PackageChecked bound source middle first)
    (right : PackageChecked bound (atInput source middle) result rest) :
    PackageChecked bound source result (first ++ rest) := by
  refine ⟨forms_append left.form right.form, ?_, left.binders.append right.binders, right.hidden⟩
  rw [Packages.checkPackageStatements_append, left.check, Option.bind_some]
  exact right.check

theorem PackageChecked.obligations {bound source result code}
    (derived : PackageChecked bound source result code) :
    discharged (Packages.packageStatementsObligations (ApplicationPackageCalls.completedEnvironment source.info)
      (layout bound source.info source.context) source.context.analysis (source.context.flow source.input.scan.facts)
      (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)) code) = true :=
  Packages.package_statements_obligations_discharge derived.check

theorem BasicCodeAt.localBinders {readers names source result item}
    (original : BasicCodeAt readers names source result item) (layout : Packages.FrameLayout) :
    Packages.statementLocalBinders layout item := by
  cases original with
  | inherited _ _ source =>
    cases source.payload with
    | primitive _ payload => cases payload <;> simp only [SourceStatement.lower, Packages.statementLocalBinders]
    | procedure _ _ => simp only [SourceStatement.lower, Packages.statementLocalBinders]
  | functionCall | procedureCall => simp only [Packages.statementLocalBinders]

theorem package_basic_decoded {readers bound source}
    (equations : Equations (sourceReaders readers) NativeDomain)
    (scope : PackageScope source) (legal : NativeDomain source)
    (hidden : HiddenRanges bound source (source.context.flow source.input.scan.facts))
    (present : source.input.scan.position ≠ 0)
    (noIf : (sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "if") = 0)
    (noFor : (sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "for") = 0)
    (accepted : ((sourceReaders readers).statement.applicationBasic source.text source.context source.input
      source.info source.catalog source.procedures).scan.position ≠ 0) :
    let result := (sourceReaders readers).statement.applicationBasic source.text source.context source.input
      source.info source.catalog source.procedures
    ∃ code, StatementCodeAt (sourceReaders readers) packageNames source result code ∧
      PackageChecked bound source result code := by
  have linked := equations.basic_model legal
  have nativeAccepted := accepted
  rw [linked] at nativeAccepted
  obtain ⟨item, original, formed, checked, kept⟩ := scope.basic_reading legal hidden nativeAccepted
  rw [← linked] at original checked kept
  refine ⟨[item], .basic present noIf noFor rfl accepted original, ?_⟩
  exact ⟨by simp only [StatementsWellFormed]; exact ⟨formed, trivial⟩,
    by simp only [Packages.checkPackageStatements, checked, Option.bind_some],
    by simp only [Packages.StatementsLocalBinders]; exact ⟨original.localBinders _, trivial⟩, kept⟩

end Silver.ApplicationPackageBodies.SourceSyntax
