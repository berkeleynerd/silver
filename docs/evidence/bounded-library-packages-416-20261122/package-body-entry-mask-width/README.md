# Original routine body entry mask widths

Refs #416. `ApplicationPackageRoutineInitializerEffects.body_input_width`
derives the complete native read/write mask widths from each original
`CompletionFrames` history. Local and output initializer steps preserve the
fixed array width; the body starts with the exact initialized read mask and
the native empty write mask. No semantic checker, body-effect or safety
certificate is an input.

Focused Linux validation passed for `Silver.ApplicationPackageRoutineInitializerEffects`
with a fresh 84,618-declaration transitive axiom audit. The managed runner used
CPUs 0–1, automatic two workers and two threads per process, and 8192 MiB per
process. Every captured source input was rehashed after the run with none
missing or changed. The retained index and evidence identify exact inputs.

This is focused proof evidence. Recursive body effect inclusion, the final
original application assurance join, and complete validation remain separate.
No native source, source pin, input domain or proof budget changed.
