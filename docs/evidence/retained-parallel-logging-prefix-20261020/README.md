# R55 parallel logging prefix evidence

See [the research note](../../research/retained-parallel-logging-prefix.md) for
the exact conditional claim, GC phase correction and serial-table scope.

Run from any directory:

```sh
python3 -B docs/evidence/retained-parallel-logging-prefix-20261020/check.py
```

The command is shown relative to the repository root. It verifies pinned
retained archives and installed ELF bytes, recomputes the two **new** finite
projections, and prints a result without changing the packet. The pinned Linux
x86_64 executable must be available at the path in `installed-byte-witnesses.json`.
It launches no inferior, solver or predecessor checker.

- `cut-projection.json`: actual J12 configuration, native session counters,
  R54 root maps and prospective logging allocation/resource credits.
- `input-role-projection.json`: full-path-role/identity join of old serial and
  J12 inputs. Input_Is_Valid's old table is explicitly at the later first-CE cut.
- `source-witnesses.json`, `control-use-scan.json`: source slices and complete
  ten-file GNAT logging/parallel use inventory, checked against source archives.
- `installed-startup-disassembly.txt`, `installed-byte-witnesses.json`: static
  GDB `disassemble /r` output and 962 instruction rows joined to ELF bytes.
  Acquisition used GDB `-nx -q -batch`, auto-load disabled, `file`, then selected
  disassembly commands; no `run`, `start`, `attach` or inferior function call.
- `inputs.json`: frozen input and packet file hashes. `check-result.json` and
  `round.md` record the focused verification; the checker never rewrites pins.

The source argument reuses accepted R53 whole-raw graph correspondence and R54
restricted alpha-opening/root attribution. It does not repeat their successful
native captures or claim a logging-enabled capture was performed.
