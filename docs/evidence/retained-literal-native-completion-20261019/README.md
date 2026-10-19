# Complete selected native composition

See the [source argument](../../research/retained-literal-native-completion.md).
The [independent review](../../reviews/review-literal-native-completion-20261019.md)
accepts freeze `4f29a3bf85` with no material findings. This is a research capacity
rule; production implementation/correspondence and the remaining #119 proof
pipeline/current-grammar work are not complete.

- `compose.py`: fresh actual-source register408 plus parent, driver, Ada,
  binder, common compiler shells, binder compiler and assembler joins.
- `shells.py`: common gnat1 shell and checksum-family compiler transfers.
- `inputs.json`:94 frozen component inputs; each component also validates its
  transitive source/configuration evidence. The common shells freshly validate
  266 distinct complete source/configuration files.
- `result.json`: default actual Hello source,475 true conditions, all12 native
  stages closed, no native residual. Offline evaluation9.298653225 seconds.
- `check.py` and `check-results.json`:3301 focused checks in13.624896653 seconds.
  Every one of408 predicates in each of both maps is separately set false and
  unknown:1632 failure cases, none promoted to success. Additional source,
  graph, argv/environment and path-unit mutations are rejected. Fresh mixed,
  8192-byte literal and5000-call sources exercise the public source API;
  checksum extremes and the first-collection guard are tested separately.

The default result is reused only as an explicit fault-test baseline, not as
the capacity result for another source. No native compiler, binder, assembler,
linker, capture, prover, Lean build, full suite or predecessor suite ran for
this aggregate. Existing accepted native observations remain retained in their
original packets. The earlier binder-assembler increment's four compiler and
four assembler calls have their own managed record and are not hidden here.

First integration caught a units mismatch: the predecessor has512 pathname
characters/513 bytes with NUL; child packets check512 bytes including NUL.
The fresh graph comparison now permits exactly that scalar bound change and
requires equality everywhere else. Binder's optional runtime pass-through was
added to preserve the actual selected directory graph. No underlying capacity
condition was weakened. The initial unsuccessful aggregate attempt and a
subsequent passing evaluation ran no native tool.

Independent aggregate review `20de4a4367` (integrated `5e95cf8810`) added92
checks in9.981868322 seconds and inspected source coverage and interface
composition. The separate Ada/binder review `0d974e826d` (integrated
`26411aa1a7`) accepts those components and the runtime pass-through repair;
its1,031 independent assertions took2.042068046 seconds. The aggregate review
explicitly excludes its author's binder component from self-review. Both
reviews retain exact inputs and reuse successful evidence. All475 guards and
12 stages pass for the independent C7/N4 source. No post-freeze implementation
change or new native run was needed.

Selected source/review worker setting: GPT-6 Astra / Extra High. Live lead
model/effort, runtime confirmation of worker settings and token/monetary cost
are unavailable. Timings above measure offline checks, not total team cost.

The [external-review disposition](../../review-a3af180047-disposition.md)
clarifies production adoption, constant stage flags, host premises and remaining
scope. [Preserved reviewer scratch](../review-a3af180047-retention-20261019/README.md)
retains available original scripts/results without rerunning them. Missing
harnesses remain explicitly identified.

The source corpora are GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`
(including its Ada tree) and binutils2.46.1 / `5e56594815`, with exact files
validated transitively by the component manifests. Historical worker `/tmp`
locations are not portable paths. Substitute corpus extraction directories
matching those manifests in this example; no corpus extraction or evaluator
execution is part of the paused maintenance:

```sh
python3 docs/evidence/retained-literal-native-completion-20261019/compose.py \
  --gcc-root /path/to/extracted/gcc-corpus \
  --ada-root /path/to/extracted/ada-corpus \
  --plugin-include /path/to/toolchain/lib/gcc/x86_64-pc-linux-gnu/16.1.0/plugin/include \
  --gas-root /path/to/extracted/binutils-corpus \
  --output /path/to/owned/result.json
```
