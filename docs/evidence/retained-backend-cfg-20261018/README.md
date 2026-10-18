# Initial CFG cleanup, loop-discovery and SSA evidence

Source pin: GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
Date: 2026-10-18. Native analysis host: Linux x86-64.

The [component report](../../research/retained-backend-cfg.md) supplies the
manual source/reachability argument and identifies unresolved interfaces.
This package checks source identity, retained excerpts, selected source guards
and finite arithmetic. It does not execute a compiler, test programs, proof
solver, Lean, complete audit, macOS or CI.

Artifacts:

* `source-manifest.json`: full-file sizes and SHA256 hashes, independently
  reconciled with the pinned source archive's retained `manifest.json`.
* `source-excerpts.md`: numbered source excerpts supporting the report.
* `checks.json`: offline check result and explicit open interfaces.
* `check.py`: standalone reproducer outside the proof-provenance scripts tree.

Reproduce against the existing source copy:

```sh
python3 docs/evidence/retained-backend-cfg-20261018/check.py \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source \
  --output /tmp/retained-backend-cfg-check.json
```

The source copy's top-level `manifest.json` identifies the archive URL and
commit. The reproducer checks every consumed source against both that manifest
and this package's full-file identities. `--capture` was used only to create
these initial text artifacts; it refuses to overwrite existing artifacts.
`--refresh` regenerates the derived text after an intentional source-analysis
change; it does not run a compiler. It was used to extend the retained excerpts
and arithmetic when closing the signed-counter obligations and extending the
analysis through the O0 fixup bridge and initial SSA construction. The package
now pins 47 source files. No successful compiler/proof capture was repeated for
these increments.

The small tree enumeration checks the ancestor-slot arithmetic on 5,913 tiny
rooted trees; it does not validate GCC loop discovery or replace the general
counting argument. Representative arithmetic likewise does not prove the
matcher bounds, cleanup termination, dominator correctness, or a whole-pipeline
capacity predicate. The source/path argument in the report now supplies the
cumulative signed `graphds_domtree` bound. The package additionally checks a
transcription of its parent-chain iteration on all 313 reachable graphs with
two through four vertices under the stated edge frontier, plus 256 seeded
larger graphs. Final candidates are compared with an independent set solver.
These finite checks support the transcription; they do not establish the
universal bound or replace its manual invariant argument.

The SSA arithmetic derives LP64 layouts from source fields, checks the PHI
allocator's signed-shift boundary and rounded-capacity inequalities at small
degrees and power-of-two boundaries, and checks operand-slab capacities at
their allocation transitions. These are integer and source-layout checks, not
compiler `sizeof` captures. The report supplies the per-variable/per-block
counting argument and explicitly leaves intermediate-pass composition, generic
allocator/lifetime composition, and downstream backend stages open.

The out-of-SSA extension adds coalescing-record/partition layouts and the
signed cost accumulator's sufficient condition. A finite transcription of its
liveness worklist is checked on every directed graph with one through three
blocks and every one-partition definition/use mask: 33,032 cases, including
self edges. Results are compared with a separate synchronous set-equation
solver. This supports the worklist transcription; the report's monotone-bit
argument supplies the general visit bound. PHI-elimination copy requests are
bounded by a manual visited-node argument. RTL helper allocations and the
intermediate O0 pass input join remain explicit work.
