# Native-repair semantic check: failed, retained

The Linux focused run on `68c4fd259b` exited 1 at 09:10:38 UTC on 2026-11-08,
after 200.406 s managed / 172.551 s building. It compiled the unconditional
zero-input lemmas, typed guard trees and `actuals_model` denotation. Two downstream
proof scripts left definition wrappers unreduced: `returnAfter_model` needed
`apply2` and `apply4`, and the comma branches in `normalized_actuals_at` needed
`modelCalls`.

Commit `f630819154` adds only those definition expansions. It changes no native
source, model definition, theorem statement or domain. The next focused check
retains successful objects and still requires the original conclusions and fresh
audit. This failed run completed no focused assurance audit.

[index.json](index.json) identifies the exact log, managed events and read-only
memory observations. All three compressed artifacts were independently checked
against their decompressed lengths/hashes and original bytes before reuse.
The observer ended normally after the finished event; no process was signalled.
