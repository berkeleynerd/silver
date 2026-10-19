# Complete selected native composition

See the [source argument](../../research/retained-literal-native-completion.md).
The new aggregate is pending independent review. This is a research capacity
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
documentation patch context mismatch ran no native tool.

Selected source/review worker setting: GPT-6 Astra / Extra High. Live lead
model/effort, runtime confirmation of worker settings and token/monetary cost
are unavailable. Timings above measure offline checks, not total team cost.

Example from the repository root (use owned TMPDIR if host `/tmp` is full):

```sh
python3 docs/evidence/retained-literal-native-completion-20261019/compose.py \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --plugin-include /path/to/toolchain/lib/gcc/x86_64-pc-linux-gnu/16.1.0/plugin/include \
  --gas-root /tmp/silver-backend-compose-20261018/gas-source \
  --output /path/to/owned/result.json
```
