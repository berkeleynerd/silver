# Source-derived visible-state layout, first checkpoint

`ApplicationPackageVisibleStateLayout.lean` derives state defining-span order and
name validity from the actual StateObjects history. Positive state ordinals with
equal original defining spans are equal. Visible integer and Boolean state
lookups therefore select the exact same global identity in the concrete layout.
The model also returns State_Target = 0 at cursor 0, over arbitrary metadata.

Focused Linux validation: `20261127T193146-c63e7d293144`, two workers, two Lean threads,
8192 MiB/process. Existing dependency objects were reused; the new target was
compiled and its 32,409-declaration axiom audit was fresh. This is partial
validation. No full OutputBody or final admission theorem was checked.

Remaining work: source-derived no-later-shadow preservation, reverse visibility,
exact reset membership/ranges, and State_Target correspondence for parsed targets.
No whole-text metadata validity assumption was added to source prefixes.

## Actual target identity and shadow primitives

StateDeclarations now also derives distinct state spellings from each original
Object freshness guard. `stateTarget_integer_iff` and `stateTarget_boolean_iff`
connect the original target span and its native lookup to the exact global
layout identity. The Boolean case retains the scalar-precedence check.

The new GlobalShadowHistory module supplies preservation under removal and
append, successful Hide_Outer exclusion, and the lookup-zero exclusion lemma.
The complete state/formal/local/output history and reset bridge remain next.

Run `20261127T194059-6b59a5718f41` passed both focused targets and a fresh
32,449-declaration axiom audit. The State_Target target was compiled in preceding
run `20261127T194001-ce0271c23360`; the successful run reused that matching
object and compiled GlobalShadowHistory after fixing its qualifier reduction.
