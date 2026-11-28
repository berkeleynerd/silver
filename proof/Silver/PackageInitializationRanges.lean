module

public import Silver.PackageInitialization

@[expose] public section

/-! Initializer inference preserves the declared domains reconstructed from
inputs and local declarations. The native frame bridge only needs to identify
this deterministic declaration fold with its visible declared-range table. -/
namespace Silver.Packages

def SharedRanges.Refines (current declared : SharedRanges) : Prop :=
  current.globals.Refines declared.globals ∧ current.locals.Refines declared.locals

theorem SharedRanges.refines_refl (ranges : SharedRanges) : ranges.Refines ranges :=
  ⟨Integer.Ranges.refines_refl _, Integer.Ranges.refines_refl _⟩

theorem SharedRanges.Refines.view {current declared : SharedRanges}
    (refined : current.Refines declared) (layout : FrameLayout) :
    (current.view layout).Refines (declared.view layout) := by
  intro index target found
  cases selected : layout.integers index with
  | global identity =>
      obtain ⟨bounds, present, included⟩ := refined.1 identity target
        (by simpa only [SharedRanges.view, selected] using found)
      exact ⟨bounds, by simpa only [SharedRanges.view, selected] using present, included⟩
  | «local» identity =>
      obtain ⟨bounds, present, included⟩ := refined.2 identity target
        (by simpa only [SharedRanges.view, selected] using found)
      exact ⟨bounds, by simpa only [SharedRanges.view, selected] using present, included⟩

def LocalInitializer.declare (item : LocalInitializer) (ranges : SharedRanges) : SharedRanges :=
  {ranges with locals := extendRanges ranges.locals item.target item.domain}

theorem LocalInitializer.check_refines {item : LocalInitializer} {before after declared : SharedRanges}
    (checked : item.check before = some after) (refined : before.Refines declared) :
    after.Refines (item.declare declared) := by
  simp only [check] at checked
  split at checked
  · cases target : item.target <;> cases domain : item.domain <;> cases value : item.value <;>
      simp only [target, domain, value] at checked
    all_goals try contradiction
    · rename_i identity targetBounds expression
      simp only [Option.bind_eq_some_iff] at checked
      obtain ⟨bounds, _, selected⟩ := checked
      split at selected
      · rename_i accepted
        cases Option.some.inj selected
        have included := (Bool.and_eq_true_iff.mp accepted).2
        refine ⟨refined.1, ?_⟩
        intro index interval found
        simp only [declare, extendRanges, target, domain] at found ⊢
        by_cases same : index = identity
        · subst index
          have equal : targetBounds = interval := by simpa only [Integer.put, ↓reduceIte, Option.some.injEq] using found
          subst interval
          exact ⟨bounds, by simp only [Integer.put, ↓reduceIte],
            fun _ within => Integer.Interval.included_sound included within⟩
        · obtain ⟨current, present, within⟩ := refined.2 index interval
            (by simpa only [Integer.put, same, ↓reduceIte] using found)
          exact ⟨current, by simpa only [Integer.put, same, ↓reduceIte] using present, within⟩
      · contradiction
    · split at checked
      · cases Option.some.inj checked
        simpa only [declare, extendRanges, target, domain] using refined
      · contradiction
  · contradiction

def initializerDomains : SharedRanges → List LocalInitializer → SharedRanges
  | ranges, [] => ranges
  | ranges, item :: rest => initializerDomains (item.declare ranges) rest

theorem checkInitializers_refines {before after declared : SharedRanges} {items : List LocalInitializer}
    (checked : checkInitializers before items = some after) (refined : before.Refines declared) :
    after.Refines (initializerDomains declared items) := by
  induction items generalizing before declared with
  | nil => cases Option.some.inj checked; exact refined
  | cons item rest ih =>
      simp only [checkInitializers, Option.bind_eq_some_iff] at checked
      obtain ⟨next, first, remaining⟩ := checked
      exact ih remaining (item.check_refines first refined)

end Silver.Packages
