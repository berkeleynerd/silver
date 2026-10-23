# Installed Re numerical-owner review

2026-10-23 UTC, #119 / #153. **Accepted within the stated premises.** Exact
author freeze: `882f1349cbb0bfec1f65a836b7ba4fd307d14263`. This closes
R71's intentionally open numerical correspondence for the selected installed
Re owners, including the additional packed Hash_set. It does not change R71's
accepted reference-source theorem or imply whole-process closure.

This review addresses R71's open installed-Re numerical correspondence for
canonical answer parsing. It does not identify an upstream Re version or extend
the accepted matching-semantics, callback or physical-resource premises.

## Findings resolved before the final freeze

**NR1 — packed-key publication can precede the count: epoch proof required.**
The reviewer identified a key store at `9144f1`, pending-action dispatch at
`914500/91451f`, and count increment only at `914507–914510`. Thus historical
count is not always at least physical occupancy at an escaping prefix. Resize
also reinserts without resetting the count. The frozen argument correctly
separates completed-boundary invariants from arbitrary prefixes: an escape ends the
current scratch epoch, and the next duplicate-removal use follows a complete
clear. No local catch resumes the interrupted insertion or rehash.

With `N=10,705,984` compiled expression IDs and the native epsilon ID0,
`M=N+1=10,705,985` bounds distinct keys. Native duplicate removal tests membership
before each outer insertion. At most M outer insertions can each trigger one
resize, whose internal reinserts do not resize. This gives historical count
`M(M+1)` and capacity `4M(M+1)` across clear epochs. These ceilings bound
representation operands under the inherited sufficient-resource premise; they
are not a RAM estimate or admission condition.

The empty-slot obligation is separate from the count ceiling. With no growth,
stable occupancy is at most count and count at most half capacity. Growth
provides twice the old capacity for at most the old occupancy plus one new key.
Consequently internal add's unbounded probe loop reaches an empty slot; the
membership loop independently caps its probes at capacity. Packed key 0 is
allowed, and unboxed sentinel -1 is excluded by the actual ID domain.

**NR2 — native layouts and control flow differ from the reference.**
The installed Str regexp contains two lazy fields, the compiled regexp eleven
fields, the working area three fields, positions two fields, and state info
three fields. The proof uses these actual layouts. The fixed character AST
array is initialized eagerly and read without mutation. Selected compiler
constructors preserve the accepted loose ID accounting; dynamic descriptor
construction introduces no new expression IDs. Static closure/dispatch data
and the epsilon object are retained with the function bodies, so this mapping
does not rest on symbol-name similarity alone.

Native break indices use `-8-(2i+1)=2(-i-5)+1`; the scan decodes with the same
subtraction before writing positions. For `0<=i<402`, this fits the signed
range and remains distinct from the unknown sentinel, tagged -2 (`-3`). The
review checked the sentinel initializer and selected scan/validation path.
Initial/final caches probe twice, but only the second miss path constructs;
those lookup catches end before delta or state addition begins.

**NR3 — positions length can lead its array: private lifetime is essential.**
`resize_1199` changes length at `920882` before allocating at `9208ac` and
publishing the new array at `9208bf`. Reusing a failed prefix would be unsafe
because the setter trusts length before an unchecked store. The selected
Core.exec route passes groups=true and creates a fresh private positions owner
for each match. No catch resumes its failed update. Only a completed match
extracts its array into Group. A stale work-area capacity hint can cause more
private growth but cannot expose the failed owner to the next search.

**NR4 — failed search does not universally clear the shared last-match ref.**
The reviewer found that native Str.search_forward pops its trap at
`92788b–92788f`, before Some Group publication and Group.offset. A later
exception may therefore retain the incoming Group or a newly completed Group.
The current canonical bounds apply only to the newly created Group. An older
startup Group remains its earlier owner's object. The frozen argument connects
later group/replacement use to each caller's own successful search: failed searches take the split/grep abandonment path or
unwind the entry. A newly published Group has all five fields initialized and
contains a completed positions array; failed private growth is never published.

## Evidence and remaining boundary

The [independent packet](../evidence/retained-re-native-correspondence-review-20261023/README.md)
passed **203,313 checks in 8.984194 seconds**, on its first run. It binds all
119 frozen author files and 24 provider files, independently parses the ELF
symbols and file-backed ranges, verifies 109 complete function bodies and eight
static data intervals, and maps all 7,274 retained instruction-byte rows back
to the installed binary. It also reattaches 84 instruction witnesses and checks
the dispatch/closure targets, sentinel distinction and numeric ceilings.

The independent finite support model checked 821 scalar clear-epoch
configurations, 53,471 reinsertion/key-publication prefixes and 5,461
linear-probe slot cases. It explicitly exhibits count-lag prefixes; it does
not assume the rejected all-prefix occupancy invariant. These checks support
the reviewed general arithmetic/ownership argument. They are not a universal
OCaml proof or an execution of the regex engine. R71's successful source and
fixed-input evidence is reused by exact identity, without replay.

The instantiated added-owner ceilings are:

| Packed scratch quantity | Bound |
| --- | ---: |
| Key domain | 10,705,985 |
| Historical count | 114,618,125,526,210 |
| Capacity | 458,472,502,104,840 slots |
| One backing payload | 3,667,780,016,838,720 bytes |

The backing ceiling is below the native OCaml string limit; tagged count,
slot-sum, doubling and byte-offset intermediates also fit. Existing bounds
remain 402/86 state-add attempts, 256/128 state-table buckets, 512 working bits,
2048 positions words, 257 transition words and eight marks words. These are
representation ceilings, not aggregate physical-resource requirements.

Reviewer base is accepted R71
`423aaf3aec178d96f32847c8bf9af314143c7c50`, on Linux x86_64. Selected reviewer
setting is GPT-6 Astra / Extra High; runtime model/effort confirmation and token
or cost telemetry are unavailable. No additional agents were used. Author
extraction records one failed absent-symbol batch followed by recovery of five successful files without
repeated disassembly; their individual elapsed times remain unavailable.
The final author checker and independent audit each passed once. No successful
validation was repeated. Exact files, providers, audit code, attempt log and
round timing are retained for an identity-only integration join.

The inherited one global e<=2, two save-entering callbacks and three saves are
unchanged. The review does not execute the target, compiler, solver, Re engine,
disassembler, capture or predecessor checker. Canonical publication/private
file lifetime, actual directory/path guards, raw backend output, startup and
whole-#119/#153 assurance remain outside this narrow task. No Oracle,
implementation source, source-shape pin, toolchain, admission or production behavior is changed.

The native differences and pre-freeze refinements above complete a relation
that R71 expressly left open. They are not new defects in its reference-source
acceptance. There is **no remaining finding requiring a new issue** within this
narrow review; the already recorded broader boundaries stay with the lead.
