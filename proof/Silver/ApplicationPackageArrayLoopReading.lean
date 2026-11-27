module

public import Silver.ApplicationPackageLoopHeaderReading

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement
open Compose Predicate ApplicationPackages

set_option backward.dsimp.instances true
attribute [local irreducible] readCountedBound ScalarExpression.ArrayAttributes.read
attribute [local irreducible] skipAt nameAfter arrayTarget Named.equalName

theorem arrayHeader_accepted {calls : Calls} {source : Input} {base : ApplicationScan}
    {first last : Nat} {iteration : Iteration}
    (parsed : arrayHeader calls source base first last = some iteration) :
    source.context.pure = false ∧
      rejectedArrayIterator calls source first last
        (afterReverse calls source.text (calls.takeToken source.text last (.word "of"))) = false ∧
      iteration =
        ⟨atPosition base (calls.takeToken source.text
          (calls.nameAfter source.text (calls.skipAt source.text
            (afterReverse calls source.text (calls.takeToken source.text last (.word "of")))))
          (.word "loop")), first, last,
          (ArrayBindings.binding source.context.arrayNames
            (calls.arrayTarget source.text source.context
              (afterReverse calls source.text (calls.takeToken source.text last (.word "of"))))).componentBounds,
          true⟩ := by
  unfold arrayHeader at parsed
  dsimp only at parsed
  split at parsed
  · contradiction
  · rename_i impure
    split at parsed
    · contradiction
    · rename_i allowed
      simp only [Option.some.injEq] at parsed
      exact ⟨Bool.eq_false_iff.mpr impure, Bool.eq_false_iff.mpr allowed, parsed.symm⟩

theorem forHeader_array {calls : Calls} {source : Input} {iteration : Iteration}
    (iterable : loopIsArray source.text source.input.scan = true)
    (parsed : forHeader (loopHeaderReaders calls) source
      (tokenAfter source.text source.input.scan.position (.word "for")) = some iteration) :
    arrayHeader (loopHeaderReaders calls) source source.input
      (loopFirst source.text source.input.scan) (loopNameAfter source.text source.input.scan) = some iteration := by
  have found : fixedAfter source.text (loopNameAfter source.text source.input.scan) "of" true ≠ 0 :=
    of_decide_eq_true iterable
  unfold forHeader at parsed
  dsimp only at parsed
  split at parsed
  · contradiction
  · have ofPresent : (loopHeaderReaders calls).takeToken source.text
        ((loopHeaderReaders calls).nameAfter source.text
          ((loopHeaderReaders calls).skipAt source.text
            (tokenAfter source.text source.input.scan.position (.word "for")))) (.word "of") ≠ 0 := found
    rw [ite_eq_left ofPresent] at parsed
    exact parsed

private theorem array_start (calls : Calls) (source : Input)
    (iterable : loopIsArray source.text source.input.scan = true) :
    afterReverse (loopHeaderReaders calls) source.text
      ((loopHeaderReaders calls).takeToken source.text (loopNameAfter source.text source.input.scan) (.word "of")) =
      loopLowerPosition source.text source.input.scan := by
  unfold afterReverse loopLowerPosition loopReverse loopInAfter
  simp only [iterable, ite_true, loopHeaderReaders, tokenAfter, ShellToken.word, loopOfAfter]
  by_cases reverse : fixedAfter source.text
      (fixedAfter source.text (loopNameAfter source.text source.input.scan) "of" true) "reverse" true = 0
  all_goals simp [reverse]

