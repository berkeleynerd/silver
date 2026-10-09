# Developing Silver

The [Oracle](oracle.md) governs correctness. [language.md](language.md) describes
current support, and [roadmap.md](roadmap.md) records proposed work. Follow the
current human task; a roadmap entry alone does not authorize implementation.

## Pre-1.0 development policy

Silver is one evolving language. Prioritize the current capability, foundational
correctness and development speed. Add infrastructure when it meets a
demonstrated need or avoids a costly architectural mistake. Record independently
addable hardening as deferred. Review suggestions are inputs to engineering
judgment, not automatic requirements.

Use Git history instead of maintaining historical language editions. Keep
existing samples working by default; deliberate changes to syntax or behavior
must update the specification, catalogue, implementation, proofs and affected
examples together. The current language must retain its complete assurance
guarantee. Do not silently remove cases or suppress obligations to make a
failing proof pass.

Intermediate builds and experiments need no proof gate. Before describing a
capability as supported, validate its current implementation and assurance.
Binary attestations, comprehensive per-program dependency manifests and
additional adversarial workspace defenses are deferred until distribution or
stronger reproducibility claims require them. Existing safeguards remain.

## Admit one coherent capability

Prefer a small capability motivated by a sample. Closely coupled syntax may
arrive together. Do not add extra operations solely to create intermediate
examples, or turn every anticipated infrastructure component into a project.

For each authorized increment:

1. Specify syntax, behavior, bounds and permitted compositions. For libraries,
   include operation identity, elaboration, effects, failure behavior and trusted
   assumptions. Use a focused experiment to discover actual obligation classes
   before choosing new proof/report infrastructure.
2. Implement and verify affected Silver-owned code in SPARK. Extend membership,
   composition, correspondence and automatic-discharge arguments over the entire
   resulting language. Preserve the author's source through proof and build and
   maintain correspondence with the selected library specifications and bodies.
3. Audit all required obligations and coverage. The application-unit report
   remains empty for the four current productions; output additionally requires
   the complete nonempty library reports. Extend report handling when new
   obligation classes or selected units require it. Keep [assurance claims](docs/assurance.md) and
   [trusted assumptions](docs/trusted-boundary.md) accurate.
4. Update the specification, catalogue and motivating sample together. Exercise
   boundaries, nearby rejected forms and interactions with existing constructs.
   Shared typed rules are useful when expansion makes duplicate metadata costly;
   a general catalogue framework is not a prerequisite now.
5. Run full validation, record actual evidence and mark the capability supported.
   Samples exercise the rules; universal proofs establish their guarantee.

The fixed Ada/SPARK editions define inherited meaning. Changes to the Oracle
need explicit human approval; routine authorized implementation does not need
repeated approval. Source-pin updates in `ReviewedSourceShape.lean` and
`ReviewedOutputShape.lean` receive
ordinary semantic review with the source diff: examine declarations, bindings,
operators and the modeled equations. Regenerating a matching pin alone does not
establish correspondence.

## Proof loop and validation

Run from the repository root. Use `scripts/bootstrap.py` and
`scripts/bootstrap_lean.py` when tools need installation. Moving the installation
requires bootstrap and rebuild. Everyday commands are:

```sh
python3 scripts/dev.py prove
python3 scripts/dev.py build
python3 scripts/dev.py test
python3 scripts/check_lean.py
```

GNATprove uses incremental analysis and its native local filesystem result cache.
The default worker count is all detected cores (`--jobs 0`); use `--jobs N` when
memory or concurrent work calls for a limit. Incremental runs preserve sessions
and reports but invalidate the previous completed full-audit manifest. They
provide development feedback, not a new full assurance record.

Lean retains Lake artifacts and rebuilds changed dependencies. Changing an embedded
recognizer or selected runtime Ada file invalidates the whole Silver Lean library.
Its module/axiom audit executes on
every invocation, including cache hits. Lake schedules independent modules;
`--threads N` controls declaration threads within each Lean process. The default
remains one because generated
certificates have high peak memory use. This is a conservative starting point,
not a measured optimum. The ten source-certificate modules are independent
so Lake can check them concurrently; each module remains serial at this setting. Measure time and memory when tuning it, and avoid multiplying all-core
thread pools across concurrent modules.

