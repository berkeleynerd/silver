# Selected null linker representation composition

Linux x86-64, 2026-10-18, research for #119. The
[source argument](../../research/retained-linker-null-composition.md) composes
fixed-input read projections with every selected variable Main, local-symbol,
CFI, table, layout and relocation representation. It adds concrete bounds for
input readers/mmap rounding, BFD IDs, LD start/stop and section-check arrays,
and LD iteration counters. The selected ld/BFD representation flag is true
under the explicit source/descriptor/interface premises; broader grammar and
the complete tool pipeline remain false.

Files:

- `check.py`: callable offline composition checker. It verifies the20 pinned
  prerequisite result identities, hashes15 installed fixed inputs and their
  1,161 archive members, checks zero COMMON records and the two script prefixes,
  reads the installed ld's target vector/initial IDs without executing it,
  and computes the supplemental bounds.
- `inputs.json`: exact prerequisite record paths, lengths and SHA-256 values.
  The records' source arguments and separately retained checks remain part of
  the contract; hashing a result is not a proof of its source reasoning.
- `sources.tar.gz` and `sources.json`:38 complete supplemental Binutils files
  at source commit`5e56594815854de5eca35c7c04b11705d0f19c02`, archive and
  per-file identities. Source citations count literal LF bytes.
- `target-projection.json`: expected18 configured target names, terminal NULL,
  object ID initial0 and section ID initial16, bound to the selected ld digest.
  The checker reconstructs these from its ELF sections/symbols and data bytes.
- `result.json`: retained output. Object-ID increments≤3,288; section-ID high
  water≤268,632; start/stop capacity327,670 pointers; section-address-check
  storage783,440 bytes; at most16 statement and9 non-mark sizing iterations.

From the integrated repository root:

```sh
python3 docs/evidence/retained-linker-null-composition-20261018/check.py \
  --prior-repo . --output /tmp/retained-linker-null-composition-replay.json
cmp docs/evidence/retained-linker-null-composition-20261018/result.json \
  /tmp/retained-linker-null-composition-replay.json
```

In the author lane the prior records were read from
`../retained-tool-capacity`. Independent native-lane review replayed the
checker and inspected the object constructor, archive cache/temporary probe,
format restore, COMMON exclusion, script-format guards and selected
reopening/exclusion paths. Its review-state output is retained at
`/tmp/native-review-linker-null-composition.json`; that historical output
correctly has the closure flag false because acceptance had not yet been
recorded. Its numerical envelope matches this result. Integration review read
the composition and
supplemental LD joins. Review acceptance supplies the manual source transfer;
the boolean is not inferred solely from arithmetic or the historical witness.

The checks use Python and read bytes only. No compiler, assembler, linker,
solver, prover, Lean build, test suite or native program was executed for this
packet. It introduces no admission rule or physical-memory requirement. Host
page size remains the existing parameter G and is not inferred from ELF
layout alignment. The installed fixed inputs/tool must still be available
at the pinned descriptor paths to replay their byte checks.
