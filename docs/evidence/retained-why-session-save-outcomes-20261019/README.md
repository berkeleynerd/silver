# Bounded save outcomes, 2026-10-19

Companion argument: [retained save outcomes](../../research/retained-why-session-save-outcomes.md).
Research [#119](https://github.com/berkeleynerd/silver/issues/119), selected
GPT-6 Astra / Extra High, Linux x86_64. Runtime model/effort confirmation,
token usage and monetary cost are unavailable.

This packet adds two bounded results to accepted inputs at
`040fba6e247e3735f9731a7581ec609b251d4a78`:

- Typed closure of all 66 retained session formula roots, including deferred
  substitutions, gives names at most 47 bytes and only small immediate integer
  constants. The accepted occurrence certificate permits at most 1,435
  name-assignment calls for each fresh shape printer; four-digit suffixes and
  constant-output expansion give a maximum shape-buffer extent of **1,074 bytes**.
- The first `Trans.fold` private cache has no writes during backward accumulation.
  A save-origin `Not_found` caught at its retained eligible `current` poll takes
  the already-accounted miss continuation, without replaying inlining work.

The typed closure also has no `Tcase`/pattern nodes, removing that specific
binder-opening logical-exception route. The per-save global shape insertion
count is at most **315**, before another attempt resets it. These are source
arguments under the listed premises, not machine-checked OCaml semantics.

## Contents and checks

| File | Purpose |
| --- | --- |
| `inputs.json` | Exact hashes of frozen capture, accepted binder certificate, source archives and reused native-prefix evidence |
| `atom-certificate.json` | Formula roots, every typed term/read pointer, identifier strings, integer values, constructor counts and derived bounds |
| `source-excerpts.json` | 41 excerpts with archive-member identities and exact line ranges |
| `runtime-limits.json` | Three retained-disassembly instruction windows, 37 bytes matched to the pinned ELF, attaching the actual 64-bit string limit |
| `check.py` | Recomputes only this new atom projection, arithmetic, excerpts and three byte windows |
| `result.json` | Final focused check result and elapsed checker time |
| `round.json` | Scope, selected settings, elapsed wall time, findings and remaining join |

Run from the repository root:

```sh
python3 docs/evidence/retained-why-session-save-outcomes-20261019/check.py
```

The checker reads the already retained capture and source archives. Its byte
check reads the installed ELF as data at its pinned host path. It starts no
target process or disassembler. It does not import or rerun the old binder,
capture-replay, registry or corpus checkers. `--write` regenerates this packet's
deterministic records only; the final check uses the comparison mode.

The accepted formula forest is an input to this new extraction. Repeated
occurrences are deliberately deduplicated only for atom coverage; existing
opened term/binder counts retain their original multiplicities. The checker
rejects missing required blocks, mismatched layouts/roots, non-immediate integer
payloads, and a changed instance that fails its stated bounds. It does not prove
the imported forest theorem, mutable-state preservation, numeric-library
correctness, or the source argument in the note.

## Limits

The bound excludes the named shape-buffer maximum-string-length failure under
preserved inputs and no interfering buffer/printer mutation. It does not exclude
all `Failure`, bounds/assertion failures caused by reentrancy, physical resource
failures, other helper exceptions, debug/error buffers, or a later normal-ending
save on a changed forest. The remaining finalizer/alias and complete
exception/continuation joins stay explicit. No native, solver or broad test was
run; previously successful evidence is reused unchanged.

**`complete_R` and `exceptional_identifier_charge` remain null.** The conditional
`counter_end <= 63,573 + 2R` interface is unchanged; 63,573 is not an established
endpoint. Parent owns independent review, integration, GitHub, session memory,
the live harness and publication. CLI memory was not updated here.
