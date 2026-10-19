# Interval native-effect frontier, 2026-10-19

Companion [research argument](../../research/retained-why-interval-native-effects.md),
research [#119](https://github.com/berkeleynerd/silver/issues/119). **Focused
obstruction, not complete native-effect closure.** The four timing hooks omit
the reachable major-GC hook and root scanner/systhreads predecessor dispatch.
This is distinct from #143's shared-base address-lowering gap. No actual unknown
nonnull hook or interference is observed; initial configuration, preservation
and dispatched effects remain separate obligations. Seven selected cells are
not asserted to exhaust the interval's application callback interfaces.

Base: `fa85a5ea0d`. Selected author: **GPT-6 Astra / Extra High**, from parent
spawn settings. Runtime confirmation, token totals and monetary cost are
unavailable. Host: Linux 7.0.14 x86_64. Ordinary collector, allocation, libc and
numeric behavior uses the existing external contract; no re-proof of those
implementations is proposed. No production, Oracle, source pin or admission
change. Complete `R` and exceptional identifier charge remain null.

| File | Scope |
| --- | --- |
| `inputs.json` | Exact inherited evidence identities |
| `source-witnesses.json` | Eight pinned OCaml source files with selected line excerpts; source archive and member identities |
| `native-bodies.txt`, `native-witnesses.json` | Eleven named installed bodies, 9,040 matched bytes including padding, seven selected symbols; no global address census or complete caller/setter analysis |
| `hook-read-coverage.json` | Original four-cell read-coverage result retained unchanged |
| `expanded-read-coverage.json` | Existing two read streams checked for overlap with all seven targeted cells; none found |
| `caml_z.c`, `z.ml`, `big_int_Z.ml`, `zarith-retrieval.json` | Official Zarith 1.14 source and URL/status/hash/timing records; a build-path string alone does not prove historical source identity |
| `check.py`, `projection-check.json`, `check-result.json` | New focused evidence checks and measured outcomes |
| `round.json` | Selected settings, task outcome, rework and elapsed time; unavailable measurements remain unavailable |

From the worktree root:

```sh
python3 docs/evidence/retained-why-interval-native-effects-20261019/check.py
```

The default checks inherited input identities, source excerpts, retained native
byte witnesses against the selected installed executable, and downloaded source
identities. It reads frozen read-coverage results without rescanning the two
streams. The initial new projection/read check completed in about **3.52 s**.
The earlier four-cell-only coverage check completed in about **3.38 s** and is
retained as a distinct observation. Neither executes the captured target.

To recompute the narrow coverage result, when needed:

```sh
python3 docs/evidence/retained-why-interval-native-effects-20261019/check.py --rescan-reads
```

The streams are members of the accepted save-state `capture.tar.gz`, for run
`20261019T000304-fcb988ec2c03`, PID 97103. Main load bias is `0x55a661b32000`.
There are 835,579 and 49,728 records, checked as overlapping byte ranges, not
only equal start addresses. Their member identities match the original
retained coverage check. No overlapping read means **unobserved**, not zero.

To reproduce the selection from the already retained disassembly, when needed:

```sh
python3 docs/evidence/retained-why-interval-native-effects-20261019/check.py \
  --disassembly /tmp/silver-why-callback-closure-disassembly-20261018.txt
```

The input must match its accepted 69,046,582-byte SHA-256 identity. Selection is
by eleven explicit function names; no all-address hook census is repeated.
`--write` with `--disassembly` rebuilds the projections and coverage result.
`--image PATH` permits the same pinned ELF at another local path. Default checking
needs no `/tmp` disassembly. The script checks evidence correspondence, not the
semantic argument or completeness of the native interface set.

The one extraction-script repair handled duplicate unrelated local ELF symbol
names by restricting symbol checks to the owned function/cell selection. The
failed first attempt stopped before writing projections; its zero-length output
was replaced by the successful result. No source/behavior conclusion depended
on that failure. See the round record for the final default check.
Authored whitespace and seven local file-link targets pass. Raw upstream
Zarith files and exact disassembly excerpts retain their original whitespace;
the full whitespace report flags only those imported records, which are not
reformatted to make an authored-style check pass.

No captured process, old checker, graph or binder certificate was replayed.
No target, build, solver, Lean, corpus, new capture or global native census ran.
Managed status had zero reserved workers and no required diagnostics. The lead
owns independent review, integration, issues, board, durable/CLI memory and
publication; this packet does not report those as already completed.