private theorem iterator_guards (first last target : Nat) (same mutable boolean pure : Bool)
    (guard : (decide (first = 0) || decide (last ≤ first) || same ||
      decide (target = 0) || mutable || boolean) = false) (impure : pure = false) :
    (decide (first ≠ 0 ∧ first < last ∧ target ≠ 0) && !mutable && !same && !boolean && !pure) = true := by
  simp only [Bool.or_eq_false_iff, decide_eq_false_iff_not] at guard
  obtain ⟨⟨⟨⟨⟨first, last⟩, distinct⟩, target⟩, immutable⟩, integer⟩ := guard
  simp only [Bool.and_eq_true, decide_eq_true_eq, Bool.not_eq_true']
  exact ⟨⟨⟨⟨⟨first, Nat.lt_of_not_ge last, target⟩, immutable⟩, distinct⟩, integer⟩, impure⟩

/-- The accepted native iterator names the original constant integer array
before its lexical element binder is appended. Every rejection guard is kept:
array identity, mutability, Boolean kind, masking, and pure-body exclusion. -/
theorem arrayHeader_original {calls : Calls} {source : Input} {iteration : Iteration}
    (iterable : loopIsArray source.text source.input.scan = true)
    (parsed : forHeader (loopHeaderReaders calls) source
      (tokenAfter source.text source.input.scan.position (.word "for")) = some iteration) :
    loopArrayAllowed source.text source.context source.input.scan = true ∧
      iteration.first = (loopHeader source.text source.context source.input.scan).first ∧
      iteration.last = (loopHeader source.text source.context source.input.scan).after ∧
      iteration.value.scan.position = (loopHeader source.text source.context source.input.scan).entry.position ∧
      iteration.value.scan.facts = source.input.scan.facts ∧
      iteration.bounds = (loopHeader source.text source.context source.input.scan).bounds ∧
      iteration.definite = true := by
  obtain ⟨impure, guard, same⟩ := arrayHeader_accepted (forHeader_array iterable parsed)
  have start := array_start calls source iterable
  rw [start] at guard same
  simp only [rejectedArrayIterator, loopHeaderReaders] at guard
  have allowed : loopArrayAllowed source.text source.context source.input.scan = true := by
    exact iterator_guards _ _ _ _ _ _ _ guard impure
  refine ⟨allowed, ?_⟩
  rw [same]
  simp only [loopHeaderReaders, loopHeader, iterable, ite_true, allowed,
    LoopHeader.bounds, tokenAfter, ShellToken.word, atPosition]
  exact ⟨trivial, trivial, trivial, trivial, rfl, trivial⟩

/-- Both original header routes determine the same binder, opening cursor,
incoming facts, interval and iteration-existence flag as the inherited reader. -/
structure OriginalHeader (source : Input) (iteration : Iteration) : Prop where
  first : iteration.first = (loopHeader source.text source.context source.input.scan).first
  last : iteration.last = (loopHeader source.text source.context source.input.scan).after
  position : iteration.value.scan.position = (loopHeader source.text source.context source.input.scan).entry.position
  facts : iteration.value.scan.facts = source.input.scan.facts
  bounds : iteration.bounds = (loopHeader source.text source.context source.input.scan).bounds
  definite : iteration.definite =
    if (loopHeader source.text source.context source.input.scan).isArray then true
    else Integer.loopDefinite (loopHeader source.text source.context source.input.scan).lower.bounds
      (loopHeader source.text source.context source.input.scan).upper.bounds

theorem forHeader_original {calls : Calls} {source : Input} {iteration : Iteration}
    (arrays : source.context.ArraysReady source.text)
    (parsed : forHeader (loopHeaderReaders calls) source
      (tokenAfter source.text source.input.scan.position (.word "for")) = some iteration) :
    OriginalHeader source iteration := by
  cases iterable : loopIsArray source.text source.input.scan with
  | false =>
    have original := forHeader_counted iterable parsed
    have positions := countedHeader_positions calls source iterable
    have bounds := countedHeader_bounds calls source iterable arrays
    rw [original]
    refine ⟨positions.1, positions.2.1, positions.2.2.1, positions.2.2.2, bounds.1, ?_⟩
    simpa only [loopHeader, iterable, Bool.false_eq_true, ite_false] using bounds.2
  | true =>
    obtain ⟨_, first, last, position, facts, bounds, definite⟩ := arrayHeader_original iterable parsed
    refine ⟨first, last, position, facts, bounds, ?_⟩
    simpa only [loopHeader, iterable, ite_true] using definite

end Silver.ApplicationPackageBodies.Statement
