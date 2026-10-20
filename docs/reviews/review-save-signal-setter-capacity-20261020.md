# Selected signal-setter capacity review

2026-10-20 UTC; #119 / #153. **Accepted within its stated conditional scope**
at freeze `76197eee3dc69d30428ef1e79b29baccb618b92c`, based on
`b9cd46dc0e6af014e5a32b2b7f180775f3d7856e`. No material defect or required
repair was identified. The six setter entries, 96 direct normal wrapper-request
bytes and 5,720-byte setter-phase caller projection do not establish complete
failure, handler, save or physical-resource capacity.

Selected reviewer: GPT-6 Astra / Extra High, explicitly assigned by the lead.
Runtime model/effort confirmation and individual token/cost telemetry were not
available. Observed review start: 14:41:09 UTC; semantic review completed at
14:43:24 UTC, an elapsed 135 seconds. The reviewer used a separate Linux x86_64
worktree and owns only this report. The lead authored the packet and retains
integration, issue state, memory and publication. The reviewer participated
in the earlier Round 37 review, whose successful evidence is reused; this
review does not rerun or extend that earlier result by implication.

Exact inputs are [the argument](../research/retained-why-save-signal-setter-capacity.md)
and all nine files in [its packet](../evidence/retained-why-save-signal-setter-capacity-20261020/README.md).
The reviewer inspected every retained native body, source excerpts, actual
signal-table data, selected edges/frame facts, checker, imported identities and
result. Additional reads covered the inherited whole-post-cut protocol,
original callback-launch qualification, Round 37 dispatch/bridge composition,
initial callback ownership, channel raise-path qualification, and retained
runtime pending-signal and small-allocation source. The fixed ELF SHA256 is
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`;
Why3 and OCaml remain the previously retained source revisions
`9390baf120ef260547dfa14f08e11c890b203d9c` and
`8eb41f72ded84df884c3671734c947f612091f84`.

The review applies Oracle 7–9, 13, 21 and 25 and preserves the separation
between source/native caller reasoning and external-service semantics.

- The installed handler supplies tagged -11, -7 and -21, hence portable
  signals -6, -4 and -11, with immediate action 3. The installer's inlined
  conversion indexes the actual ELF table at `0x9f2bc0`; entries 5, 3 and 10
  are native 2, 1 and 15. Untagging, conversion, indexing and the installed
  0..64 range check are valid for these arguments. The unavailable-signal
  branch is excluded by these fixed inputs, not by assuming all setters
  succeed. The retained sys.mli contract plus actual native wrapper supports
  selection of caml_install_signal_handler and discarding its result; no
  generated sys.ml implementation is claimed to be retained.

- Each handler contains three sequential setter sites under one
  Invalid_argument trap. A matching exception skips the remaining protected
  sites and proceeds to save; another exception escapes. Neither path retries
  an earlier setter. Ordinary ending supplies no additional site. Under the
  preserved successful mask/ignore and native-frame protocol, the one global
  two-callback allowance therefore permits at most six setter entries.
  This boundary is essential: the original callback-launch theorem explicitly
  bounds save-entering callbacks and excludes arbitrary failed signal-service
  retries before the first ignore commit. The new result must not be exported
  as a bound on those excluded retries, pre-commit physical-failure recovery,
  or changed mask/reinstallation behavior. The note states this conditional
  boundary and leaves broad failed-service behavior incomplete; the six-entry
  result is not used to prove its own protocol premise.

- The old default/ignore returns are immediate. The old-handle branch makes
  one caml_alloc_small request for one field, hence 16 bytes with its header,
  after installing the OS action. It references the existing handler closure
  rather than copying it. Charging one request at every entry includes a final
  abandoned attempt and gives 2*3*16=96. There is no retry inside this source
  caller. Allocator internals, error strings and later pending callbacks have
  separate owners; 96 is not complete failure allocation. Immediate action 3
  bypasses the block-action branch, so these setters neither allocate the
  handler array nor register/update its global root or closure slots. The
  accepted installed-array relation remains necessary when reading an old
  handler slot.

- The own frames, including incoming return slots, are 48 for the handler
  with its setter trap, 16 for Sys.set_signal, 208 for the installer, 352 for
  caml_set_signal_action and 16 for raise-if-exception's charged prefix.
  Adding the imported 192-byte normal scanner and 4,104-byte direct bridge
  high-water gives 4,936. The installer/action native reservations agree
  with their local records and pushed registers. The bridge's temporary
  4 KiB touch is charged even though it is restored before the C callee runs.
  Summing mutually exclusive action/scanner and transient/live phases is
  conservative. Sequential setters multiply cumulative requests, not this
  simultaneous stack projection.

- The incoming dispatch is 816-32=784 bytes. Adding it yields 5,720, with
  the new 48-byte trapped handler replacing the old 32-byte save-phase
  handler. The incoming scanner and installer-called scanner are distinct
  suspended/active instances, so their two charges are not duplication.
  The native handler pops its setter trap before save and restores its local
  frame before tail-transferring to exit. This projection therefore cannot
  replace the complete handler demand or be added to the save-phase handler
  as though both handler frames were live. Suspended outer work, nested
  callbacks, service-owned crossings, allocation/libc interiors, raising
  diagnostics and later save/exit work remain separately charged obligations.

The focused checker ran once, without changing author artifacts:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-why-save-signal-setter-capacity-20261020/check.py
```

It passed five exact source excerpts, six retained native bodies / 1,020
instruction bytes, actual signal-table data, selected edge/import checks and
the result comparison in 0.317240444 seconds. The arithmetic and byte checks
do not mechanically prove source/native refinement, the protocol, or libc/OS
behavior. Usable bounds remain null without the named relation; complete
handler/setter/exit and save stack remain null, and physical sufficiency false.

Only this report changed. No native execution, capture, new disassembly, source
fetch, solver/proof run, predecessor replay or repeated successful check was
performed. No GitHub or CLI-memory write occurred. The child harness goal was
null; no goal status changed.
