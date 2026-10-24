# Contract-builder local representation safety

Continuation of #202 / #119 after author repair
`93fdabb2232e0fc7fe2fd7c39f167c1985991f5a`, accepted by independent review
`ed10f9ba6201024b5053a84b6595bc770b2bcfeb`. All earlier packets are unchanged.
See the appended [source argument](../../../research/retained-main-construction-demand.md).

For the accepted flat `create_cty`, saturated closed snapshot application and
ordinary Unit partition, this packet closes the **new local representation
obligation**: finite structural traversal, fixed-size records/closures/list
cells and representable local request headers. It preserves the accepted
request vector, candidate records and shared owner histories. It does not
introduce another cumulative byte coefficient or an aggregate RAM/stack gate.

The retained Linux ELF agrees with **332 native bodies / 38,376 instruction
bytes**: 212 local helpers and closure bodies, plus 120 fixed-arity application
adapter bodies. Twenty-four constant closure objects have their headers,
extents and code pointers reconciled to the ELF. Every local heap reservation
site is constant; the largest reserves **104 bytes**, including its headers.
This bounds any individual block in such a reservation by 12 payload words.
Several retained bodies contain excluded branches; `source-closure.json` and
`native-boundary.json` give their source disposition. Direct native symbol
references alone are not claimed to be a complete indirect call graph.

The new finite input-shape witness retains empty trigger-group spines, saved
images and context-case patterns. It is mathematical input structure, not an
assertion that a failed call traversed every input. Actual construction and
failed-prefix requests still come from the accepted fold. A diagram outside
the source arity/domain guards cannot export an unconditional local closure.

**Cumulative local frame/closure byte pricing is intentionally uncomputed
and is not a remaining representation obligation.** Fixed per-request sizes
and finite descent suffice under the existing physical resource premise.
The historical `complete_native_bytes=false` field is preserved inside the
accepted request vector; the new export records this disposition explicitly.
The genuinely required remaining joins are shared hashcons owner endpoints,
backing request sizes and callbacks; Wvs/strong memo services; unresolved
source entry multiplicities; remaining builder families and later construction.

Files:

- `local.py`: additive input-shape/guard wrapper over the frozen builder.
- `source-closure.json`, `arity-frontier.json`: source branches, descent and
  actual nullary/binary type frontier; no arbitrary Why grammar extension.
- `source-witnesses.json`, `inputs.json`: exact excerpts and complete identities.
- `native-bodies.json`, `native-witnesses.json`, `native-census.json`,
  `native-boundary.json`: retained code/data correspondence and source cuts.
- `freeze.py`: read-only extraction from the existing disassembly and ELF.
- `check.py`, `exports.json`, `result.json`, `fixture-check.json`: focused checks
  and seven diagrams, including failures and unsupported-domain controls.
- `round.json`, `checkpoint.md`: settings, timing, decisions and handoff.

One focused check passed **1,466 assertions in 1.793509 seconds**, Linux
x86_64. A later fixture-only check passed 16 assertions in 0.015193 seconds
after replacing a hypothetical function-typed literal image by a nullary
logical application; all exports remained byte-identical. Successful native
identity checks were reused for that change. No native target, compiler,
prover, Lean, disassembler or predecessor checker was run.

```sh
python3 docs/evidence/retained-main-construction-demand-20261024/builder-locals/check.py
```

The installed-source/native relation remains a trusted correspondence premise;
the byte reconciliation is not a machine-checked compiler refinement proof.
Oracle/admission/tool pins, one global `e <= 2`, two save-entering callbacks
and three saves are unchanged. Independent review is pending; #202/#119 stay
open and production #88–#94 is untouched.
