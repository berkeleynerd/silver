module

public import Silver.ApplicationPackageStatementReading
public import Silver.PredicateLoopProperties
public import Silver.PredicateBodyMeaning

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement
open Compose Predicate ApplicationPackages

set_option backward.dsimp.instances true
attribute [local irreducible] readCountedBound ScalarExpression.ArrayAttributes.read

/-- The existing lexical, array-attribute and counted-bound readers are used
at their original inputs. Package-specific name rejection and effect reading
remain the caller's exact functions. -/
def loopHeaderReaders (calls : Calls) : Calls :=
  {calls with
    takeToken := tokenAfter
    skipAt := Compose.skipAt
    nameAfter := Compose.nameAfter
    forbiddenName := Named.forbiddenName
    nameIs := fun text first last name => Named.nameIs text first last (name.toList.map Char.toNat)
    equalName := Named.equalName
    arrayTarget := Predicate.arrayTarget
    readArrayAttribute := fun text position names arrays first last range =>
      ScalarExpression.ArrayAttributes.read text position names arrays first last range
    readCountedBound := Predicate.readCountedBound
    widenInto := fun context facts => facts.widen context.scalarNames
    pathJoin := PathFacts.Context.join
    bodyToken := fun text _ scan token => Predicate.bodyToken text scan token}

theorem forHeader_names {calls : Calls} {source : Input} {afterFor : Nat} {iteration : Iteration}
    (parsed : forHeader calls source afterFor = some iteration) :
    iteration.first = calls.skipAt source.text afterFor ∧
      iteration.last = calls.nameAfter source.text (calls.skipAt source.text afterFor) := by
  unfold forHeader at parsed
  dsimp only at parsed
  split at parsed
  · contradiction
  · split at parsed
    · unfold arrayHeader at parsed
      dsimp only at parsed
      split at parsed
      · contradiction
      · split at parsed
        · contradiction
        · cases parsed
          exact ⟨rfl, rfl⟩
    · cases parsed
      dsimp only [countedHeader]
      exact ⟨rfl, rfl⟩

theorem forHeader_name_guard {calls : Calls} {source : Input} {afterFor : Nat} {iteration : Iteration}
    (parsed : forHeader calls source afterFor = some iteration) :
    rejectedBinder calls source iteration.first iteration.last = false := by
  have names := forHeader_names parsed
  rw [names.1, names.2]
  unfold forHeader at parsed
  dsimp only at parsed
  split at parsed
  · contradiction
  · rename_i accepted
    exact Bool.eq_false_iff.mpr accepted

theorem forHeader_name_positive {calls : Calls} {source : Input} {afterFor : Nat} {iteration : Iteration}
    (parsed : forHeader calls source afterFor = some iteration) :
    iteration.first ≠ 0 ∧ iteration.first < iteration.last := by
  have guard := forHeader_name_guard parsed
  simp only [rejectedBinder, Bool.or_eq_false_iff, decide_eq_false_iff_not] at guard
  exact ⟨guard.1.1.1.1.1, Nat.lt_of_not_ge guard.1.1.1.1.2⟩

/-- A lexical binder is defined strictly after the original FOR cursor. This
preserves Main's source-origin separation from earlier private package state,
including a binder with the same spelling as a private declaration. -/
theorem forHeader_binder_after {calls : Calls} {source : Input} {iteration : Iteration}
    (position : source.input.scan.position ≤ source.text.length + 1)
    (parsed : forHeader (loopHeaderReaders calls) source
      (tokenAfter source.text source.input.scan.position (.word "for")) = some iteration) :
    source.input.scan.position < iteration.first := by
  have names := forHeader_names parsed
  have nonzero := (forHeader_name_positive parsed).1
  rw [names.1] at nonzero ⊢
  change skipAt source.text (fixedAfter source.text source.input.scan.position "for" true) ≠ 0 at nonzero
  have tokenPresent : fixedAfter source.text source.input.scan.position "for" true ≠ 0 := by
    intro zero
    simp only [zero, skipAt, ite_true] at nonzero
    exact nonzero rfl
  have tokenAfter := Expressions.model_fixed_advances source.text source.input.scan.position "for" true position (by decide) tokenPresent
  have skipped := skipAt_advances source.text _
    (fixedAfter_result_bound source.text source.input.scan.position "for" true (by decide)) nonzero
  exact Nat.lt_of_lt_of_le tokenAfter skipped

private theorem counted_start (calls : Calls) (source : Input)
    (counted : loopIsArray source.text source.input.scan = false) :
    afterReverse (loopHeaderReaders calls) source.text
      ((loopHeaderReaders calls).takeToken source.text (loopNameAfter source.text source.input.scan) (.word "in")) =
      loopLowerPosition source.text source.input.scan := by
  unfold afterReverse loopLowerPosition loopReverse loopInAfter
  simp only [counted, Bool.false_eq_true, ite_false, loopHeaderReaders, tokenAfter, ShellToken.word]
  by_cases reverse : fixedAfter source.text
      (fixedAfter source.text (loopNameAfter source.text source.input.scan) "in" true) "reverse" true = 0
  all_goals simp [reverse]

def originalCountedHeader (calls : Calls) (source : Input) : Iteration :=
  countedHeader (loopHeaderReaders calls) source source.input
    (loopFirst source.text source.input.scan) (loopNameAfter source.text source.input.scan)

