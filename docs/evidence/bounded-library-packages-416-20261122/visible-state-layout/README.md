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
