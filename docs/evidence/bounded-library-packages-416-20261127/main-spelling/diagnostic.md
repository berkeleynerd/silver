# Main spelling focused diagnostic, 2026-11-27

The first draft had a Nat/Int loop-offset inference mismatch, a findSome
simplification that unfolded past the induction hypothesis, and one arithmetic
lemma name. The second draft left only the explicit Int coercion normalization
and a second untyped callback. Both were repaired without domain/budget changes.
The third draft elaborated the full theorem; warning-as-error rejected an unused
simp argument. Remove that argument, then check the full-domain theorem together
with the exact candidate tree. No integrated proof run is being attempted.
