# Explicit no-LTO link descriptor

2026-10-18, Linux x86_64, Refs #119. Supports the
[selected link transfer](../../research/retained-link-inputs.md).

The proposed link descriptor adds `-fno-lto -fno-use-linker-plugin`. It uses
the existing toolchain and retained null-program objects. Production flags
remain unchanged. `run.py` and `check-ld.py` are the exact executed scripts;
their absolute inputs identify the retained session. Do not rerun them in
this evidence directory. Native outputs remain at their recorded scratch
paths, with hashes in the records.

Managed run `20261018T081727-b7ffb03aced1` made one driver-only query
(0.003206 seconds) and one actual link (0.044033 seconds). GCC verbosity did
not expose the child linker, so the recorded diagnostic follow-up
`20261018T081848-3f280e1bb163` repeated only that retained-object link with
collect2 verbosity (0.036707 seconds). It selected the expected toolchain
linker, SHA256 `5fedbb6086b0234eb990800507c0670cb572b48ad864a4d8e8f961ddddef09a0`.
No frontend, assembler, prover or resulting program ran. The raw stdout,
stderr, commands, environment and managed records are retained under a
content manifest.

Replay the comparisons without running native tools:

```sh
python3 docs/evidence/retained-link-no-lto-20261018/check.py \
  --output /tmp/link-no-lto-check.json
```

`--installed` additionally hashes the retained input objects and both linker
paths. The checker compares exact target arguments after removing the old
plugin fields and normalizing only the output filename; fixed inputs and
their order are unchanged. It reuses the earlier complete source archives,
library inventory and GCC-display decoder. The manual source argument
establishes reachability; the checker does not prove vendor code correct.

This avoids the unused plugin path and collector LTO worker, with 45 collect2
positions, 44 linker positions and separately bounded argument arrays. The
whole linker/generated-object/layout argument remains incomplete. No broad
assurance run or production language change belongs to this experiment.
