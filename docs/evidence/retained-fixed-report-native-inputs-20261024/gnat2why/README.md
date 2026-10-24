# GNAT2Why's native report configuration owners

2026-10-24, #212 under #119. This continues the reviewed R87
[parent/reporter provider](../README.md). The producer is a separate ELF and
cannot inherit another executable's constants merely from similar source.
This packet independently attaches its three selected configuration fields.

The exact installed GNAT2Why ELF in [inputs.json](inputs.json) contains
`__gnat_max_path_len = 4096`. Its version function has the same reviewed
straight-line instruction shape, with its own secondary-stack allocator call
resolved: bounds 1..10, text `FSF 16.1.0`, a 20-byte return allocation at
alignment four. The padded static symbol is not the returned String length.

The producer's mmap page-size wrapper resolves through its own PLT/GOT
relocation to `getpagesize`. Its code has the reviewed reporter wrapper shape.
The retained host service observation is 4096; reuse depends on the same
host/runtime and stable ordinary service premise already stated by R87.
This is not a claim that every platform has that page size, nor a new service
query. The original native inspection and source bindings remain unchanged.

The accepted response-parser interface requires `max_path >= 1` and
`page_size >= 1`; its path scratch, normalization and mapping inequalities use
these separate operands. This packet supplies their selected producer values.
The producer and report reader still need actual common paths, complete input
sizes and their remaining source/storage joins. It does not establish a
complete parser, producer, fixed-report or #119 capacity result.

`check.py` reads the exact ELF, maps symbol addresses through file-backed
PT_LOAD segments, resolves relative calls and the imported page service, and
checks the retained configuration/provider identities. It imports only the
existing pure ELF reader; no author/predecessor checker, target binary,
compiler, prover, Lean or service is executed. Exploratory symbol extraction
preceded the final check; its output identified the three owners without a
service query. The final measured result is in [result.json](result.json).

The lead authored this bounded provider. Live lead model/effort and token/cost
telemetry are unavailable. Independent review is required before acceptance;
its setting and actual measured work will be reported separately. Oracle,
tools/pins, admission, physical-resource premises and the single global
e<=2/two-callback/three-save allowance are unchanged. Production #88–#94
remains unstarted and draft PR #121 remains unmerged.
