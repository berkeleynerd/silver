# Retained callback registration and exceptional signal continuation

Research #119, Linux x86_64, 2026-10-18. The
[source argument](../../research/retained-why-inline-callback-closure.md) leaves
the complete continuing-call endpoint **open**. The signal handler can create
identifiers; if a relevant exception then escapes into a continuing transform
catch, that work needs accounting. No actual post-registration escape route is
established. Review R1 refuted the original stable missing-task witness: the
existing detachment guard catches that missing lookup and skips the node.
The corrected packet retains the guard and its scoped local mutation inventory.
The accepted accounted endpoint remains **60,496 + 1,145 = 61,641**.

```sh
python3 -B docs/evidence/retained-why-inline-callback-closure-20261018/check.py
```

The default check verifies frozen identities, source/native witnesses, predecessor
binding and scoped result flags. To independently regenerate the numeric ELF
reference extraction using the pinned installed files and objdump:

```sh
python3 -B docs/evidence/retained-why-inline-callback-closure-20261018/check.py --regenerate
```

Neither command starts the target, debugger, compiler or solver. Regeneration
runs objdump only. Paths can be supplied with `--install` and `--objdump`.

- `sources.tar.gz`: 43 exact selected Why3/OCaml files and source index.
- `native.tar.gz`: numeric references, plugin imports, storage classifications,
  custom allocator call-site contexts and reference-owner/witness disassembly.
- `binding.json`: unchanged predecessor capture/plan member identities and
  mapped executable/plugin identities; no new runtime observations.
- `inputs.json`: archive/member hashes and reused predecessor file identities.
- `audit.py`: ELF extraction, explicitly not a native non-aliasing theorem.
- `check.py`: focused offline validation, including the guard/lookup inventory,
  BSS rejection and operand decoding regressions; no prior expensive graph
  replay is repeated.
- `result.json`: unchanged accounted arithmetic and explicitly false complete
  capacity/reentrancy claims, with the remaining exception-exclusion or
  bounded-charge obligation.
- `round.json`: selected settings, actual available timing, rework and review
  handoff. Runtime model confirmation and token/cost measurements are unavailable.

The live finalizer registry remains unobserved. The registered-capability and
custom-hook findings are source/interface arguments with native witnesses;
negative reference scans and last-textual-register definitions are not a
machine-checked arbitrary native control-flow proof.
