# Guarded Hashtbl prefix evidence, 2026-10-20

The [argument](../../research/retained-why-save-hashtbl-prefix.md) establishes
the conditional source/native contract for shared save tables whose complete
insertion counts satisfy the no-resize guards. Entry state and numeric
instantiation remain explicit lead-owned inputs. Independent review is pending.

| File | Purpose |
| --- | --- |
| `inputs.json` | Exact base, reused source archives, arguments and accepted reviews. |
| `source-witnesses.json` | Exact member hashes and line excerpts for the implementation and clients. |
| `native-bodies.json`, `native-witnesses.json` | Twenty bodies projected from retained disassembly, with exact selected executable identity and instruction bytes. |
| `table-interface.json` | Required fields, actual selected table families and uninstantiated rows. |
| `transfer.py` | Arithmetic consumer with null preservation and explicit premise gates. |
| `check.py`, `check-result.json` | Focused source/ELF projection and guard boundary checks; no predecessor replay. |
| `result.json`, `round.json` | Scope, remaining join, settings and available timing. |

From the worktree root:

```sh
python3 docs/evidence/retained-why-save-hashtbl-prefix-20261020/check.py
```

The installed executable path comes from `native-witnesses.json`; it is read
as data and must match the retained SHA-256. Optionally reproduce the body
projection from the existing 69 MB disassembly text with
`--disassembly /tmp/silver-why-callback-closure-disassembly-20261018.txt`.
No disassembler, target, capture or proof tool is launched. The source/native
argument uses the existing external behavior relation, not a universal compiler
refinement theorem. Synthetic arithmetic cases are boundary checks, not actual
entry observations or a proof of the invariant by sampling.
