# Independent review of literal GAS/BFD storage

2026-10-18, [#119](https://github.com/berkeleynerd/silver/issues/119).
Target: `f84c97a973e4666315e08f5c3ceba41043a7c35c`, reviewed in checkout
`e136c527908f56146e45de00a80e62435c2c8138` (the later commit adds only the
separate Why3 review). Selected reviewer: GPT-6 Astra, Extra High; runtime
model/effort confirmation is unavailable. Measured review interval:
18:12:53–18:15:27 UTC (154 seconds), excluding report authoring and commit.
Token use and cost are unavailable.

**Accepted within the selected storage-interface scope; no material finding.**
The [storage argument](../../research/retained-literal-assembler-storage.md)
extends the accepted literal stream/object interface without borrowing the
null stream's fixed symbol-array or string-hash capacities. Its closure remains
conditional on that interface, the five-argument `AS --64 -o OBJECT ASSEMBLY`
shape, actual path bound P, LP64 and selected configuration/source behavior.
This does not establish a production invocation or whole-pipeline capacity.

Review inputs were the new document, `storage.py`, `check-storage.py`,
`storage-inputs.json` and `storage-result.json`, plus their pinned interface,
null allocation/backing/hash/startup/invocation and ELF/string-table dependencies.
The earlier 264-occurrence inventory was reused as a completeness cross-check;
this review inspected the changed dispatch and storage joins against the
retained Binutils sources rather than treating that lexical count as a proof.

- `.ascii` uses `stringer`/`stringer_append_char` to append decoded bytes
  directly; its `.debug`/listing and malformed-input routes are unselected.
  `.base64` uses its fixed four-element group and bytewise appends. The reviewed
  producer bounds each generated directive to 255 decoded bytes, so the new
  `num_octets` accumulation is bounded. The selected `.rodata` alignment hook
  introduces no additional storage. Bounds-record `.long` values stay within
  the existing ordinary integer parser path.
- RIP-relative LEA and direct calls retain the accepted fixed encodings and
  simple-symbol fixups. `@PLT` adds the bounded `lex_got` temporary without a
  GOT symbol or complex-expression wrapper. Instruction scratch uses the
  64-byte instruction bound; the larger literal-data line bound is not needed
  for those copies. The other instruction/parser and synthetic-CFI exclusions
  remain applicable.
- Pool alignments depend only on their section's fixed prefix. Text is fixed
  before the frame estimators consume its label differences; the CFI estimator
  and relaxer therefore agree. The new data does not create a reverse
  dependency, oscillating LEB128, branch-relaxation or additional sweep
  allocation. `F<=UINT_MAX` also entails that the unsigned-long
  `frag_count*frag_count` safety product fits on the selected LP64 host.
- GAS's symbol hash stores symbol objects directly. Conversion/replacement
  preserves the key, and the allocation ceiling S bounds occupied keys.
  `htab_find_slot_with_hash` can grow before a duplicate lookup; the proposed
  least prime above `max(1024,2S)` covers that behavior. The source's
  `index += hash2` has upper intermediate `2p-3`, supporting the separate
  probe condition. Fixed string-table tuples and notes-backed startup hashes
  retain their existing bounds.
- The extra chain fits the initial frchain chunk. `output_file_close` collects
  fourteen fragment-obstack pointers plus its terminator and finishes that
  object before BFD close. Thus the notes prefix is at most 120 bytes.
  `_obstack_newchunk` adds at most `120+15+15+100=250` beyond Q; the variable
  symbol/relocation arrays and path copies are completed bulk objects, not
  prefixes carried into another growth. The revised allowance correctly
  replaces the earlier 112/241 constants.
- Main-arena request sites and their allocator domains reconcile to
  `P+136S+24R+13792`. The reordered symbol pointers use `8(S+8)`; relocation
  buffers total `24R` across sections. The 40Y/24Y serialization arrays use
  ordinary `bfd_malloc`, while section/string hashes use separate arenas.
  Fourteen section metadata requests and the section hash's 13/31 capacities
  are conservative. The per-request `q+23` condition and cumulative raw
  `alloc_size` condition protect different representations.
- The separate ELF string hashes start at 4051. Source growth advances through
  4093 before 8191, at distinct-entry thresholds 3039 and 3070. Their pointer
  arrays independently grow from 64 slots and include the reserved zero slot;
  sorting storage is separate again. Existing names are retained with
  `copy=false`; reference, length, offset and lifecycle conditions remain
  explicit. No main-BFD allocation counter is imposed on these independent
  arenas, and no aggregate RAM gate is introduced.

Independent offline validation ran `check-storage.py` with output directed to
`/tmp/silver-literal-assembler-storage-review-20261018.json`. All nine cases
passed; the result was byte-identical to retained `storage-result.json`.
The replay verified thirteen added input identities and 33 supplementary source
files alongside the base context's 90-file capsule. This includes the corrected
4051/4093/8191 test expectations and the separate pointer-array boundary.
The target evidence is Linux x86_64. No native compiler, assembler, linker,
debugger, prover or broad suite was run by this review.

The result closes the documented selected GAS-owned dynamic-request coverage
and output-BFD storage composition under its premises. Host allocation success,
pointer placement, stack and library contracts remain explicit. Actual
production argv/path materialization, other compiler/producer/binder objects
and phases, and final-link displacement reach remain outside this acceptance.
