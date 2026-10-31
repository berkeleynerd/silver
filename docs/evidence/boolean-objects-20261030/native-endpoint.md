# Boolean native endpoint proof checkpoint

Issue #291, native Linux x86-64, 2026-10-30. This subthread inherited selected
GPT-6 Astra / Extra High; no independent runtime model confirmation, token usage,
or cost measurement is available. It did not spawn further agents.

The endpoint work retained arbitrary native initializer arrays on their checked
`ValidInitials` domain. Boolean metadata, literal hiding and initializer masks
remain in the context. Eager operators receive the incoming flow, and xor checks
retain the original source cursor. The contracts do not narrow the domain to
source-allocated or initialized-prefix arrays.

| Checkpoint | Result | Recorded native tool time |
| --- | --- | --- |
| `43d8ec80f7`: Model, Progress, Ranges | Focused model check and fresh axiom audit passed, 14,326 declarations | Build 70.967 s; audit 84.252 s |
| `7ce80c0f32`: Correspondence, Contracts, ModelSizing | Focused sizing check and fresh axiom audit passed, 14,806 declarations | Build 97.911 s; audit 9.078 s |
| `5e2479c08d`: Helpers | Focused helper check and fresh axiom audit passed, 16,021 declarations | Build 18.252 s; audit 7.655 s; complete runner 47.66 s |

All checks used one managed worker, one Lean thread, 8192 MiB, Lean 4.34.1,
and the existing independent endpoint cache. They were incremental builds with
fresh audits; they were not clean builds or kernel replay. The helper result is
run `20261030T112352-d7f150247720`. Its exact input digest, module list, tool hashes
and compressed original log are retained in `native-endpoint/`.

The substantive rework was local equation simplification, explicit initializer
arguments in count lemmas, and normalization of checked helper calls. Source
review identified that the initial lexical helper draft was too broad: equal
names now require two valid nonempty source spans, and name matching requires
a valid source span and a nonempty word of at most 16 characters. The Boolean
atom and mask proofs derive these conditions before using the helper equations.
No arbitrary out-of-domain lexical equivalence is assumed.

The source subthread separately owns `PredicateNativeLibraries` and downstream
body/library integration. Whole-project coverage, integrated source correspondence,
native obligation discharge, final assurance and capability status remain with
the lead. These focused checkpoints do not complete #291.
