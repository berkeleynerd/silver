# Exact application source bundle — focused checkpoint

Implementation `c84b73b6ba` integrates `e042255a1f` without changes. Linux x86_64
canonical focused run `20261122T125009-00cc034988d0` passed all **81 checks**
(12 flow, 69 proof) across seven entities on November 22. Managed duration
was 10.422 seconds; automatic allocation eight workers, affinity CPUs 0–7,
16 MiB invoking stack. The command was `dev.py prove --unit
silver_application_units.adb --task packages-416-source-bundle`, at the unchanged
canonical native policy.

The complete unit covers Fits, Valid, Unit_Span, Unit_Source, Prefix and Pack,
including arbitrary input String bounds, exact copied bytes, offsets, zero tail,
preconditions, arithmetic/range/length/index safety, dependencies and termination.
No proof contract or input domain was weakened. Silver_Profile contributes only
the existing Max_Source_Length constant; future parser/driver callers still need
focused coverage when integrated. This is not whole-compiler assurance or new
language support.

`events.jsonl.gz`, `native.log.gz` and `focused-evidence/` preserve the actual
run and audited report identities. The compile/assertion driver is retained
alongside its project. Its earlier managed compile and execution runs were
`20261122T124810-1e29b39f975b` and `20261122T124826-55a24a5f37d3`, respectively.
They exercise empty/oversized inputs, arbitrary high bounds, exact CR/LF/comment/
NUL/non-ASCII bytes and the 4,096-byte boundary. Storage preserves arbitrary
bytes; later admission owns the source-alphabet check.

Implementation selected GPT-6.1 Sol Extra High, contract design GPT-6 Astra Max;
runtime settings and token/cost totals are not independently exposed. No broad
native/Lean/regression checkpoint was run for this helper.
