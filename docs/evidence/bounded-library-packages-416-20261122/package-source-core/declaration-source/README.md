# Declaration reader source proposals

The Signature candidate checks the complete 1,536-token native body with its
typed declarations, control flow, stores and annotations. It checks unique
body extraction, the Signature header, the full Append_Package_Formal contract,
the native defaults of Routine and Formal, and the scalar Append expression
and precondition. The copied Signature, Specification and Append procedures
from `a0c9a978fa` are byte-identical at `8e766b6712`. The authoritative
profile still needs to instantiate the checked-source requirements.

| Linux x86-64 focused run | Scope and result |
| --- | --- |
| `20261127T123421-f6f934af9526` | Executable comparison matched 1,536 Signature and 739 Specification body tokens. Other targets failed in this batch. |
| `20261127T123543-3ae1a53e8432` | Monolithic kernel candidate intentionally interrupted after 375.528 seconds. The last sample at 364 seconds was 42,539,424 KiB RSS. |
| `20261127T130642-dcae050f4ec1` | Unique Signature body and complete Signature/Append header extraction passed. Incremental build 47.473 seconds, fresh audit 22,894 declarations in 3.167 seconds. |
| `20261127T130810-36ee39fa9f49` | The split render reached the list-composition proof. Direct definitional reduction failed for the mutually recursive renderer and the outer loop syntax. |
| `20261127T131113-88e64e0b2eae` | All section renders, their composition and the complete Signature/Append candidate passed. Incremental build 78.100 seconds, fresh audit 23,005 declarations in 3.389 seconds. |

Both successful runs used two workers, two threads per process and a diagnostic
Lean memory setting of 8192 MiB per process. The final run's sampled process
high-water mark was 7,153,836 KiB. Independent literal source ranges let
the kernel check the typed sections separately. The loop proof composes those
equalities using the renderer equations. The independent Append spelling is
split at original line boundaries. Source identity, full reader interpretation
and delivery assurance retain their separate integration checks.

## Specification and strengthened Object sources

The Specification proposal covers its complete 739 body tokens, contract,
export record defaults and the omitted Local argument's Object header. The
Object proposal covers its complete 730 body tokens, record defaults and
Read_Expression specialization. The source at `8e766b6712` adds explicit
upper bounds for Object's Init_First and Init_After, adding 26 header tokens.
Both proposals include those bounds. The native focused run
`20261127T125548-44ef65f45db0` checked the strengthened helper's 30 obligations
on the primary source.

| Linux x86-64 focused run | Scope and result |
| --- | --- |
| `20261127T131446-7e2fee55356e` | The Specification source parts compiled. The renderer batch failed on an unused direct-body simplification rule in the else branch. |
| `20261127T131725-b6591b685187` | The corrected complete Specification proposal passed at 8192 MiB per process. Incremental build 21.205 seconds, fresh 22,995-declaration audit in 3.161 seconds. |
| `20261127T131816-71f98eb40e58` | The Object candidate failed at its scalarSpecialization field. Kernel reduction of the long Read_Expression header exceeded the diagnostic 12,288 MiB limit. |
| `20261127T132352-317e899d778f` | The independently spelled scalar header and result record, split at original line boundaries, passed at 8192 MiB. Build 16.287 seconds, fresh 21,118-declaration audit in 3.093 seconds. |
| `20261127T132439-880acf1cced5` | Both complete Object and Specification proposals passed together with the independently checked scalar facts. Build 75.849 seconds, fresh 23,056-declaration audit in 3.156 seconds, two workers and two threads, limit 12,288 MiB per process. |

The copied Object source fragment digest is
`b6eba92d5e413524bea9058ae80f4f3315d8d975d4014e3b7a4a1e1a7ae26a62`.
The copied Specification plus its strengthened Object header has digest
`70b741d1d1adf438e07a1f26bbc3a7fa42c08ee42f178483323d8e752832b6f9`.
The authoritative original-file binding and complete typed-to-raw reader
simulations remain with their respective integration checks.
