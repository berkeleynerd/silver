# Original Main declaration obligation coverage

Refs #416. Review of `53bc4fca4a` found that Main's enumerated predicate
obligations omitted the String/Character declaration range and length schemas,
including the optional argument. Runtime store fit did not establish automatic
discharge of those omitted checks.

`MainSyntax.obligations` now includes those `Compose.Check` families and the
canonical Boolean declaration obligations alongside the retained raw scalar,
Boolean, local-callable and body obligations. The original optional argument
and declaration history derive their discharge. `original_main_bounds` derives
raw source initializer schemas, actual bound-store traces, initial/final bound
compatibility and final metadata/fit for both argument branches. Its schema
projection does not replace Main's package environment or runtime stores.

Focused Linux `ApplicationPackageOriginalAssembly` run
`20261128T023845-783bdc63837c` passed a fresh 91,761-declaration axiom audit.
All 1,759 captured inputs matched when rehashed, and the owned source matched
the protected workspace copy. The run used CPUs 0–1, automatic two workers and
two threads per process, and 8192 MiB per process. The two initial drafts exposed
local proof elaboration/name-resolution issues; no domain, budget or semantic
premise was weakened.

This packet checks the Main helper contracts. Final endpoint integration,
routine-local raw range coverage and its separate review remain outstanding
at this packet's checkpoint. Whole-source, native and complete-project checks
remain the lead's integration work.