theorem countedHeader_positions (calls : Calls) (source : Input)
    (counted : loopIsArray source.text source.input.scan = false) :
    let native := originalCountedHeader calls source
    let original := loopHeader source.text source.context source.input.scan
    native.first = original.first ∧ native.last = original.after ∧
      native.value.scan.position = original.entry.position ∧
      native.value.scan.facts = source.input.scan.facts := by
  have start := counted_start calls source counted
  dsimp only [originalCountedHeader, countedHeader]
  rw [start]
  by_cases range : (loopRange source.text source.context source.input.scan).after ≠ 0
  all_goals
    have query := range
    simp only [loopRange] at query
    simp [loopHeaderReaders, loopHeader, counted, query, loopRange, loopEndpoint,
      atPosition, tokenAfter, ShellToken.word, ShellToken.symbol]

/-- A captured Range query supplies semantic endpoint values, while ordinary
counted loops keep the complete original bound readers. Both routes produce
the same declared loop interval and definiteness as the inherited checker. -/
theorem countedHeader_bounds (calls : Calls) (source : Input)
    (counted : loopIsArray source.text source.input.scan = false)
    (arrays : source.context.ArraysReady source.text) :
    let native := originalCountedHeader calls source
    let original := loopHeader source.text source.context source.input.scan
    native.bounds = original.bounds ∧
      native.definite = Integer.loopDefinite original.lower.bounds original.upper.bounds := by
  have start := counted_start calls source counted
  dsimp only [originalCountedHeader, countedHeader]
  rw [start]
  by_cases range : (loopRange source.text source.context source.input.scan).after ≠ 0
  · have safe := loopRange_safe arrays range
    have nonempty : ¬(loopRange source.text source.context source.input.scan).bounds.upper <
        (loopRange source.text source.context source.input.scan).bounds.lower := by omega
    have query := range
    simp only [loopRange] at query nonempty safe
    simp [loopHeaderReaders, query, loopHeader, LoopHeader.bounds, counted, loopRange,
      loopEndpoint, Integer.loopBounds, Integer.loopDefinite, Integer.Interval.singleton,
      Integer.Interval.isEmpty, Integer.Interval.normalize, nonempty, safe.2]
  · have query := range
    simp only [loopRange] at query
    simp only [loopHeaderReaders, query, ite_false, loopHeader, LoopHeader.bounds, counted,
      Bool.false_eq_true, loopRange, Integer.loopBounds, Integer.loopDefinite, tokenAfter,
      ShellToken.word, ShellToken.symbol]
    exact ⟨rfl, rfl⟩

theorem forHeader_counted {calls : Calls} {source : Input} {iteration : Iteration}
    (counted : loopIsArray source.text source.input.scan = false)
    (parsed : forHeader (loopHeaderReaders calls) source
      (tokenAfter source.text source.input.scan.position (.word "for")) = some iteration) :
    iteration = originalCountedHeader calls source := by
  have noArray : fixedAfter source.text (loopNameAfter source.text source.input.scan) "of" true = 0 := by
    exact Classical.not_not.mp (of_decide_eq_false counted)
  unfold forHeader at parsed
  dsimp only at parsed
  split at parsed
  · contradiction
  · have noOf : (loopHeaderReaders calls).takeToken source.text
        ((loopHeaderReaders calls).nameAfter source.text
          ((loopHeaderReaders calls).skipAt source.text
            (tokenAfter source.text source.input.scan.position (.word "for")))) (.word "of") = 0 := noArray
    rw [noOf] at parsed
    simp only [ne_self_iff_false, ite_false, Option.some.injEq] at parsed
    exact parsed.symm

theorem countedHeader_original_bounds {calls : Calls} {source : Input} {iteration : Iteration}
    (counted : loopIsArray source.text source.input.scan = false)
    (arrays : source.context.ArraysReady source.text)
    (parsed : forHeader (loopHeaderReaders calls) source
      (tokenAfter source.text source.input.scan.position (.word "for")) = some iteration)
    (present : iteration.value.scan.position ≠ 0)
    (compatible : ScalarMetadata.OverlayCompatible source.context.scalarNames
      source.context.declarationCount source.input.scan.facts) :
    ∃ lower upper, LoopBoundsAt source.text source.context source.input.scan lower upper ∧
      lower.infer (source.context.flow source.input.scan.facts).scalars =
        some (loopHeader source.text source.context source.input.scan).lower.bounds ∧
      upper.infer (source.context.flow source.input.scan.facts).scalars =
        some (loopHeader source.text source.context source.input.scan).upper.bounds ∧
      iteration.bounds = Integer.loopBounds
        (loopHeader source.text source.context source.input.scan).lower.bounds
        (loopHeader source.text source.context source.input.scan).upper.bounds ∧
      iteration.definite = Integer.loopDefinite
        (loopHeader source.text source.context source.input.scan).lower.bounds
        (loopHeader source.text source.context source.input.scan).upper.bounds := by
  have native := forHeader_counted counted parsed
  have positions := countedHeader_positions calls source counted
  rw [native] at present ⊢
  rw [positions.2.2.1] at present
  obtain ⟨lower, upper, original⟩ := loopHeader_readings counted present
  have inferred := original.inferred counted arrays
  rw [source.context.reading_ranges compatible] at inferred
  have bounds := countedHeader_bounds calls source counted arrays
  refine ⟨lower, upper, original, inferred.1, inferred.2, ?_, bounds.2⟩
  simpa only [LoopHeader.bounds, loopHeader, counted, Bool.false_eq_true, ite_false] using bounds.1

end Silver.ApplicationPackageBodies.Statement
