# Polymorphic copy

**Candidate: proofs likely to discharge automatically.** A class-wide copy initialized from a class-wide parameter, followed by a dispatching procedure call, raises no run-time check that can fail and needs no loop, arithmetic or heap use. So proof depends only on SPARK admitting tagged types and dispatching, which it does without annotations.

Position 1552 in the [progression](../../progression.md#stage-33), in stage 33.

## Approach

A package declares a tagged null record T with a primitive procedure Show that prints "T", and a child-level package derives S from T and overrides Show to print "S". A procedure Copier takes an X : T'Class parameter, declares a local class-wide object Duplicate : T'Class := X (a real copy, not a reference or heap clone), and dispatches Duplicate.Show. Main calls Copier with a T object and an S object, so no access types, loops or arithmetic are involved. About 45 lines.

## Proof obligations to watch

- **other**: Flow analysis of the dispatching call relies on the generated Global of the root primitive covering the overriding, which holds because T's and S's Show procedures both touch only Silver_IO's output state.

## Language surface recorded by this assessment

Packages, tagged types and procedures.

## External effects

- **console output** (allowed): The program prints the result of calling the overridden method on each copy to show that the copy's specific type is S.

Assessed on 2026-10-15 against page revision 414407 of the [task](https://rosettacode.org/wiki/Polymorphic_copy) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
