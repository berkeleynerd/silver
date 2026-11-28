# Arbitrary uninitialized State_Set storage

Focused DeclarationLaws run `20261122T191904-d99cfed764b8` passed with a fresh audit of
20,533 declarations at 2 workers / 2 threads on Linux x86-64. State_Set declarations
without an initializer preserve all incoming fixed-array cells; the new
Initialization.stateSet_arbitrary theorem states that equality directly.
Declaration.implicitSupported now admits that native form. No empty-state default
is introduced. This supports the package-call source that assigns Item.May_Write
before reading Call_Writes. The call's native/source proof is a separate check.
