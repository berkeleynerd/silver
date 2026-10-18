# Independent review of the literal assembly and object interface

2026-10-18, [#119](https://github.com/berkeleynerd/silver/issues/119).
Target: `5794440714eb6c20a4afc3e1484e6ca8ea2534f5`.
Selected reviewer: GPT-6 Astra, Extra High; runtime model/effort confirmation
is unavailable. Measured review interval: 18:04:37–18:06:38 UTC (121 seconds),
excluding report authoring and commit. Token use and cost are unavailable.

**Accepted within the stated interface scope; no material finding.** The
[source argument](../../research/retained-literal-assembler.md) composes the
source-derived call, null-statement and decoded-byte counts with the reviewed
final-RTL and constant-emission interfaces. It supplies the claimed assembly
stream, selected encodings, fragment events, region condition, symbol/fixup/
relocation counts and ELF file envelope. Its effective-option, target/ABI and
source-correspondence premises remain necessary. Passing the local checks
does not establish whole-assembler or whole-pipeline capacity.

Review inputs were the target document and packet's `compose.py`, `check.py`,
`inputs.json` and `result.json`; relevant final-RTL, constant-emission, null
GAS/ELF and generic string-table arguments were read as dependencies. New GAS
dispatch and representation checks used the authoritative retained Binutils
capsule at commit `5e56594815854de5eca35c7c04b11705d0f19c02`. The existing
reviewed compiler transfer was reused; the GCC ASCII/base64 writer was also
inspected in the supplied source tree.

- The complete source recognizer supplies C, N and W; the evaluator additionally
  excludes vertical-tab/form-feed source bytes. Fixed null outline output plus
  one line per final-chain object and the separate constant-data allowance
  covers the new stream without assuming every chain object prints. The
  selected instruction templates and small CFI rules fit the per-line charge.
  Quotes, backslashes and directive-like literal contents remain data.
- `PLT` has `need_GOT_symbol=false` in `tc-i386.c:1400–1402`.
  `lex_got` removes the suffix before ordinary displacement-expression parsing
  (`:13381–13451,15046–15066`). The selected expression stays a named symbol;
  neither GOT-symbol creation nor a general expression wrapper is introduced.
  The temporary copied operand fits the stated line-derived request bound.
- Opcode selection and emission support seven-byte RIP-relative LEAs,
  three-byte DI register moves and five-byte direct calls. `JumpDword` selects
  `output_jump`, rather than branch relaxation. The selected zero branch
  alignment excludes forced instruction-fragment splitting. Each LEA/call
  creates at most one fixup; `fix_new_exp` reuses its symbol.
- GAS base64 decoding appends each decoded byte separately
  (`read.c:5789–5804,5816–5982`). The producer's chunks contain at most 255
  decoded bytes, bounding `num_octets`; the selected eight-bit-byte target
  adds no tail padding. Its alignment hook creates no `.rodata` alignment.
  ASCII decoding likewise preserves the bytewise reservation charge.
- The reservation delta correctly replaces the null text allowance and adds
  W literal bytes, 8C bounds bytes, 2C pool-alignment pattern bytes and one
  final-alignment pattern. The fragment sum independently reconciles to
  `2Q + 12 + 35 + 2C + 1 + 14 = 2Q+2C+62`. Final subsection alignment is zero
  for this nonmerge `.rodata`, so it adds a pattern/fragment but no uncharged
  payload. The stored 16-bit region condition counts actual alignment events
  and remains a sufficient condition, not an inherent language call limit.
- The extra section, pool labels and two external names reconcile the GAS/BFD
  symbol counts. Ten ordinary sections permit ten relocation sections and
  ten existing section symbols in ELF mapping, yielding 24 headers and
  `Y=S+9` serialized symbols. The object envelope separately charges payload,
  records, strings and alignment. Under the conservative four-byte
  symbol-string ceiling, the resulting name/refcount bounds also fit the
  generic string-table conditions; variable backing/lifetime costs are not
  borrowed from the small-null case.

Independent validation ran `check.py --output
/tmp/silver-literal-assembler-review-20261018.json`: all ten cases passed,
nine pinned inputs and 90 source files verified, and the output was
byte-identical to retained `result.json`. A further source-recognition check
covered all 95 printable ASCII literal bytes, including quote escaping, and
confirmed the exact decoded counts. The symbol-string count/refcount
implications were checked separately with mathematical integers. These are
offline checks, not native emission samples or a machine proof of the source
argument. The retained target evidence is Linux x86_64; no compiler,
assembler, linker, prover or broad suite was executed.

GAS subsidiary/hash/parser lifetime, BFD arenas and string-table growth,
production invocation, fixed-object/binder composition and final-link
displacement reach remain open as recorded. In particular the text and object
size bounds do not prove that every later PC-relative relocation reaches its
target. No implementation, admission rule or production configuration changed.
