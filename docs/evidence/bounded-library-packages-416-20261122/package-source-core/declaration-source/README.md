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
