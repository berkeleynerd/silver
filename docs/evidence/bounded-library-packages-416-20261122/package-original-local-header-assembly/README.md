# Original package routine-local declaration schemas

Refs #416. Review found that normalized routine initializer phases retain
values and target intervals but omit raw inline range endpoint arithmetic.
`PackageSyntax` now retains every original routine-local `ObjectSyntax` header
in completion order, including unused routines and empty headers. Each header
keeps the actual signature metadata and each declaration's incoming scope.
The syntax relation contains no checker or discharge certificate.

`package_syntax` constructs the headers from the original native histories and
derives their full raw range/RHS discharge separately. The package header
aggregate now appends `routineLocalHeaderObligations`, so the existing final
semantic aggregate receives these families automatically.

Prerequisite `7ff7808ad44e9f12635c7df7f4b05630148ce525` supplies
`ApplicationPackageOriginalLocalHeaders` and its independent focused evidence.
That file was synchronized as a baseline dependency and is not owned by this
integration commit. The only import difference identified against the helper's
checked closure was the integration tree's additive `PackageEffectSummaries`
lemmas/import; this integration check includes that tree.

Focused Linux `ApplicationPackageOriginalAssembly` validation passed a fresh
91,789-declaration audit. All 1,760 captured inputs matched on rehash, and both
the owned assembly and imported helper matched protected workspace copies.
The exact run/digests are in this packet. CPU allocation was 0–1, automatic two
workers and two threads per process, with 8192 MiB per process.

This closes the package-local raw range finding at the assembly boundary.
The separate Main inline Integer constraint inventory and final combined
endpoint check remain outstanding here. Complete source/native/project
validation stays with the lead.
