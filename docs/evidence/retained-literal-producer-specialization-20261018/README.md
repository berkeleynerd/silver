# Literal Main producer specialization

Offline #119 evidence, 2026-10-18. The
[source argument](../../research/retained-literal-producer-specialization.md)
joins complete literal-source recognition and zero registered Main checks to
the absence of Main JSON serialization. It retains every general producer-core
condition except the hypothetical per-file JSON-byte bound. Five fixed-library
Why3 inputs and all other pipeline obligations remain separate.

Run from any directory:

```sh
python3 docs/evidence/retained-literal-producer-specialization-20261018/check.py \
  --output /tmp/literal-producer-specialization.json
```

`compose.py` exposes `Context()` and `evaluate(source_bytes, context, path_bytes)`.
The result includes the complete general core, its unchanged source counts,
named retained conditions, the hypothetical general JSON estimate and the
source-derived zero actual Main emission. Construct Context once and reuse its
validated inputs across evaluations. Input hashes cover the reused formulas,
source argument, relevant current Silver files and external-source identities.
The original source archive and the general component's own evidence hashes
are checked transitively.

The retained `result.json` distinguishes core arithmetic from whole-pipeline
capacity. No native tool executes. This packet changes no production admission.
