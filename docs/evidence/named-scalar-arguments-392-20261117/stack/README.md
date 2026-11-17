# Compiled association storage — #392

Read-only disassembly of the incremental Linux aarch64 build
`20261117T033259-3ca6b2ad891b`, using the pinned GNAT toolchain's objdump.
The object and source hashes are in `identity.json`. The normal build enables
assertions and does not request optimization. This is a compiled-layout
observation, not a universal stack bound or a performance improvement claim.

The source-derived `Formal_Set` contains 585 Boolean slots. `Mark_Formal`
returns a set by value. In this build its outer frame is 688 bytes and its
wrapped expression-body frame is 640 bytes; the generated code copies 585
bytes and checks the complete quantified postcondition. These frames are
transient per call. Runtime association walkers are loops, so visited-set
frames do not accumulate recursively with the number of actuals.

| Routine | Outer fixed frame | Wrapped body fixed frame |
| --- | ---: | ---: |
| `Actuals_After` | 400 bytes | 1376 bytes |
| `Procedure_Actuals_After` | 400 bytes | 1360 bytes |
| `Procedure_Updates` | 656 bytes | 1872 bytes |

`Procedure_Updates` also has two count-sized dynamic local stack reservations
(`sub sp, sp, x0`) and secondary-stack mark/release calls. The 1872-byte entry
therefore describes its fixed frame only, not all of that routine's local storage.

These figures are local fixed frames, not maximum complete call-chain consumption;
callee frames, compiler metadata, runtime/secondary-stack activity and other
existing state also contribute. No heap/stack optimization is claimed. The
final named-argument tests, including many-formal and complete-source boundary
cases, passed with the established 16 MiB process stack. The final complete
repository suite remains a separate validation requirement.