At capability-validation checkpoints:

```sh
python3 scripts/dev.py prove --full
python3 scripts/dev.py build
python3 scripts/dev.py test
python3 scripts/check_lean.py --full
```

Full GNATprove validation forces unit analysis, regenerates reports and audits
complete coverage and provenance; native sessions and solver-cache results may
be reused. It establishes a complete audit, not an uncached runtime bound.
Optional `dev.py prove --cold` implies full validation and allocates a unique
fresh output/session/cache workspace. It prints the separate evidence path and
preserves the normal warm state and every other host's artifacts. Cold mode
rejects custom `--subdirs`. Use it for a fresh-proof measurement, toolchain
investigation or suspected cache problem, not as a mandatory capability gate.

Full Lean validation adds the independent fresh kernel recheck.
`check_lean.py --clean` also discards the current host's proof workspace. Clean
runs serve toolchain changes, cache investigations and CI; they are not the
everyday editing loop. Both workflows keep the same logical requirements.
Cached evidence must apply
to the current inputs and configuration.

For exploratory GNATprove options, use a separate output directory:

```sh
python3 scripts/dev.py tool -- gnatprove -P ../../../silver.gpr \
  --subdirs=explore/trial --timeout=60 \
  -XSILVER_HOST="$(python3 scripts/dev.py paths --field host)"
```

Direct `gnatprove` calls through `dev.py tool` require `--subdirs=explore` or a
directory below it; help and version queries are exempt. An optional filesystem
solver cache must be outside the managed `.silver/<host>/proof-cache/` tree and
the cold workspaces' `cache/` directories. This guard prevents ordinary command
mistakes; it is not an adversarial boundary for arbitrary commands or wrappers.
Exploratory runs do not produce the audited success manifest.

GNATprove failures remain failures; no automatic retry is performed. The
recorded `DOC_END` diagnostic identifies an unexpected end of JSON input. A
parallel-write race has not been established. `--jobs 1` is a diagnostic
comparison, not a verified workaround; the default remains all cores. Preserve
a recurrence's logs and inputs before another run replaces them. See
[the workflow record](docs/proof-workflow.md) and
[Hello World evidence](docs/hello-world.md) for observed failures and subsequent
validation. Cold success does not establish that the warm-state defect is fixed.

Use the symlinked-TMPDIR regression to exercise path portability on Linux.
For Markdown-only changes, check links, current-language consistency and
`git diff --check`; rerun proofs only when affected inputs or claims warrant it.
Record incremental, full, clean and reused results accurately. Keep timings and
counts in [the workflow record](docs/proof-workflow.md), not acceptance thresholds.

## Samples, platforms and handoffs

[samples/null.adb](samples/null.adb) preserves the original source bytes. The
[sample manifest](samples/manifest.json) links supported samples to capabilities,
specification references and expected output/exit status. Proposed examples stay
in the roadmap; rejected fixtures stay in tests. The manifest-driven test admits,
proves, builds and executes every supported sample, comparing application output
separately from compiler diagnostics.

Linux is primary; native macOS validation is independent and nonblocking.
Distinguish native evidence, mocked routing and configured-but-unrun CI.
Use `scripts/dev.py paths` and preserve native host isolation under `.tools/`
and `.silver/`. See [platform coexistence](docs/platform-coexistence.md).

[AGENTS.md](AGENTS.md) supplies session guidance and
[docs/session-memory.md](docs/session-memory.md) records dated decisions and
handoffs. Use subthreads with explicit ownership for separable work. Keep
temporary experiments separate and preserve unrelated scratch files.

Runtime source edits require refreshing bootstrap, rebuilding Silver and
rechecking compiler and Lean evidence together. Bootstrap embeds exact selected
library bytes; a stale compiler rejects changed installed runtime files. This
source binding is part of correspondence, not deferred binary attestation.
