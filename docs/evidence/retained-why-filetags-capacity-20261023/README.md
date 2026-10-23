# FileTags capacity evidence

2026-10-23 UTC, Linux x86_64; #119 / #153, R71. Author base:
`2b9e9f780f9e747d0610663ead3f1e90a4a60c08`. The
[source argument](../../research/retained-why-filetags-capacity.md) closes
the private FileTags counter, size, bucket-cell and backing representation
guards under the inherited sufficient-physical-resource premise. Independent
review is pending at this author freeze.

The focused check passed **1,059,547 assertions in 2.788705 seconds**. Most are
repeated small-model chain assertions, not independent proof obligations.
It pins 29 provider files, 17 complete source members and 29 strict ranges;
censuses 556 source files; joins four later libraries to all five initial input
families; and checks 14,132 mutating-store prefixes in 1,032 small configurations.
It runs no target, native capture, predecessor checker, compiler, solver or
proof tool, and invokes no disassembler/source fetch.

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-why-filetags-capacity-20261023/check.py
```

Exports in `projection.json`, identically bounded for all five clients:

* Exact initial count N0 is unknown, with N0<=945214; initial backing B0 is
  unknown, with B0<=524288.
* At most945216 suffix add-handler entries; counter, scalar size and physical
  bucket cells per table at most1890430; backing/tail extent at most2097152.
* Lookup-chain and actual counter/index/threshold/array guards pass. Summed
  root occurrences remain separate from physical cells.
* Explicit suffix bucket/array requests for both tables total at most20144648
  words. This excludes closure/caller/GC/native-service allocations and is
  not a complete routine allocation or physical-RAM bound.

The positive theorem explicitly inherits sufficient physical memory/stack and
faithful valid runtime services. Ordinary physical failures are not counted as
escaping-save events; arbitrary resumed resource failures inside published
mutations are outside this result. One process-wide e<=2, two save-entering
callbacks and three saves remain unchanged. Existing filename180/warning436
exports remain unchanged. No whole-process capacity or admission conclusion
is made.

`inputs.json` pins accepted source/native evidence and predecessor results;
their programs are not replayed. `source-ranges.json` and
`source-witnesses.md` retain complete member and strict excerpt identities.
`census-baseline.json` freezes the full call/private/alias census;
`call-census.json` is its independently reconstructed output.
`library-domain-join.json` attaches exact later paths to completed initial
parsing. `projection.json` contains all arithmetic exports.
`small-prefix-check.json` records exhaustive refined-hash/duplicate choices
for abstract initial capacities1 and2 at their growth threshold, every
mutating-store prefix, and ascending/descending repair orders. It contains a
three-cell/five-occurrence witness and exercises both shared-tail/no-second-
resize and empty-array/safe-second-resize cases. These finite examples
corroborate the general source proof; they do not establish it by sampling.
`check-attempt-1.log` and `result.json` retain the single focused run.
`prepare.py` documents author pin preparation; it is not part of validation
and must not be used to erase a pin mismatch during review.

Two preparation attempts failed strict source-range assertions before any
manifest/checker output: Loc's requested end366 exceeded its actual end360;
Sexp_parser's requested end25 exceeded its actual end24. Complete source
inspection corrected the explicit ranges to343–360 and12–24. No clipping was
introduced. A set_file range13–30 was also attached. `attempts.json` records
those preparation failures and the successful new focused check.

Selected author: GPT-6 Astra / Extra High. Runtime confirmation and token/cost
telemetry are unavailable. Preparation started20:08:00 UTC; the passing check
and source draft were complete before20:28:51 UTC. This wall-clock interval
includes context handoff; it is not a causal model-efficiency measurement.
The initial zero-suffix-insert idea was rejected because a save-origin
Not_found may be a false miss; the completed proof bounds D0 recovery instead.
Parent clarification attached the existing resource premise explicitly, with
ordinary failures kept separate from e. Independent review settings, exact
freeze and acceptance belong in the review report.
No GitHub/shared-record, harness-state or CLI-memory write was made.
