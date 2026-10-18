# Independent review: literal Main ALI adapter

Reviewed implementation: `e8b931aa77cf29958ba9eeb2108486553fcda3ad`.
Disposition: **accepted for the stated conditional Main ALI writer and exported
reader-buffer interface**. No blocking defect or required correction found.
This does not accept a complete binder/GPR/parent process or production rule.

The review covered all seven files introduced by that commit, the pinned
`native_invocation_metadata` and `native_ali_backing` implementations and their
source arguments, and the relevant selected GCC Ada sources. The exact packet
input manifest is `inputs.json` (SHA-256
`2b3e08926f6c487b58cfa766f0ef5fa46a908ceec6f4596927baafe8d48dcad7`).
The reviewed callable SHA-256 is
`061cec323dfee8e9c8fd8250caa0efc62ac0917b1de8daca5f9dfaff8fcb6140`.

- **Invocation frontier:** direct literal Put/Put_Line calls and nulls introduce
  no entity outside the accepted broader 19-target frontier. In
  `sem_elab.adb:12165–12193,13190–13241`, saved-construct and saved-pair tests
  precede their ALI appends. Repeating source calls therefore does not require
  multiplying the 19/361/19 construct/relation/signature bounds. The signature
  fields are stable entity attributes during this graph pass; the existing
  97-character allowance includes ten-digit source coordinates. Passing zeros
  to the broader helper does not undercharge exported scenario lifetimes:
  only the four source-independent ALI fields are extracted, and the adapter
  explicitly leaves marker/scenario lifetime work elsewhere.
- **Selected switches:** the eight A payloads are read from the pinned literal
  witness, then joined with the established indexed `-gnateI1` and retained
  split-option transfer. Ten payloads total 110 bytes and ten serialized A
  records total 140 bytes including LF. The old six-switch or 399-byte null
  descriptor is not reused. Internal naming/map/include paths retain their
  established nonrecording projection. The result is conditional on the
  selected command; it does not misidentify the historical literal witness as
  an execution of the complete indexed/split descriptor.
- **Writer and reader scope:** `native_ali_backing(..., include_xrefs=False)`
  uses the accepted no-Xref serializer route with the selected specification
  closure and unchanged unit-table allowance. The complete-file bound is an
  export for a downstream EOF-terminated allocation, not an aggregate-memory
  condition or a bound on every downstream table. Independently summing the
  record families gives
  `115+140+6160+78843+1990304+6+2052+74727+49 = 2152396` bytes.
  The largest record including LF is 1184 bytes at P=512, below the actual
  2112-byte EOL reserve even though the complete file envelope exceeds the
  writer's 2112000-byte buffer. The exported reader object is 2152397 bytes.
  GPR/binder row policies, graph/table lifetimes and full launch materialization
  remain explicitly unclosed.
- **Source correspondence and checks:** both replay entry points verified the
  ten pinned predecessor inputs, the relevant complete-source identities used
  by the existing model, and all 48 serializer/specification inputs. The eleven
  focused checks passed. `check-results.json` and the default Hello
  `result.json` each replayed byte-equal. The P=976/P=977 result follows the
  conservative record envelope, not an asserted tool/path maximum. No compiler,
  assembler, linker, prover, solver, Lean or new native witness ran.

Replay commands were the README's `check.py --ada-root
/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada`, followed by
`compose.py` with the same root and default source/P. Outputs were written
under `/tmp` and compared with the committed records. Check replay wall time
was 0.391430396 seconds; full default-result replay was 0.310158983 seconds.
The actual host was Linux x86_64. The review worktree changed only this report.

Selected reviewer model/effort: **GPT-6 Astra / Extra High**, assigned by the
parent. Runtime model/effort confirmation is unavailable; no model change is
claimed. Review began 2026-10-18 18:31:36 UTC and completed
2026-10-18 18:34:43 UTC (elapsed 187.392 seconds).
Token and cost measurements are unavailable. No additional agent was spawned.
The child harness has no active goal; the parent's overall goal was not changed.
