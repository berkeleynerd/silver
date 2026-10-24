# C→T parser and converter consumer representation

This #202/#119 author packet closes the actual pre-typing Yojson, Number/BigInt,
and private Format/Printf/Buffer representation operands under the accepted
source/producer/runtime/physical premises. It follows auxiliary author
`ae53fcef513b322bdc67f91aee998d1a8c356a22`, independently accepted without findings
by `bee34a8db1a84991cbf7491343223c5d71735afd` (integrated locally as `d3f8e84cc8`).
Earlier packets are immutable. The detailed source argument is appended to
[the research note](../../../research/retained-main-construction-demand.md#source-derived-prefix-consumer-representation).

- B remains the producer body bound 2^31−2. Yojson reads N=B+1 bytes, including
  Outputs.Close's LF. Fresh lexbuf backing≤max(1024,2N), string buffer
  backing≤max(256,2N), and each parser error string≤N+256.
- Complete fixed numeric origins plus Main's no-Ureal induction supply ten
  Ureal tuples: bases 2/16, numerator<2^64, |denominator|≤4080. The converter
  stores exponents; it calls no radix power/shift before T. Normalization's
  trial-divisor squares, failed trials and signed corrections are included.
  Every arithmetic operand≤3 limbs; custom request≤6 limbs/72 total bytes.
  d=40 bounds decimal parsing only. The later five-atom contract is unused.
- Each selected Format/Printf operation owns a fresh private buffer. Its
  result length≤L=max(64B+128,N+256), backing≤max(512,2L), and its queue/counter,
  flush-sentinel and header arithmetic fit. At the producer maximum L=2^37.
  Registered outer failure reporting and post-T printers retain their separate
  interfaces; they are not called by pre-T exception construction.

`consumers.producer_envelope(role)` exports the conditional producer maximum.
`consumers.from_serialized_json(role, data)` sizes actual producer bytes with
one final LF. Neither entrypoint validates schema or source origin, and neither
accepts a caller-provided count/exponent vector. The source relation is explicit
in every result. The five role/configuration guards remain exact.

The already-pinned binary contains the Yojson3.0.0 build path. The packet retains
that byte window and the official source archive with retrieval hashes. These
corroborate source-family selection; the existing external behavior relation
supplies source/native correspondence. No new attestation requirement or tool
pin is introduced. GMP's faithful bounded-operand numeric/allocation contract
likewise remains an inherited primitive premise, not a newly proved library.

`prepare.py` freezes exact provider/source identities, the new numeric-origin
projection and all 96 old packet file hashes. `source-witnesses.json` contains
24 complete source identities and 72 exact excerpts. `check.py` checks those
joins, body/file arithmetic, all five guards,28 exact normalization controls,
and scalar formatter queue/flush controls. It does not execute a predecessor
checker, compiler, generated lexer, parser binary, prover, Lean, service,
capture or disassembler.

```sh
python3 docs/evidence/retained-main-construction-demand-20261024/prefix-consumers/check.py
```

The final focused check passed **944 assertions in 1.697476720 seconds** on
Linux x86-64. The prior successful draft passed 899 in 1.615757796 seconds;
`check-before-formatter-controls.py` and `result-before-formatter-controls.json`
preserve that history. The final recheck replaced a vacuous formatter boundary
control with an actual scalar queue/flush simulation and tightened the Safe
preprocessor check. An earlier source extraction stopped on an overlong excerpt
endpoint before writing a packet; the four invalid endpoints were inspected
and corrected. A broad archive-name inspection also stopped on a nonarchive
filename before any evidence change. These are preparation errors, not hidden
proof/native failures. See `round.json`.

The joined **C→T representation interface** is closed under its stated
premises. T→builder import/clone/typing/proxy/candidate transport and whole-pipeline
capacity remain false. No cumulative physical allocation or aggregate stack/RAM
gate is claimed. The exact R78 configuration and one global e≤2/two save-entering
callbacks/three saves remain unchanged. Independent review is pending. Root
owns integration/publication and issue/session-memory updates.
