# Retained Debug formatter first-use review

2026-10-20 UTC; #119 / #153. **Accepted under the stated selected-input,
source/native, typed-ownership and runtime/loader premises** at author freeze
`7ead79763d239bbd81ed734b2aaa1ef01d8cc747`, based on `323a54cc7e`.
No material defect or required repair was identified. This accepts the exact
escape formatter constructor/setup state at all five retained cuts and its
preservation through each selected continuation until the first Stats exit-hook
entry. It also accepts the additional newline wrapper's 16-byte own frame.
It does not establish complete exit/save stack, capacity or physical adequacy.

Selected reviewer setting: GPT-6 Astra / Extra High, explicitly assigned by
the lead. Runtime model/effort confirmation and individual token/cost telemetry
were unavailable. Observed review start was 15:28:54 UTC; semantic review
completed at 15:34:30 UTC, an elapsed 336 seconds. The reviewer used a separate
Linux x86_64 worktree and owns only this report. The lead retains integration,
issues, durable memory and publication. The reviewer did not author the packet.

Exact review inputs are the [research argument](../research/retained-why-debug-formatter-control.md)
and eleven files in its [evidence packet](../evidence/retained-why-debug-formatter-control-20261020/README.md),
including its checker, 603-source client/flag projection, 43 source excerpts,
five-process attachment and 20 retained native bodies. Relevant source paths
were independently inspected in Debug, GNAT main/config/util/report, Whyconf,
Trans/Libencoding, Termcode, Smtv2, Why3printer, Pretty/Expr, Pinterp, Pp, Format,
Buffer, CamlinternalFormat and Stdlib. The accepted prefix, native/pending-client
ownership and persistent exit-chain results were reused without replaying their
checkers. The earlier private F interface and separately accepted timing-format
and timing-growth results were not revalidated or promoted to complete capacity.

The source identities remain Why3
`9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml
`8eb41f72ded84df884c3671734c947f612091f84`. The installed ELF SHA256 is
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`;
the retained disassembly SHA256 is
`f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5`.
Oracle 7–9, 13, 21 and 25, complete selected owner/callback closure and the
source/native/service distinction govern this review. The behavior relation is
an explicit external premise, not a recovered historical source-build identity.

The following critical challenges were resolved:

- **Concrete attachment rather than missing-pointer inference.** The five
  cases/PIDs are Put_Line/17310, Put/17514, First_Or_Default/17631,
  Is_Message/17704 and Input_Is_Valid/17869. Their exact retained process and
  exit-hook records attach to the accepted prefix: fixed executable/seven
  images, one initial OCaml worker with no added worker, two selected plugins,
  Per_Check, CE off, external server and no replay/debug/standalone route.
  Neither WHY3DEBUG nor GNATWHY3LOG is present. Missing Buffer, queue, stack
  and callback descendants in raw observations remain missing; scalar matches
  and unchanged mappings alone cannot establish freshness. The source-prefix
  and ownership argument supplies the unobserved state.

- **Flag identity, writers and configuration.** The flag type is abstract;
  all representation-field uses are inside Debug. Registration shares an
  existing same-name object and otherwise initializes from the one WHY3DEBUG
  snapshot. The selected writes enable vc_sp, rac:execute_no_builtin_mach and
  stats. Their consumers do not add a dprintf sink. GNAT parses its own options;
  recorded argv leaves arbitrary --debug-why3, debug/save-VC/stack-trace and
  No_WP writers inactive. Its direct read_config/build_env route does not run
  Whyconf.Args initialization or Debug's queued argument handlers. Built-in
  provers select only gnat_json and ada_terms. Other frontend/plugin writers,
  the commented Jessie setter and Glob's unset are correctly classified.
  Selected environment writers do not populate either missing debug variable.

- **A failed restoration does not invalidate the flag induction.** The Why3
  printer can leave print_attributes true if printing or a pending action
  raises before restoration. The packet conservatively allows that flag to
  remain true. Pretty/Expr use it to select output to an already supplied
  formatter; it is absent from the dprintf sink-name set. No successful-cleanup
  assumption is needed. Same-name registration aliases were checked by their
  actual names, rather than assuming each source variable denotes a new flag.

- **Lexical census versus executable call flow.** The 465 records are lexical
  Debug.dprintf occurrences, not a count of executed calls or a proof by search.
  The generic Trans.print_meta parameter has exactly three source clients,
  all passing Libencoding.debug, registered as encoding. An independent scan
  also found Termcode's unqualified dprintf use: its partial application at
  termcode.ml:1062 is already a census record and fixes session_pairing, which
  remains false. No module alias/open/include supplies another external Debug
  client; the apparent local Debug module in encoding_guards_full is commented
  out. Debug_optim's AST rewrite adds a test_flag guard to direct calls; it does
  not introduce an enabled-output path. This resolves the concrete aliases
  without treating the lexical checker as an OCaml control-flow verifier.

- **Ignored formats and direct-access bypasses.** Debug's false branch transfers
  to Format.ifprintf, which discards the formatter and invokes make_iprintf
  with unit state. Alpha/Theta/custom-format arms consume arguments without
  invoking supplied printers; literals, flush and formatting directives do
  not operate on the discarded formatter. Argument evaluation can still have
  effects and is covered by the source client/alias argument. Smtv2 obtains a
  real alias, but its direct Pretty call is guarded by smtv2_printer=false.
  Trans.create_debugging_trans and its private print_task_goal genuinely bypass
  flags and print directly. The complete source projection has no reference
  to the exported helper beyond definition/interface; the private helper is
  used only there. Their executable bodies exist. Exclusion depends on actual
  typed clients and the accepted fixed-plugin/no-reflection boundary, not on
  absent symbols or only a search for direct native calls.

- **Constructor and publication order.** Reaching any cut requires the
  Buffer.create 42, formatter_of_buffer and one escape setter call to finish.
  There is no source recovery from an incomplete constructor into these cuts,
  and the accepted pending clients cannot enter a cut with that prefix still
  active. Buffer position is zero, capacity 42, with initial/backing storage
  shared. The formatter is not an empty queue: it contains one unknown-sized
  Pp_begin(0,Pp_hovbox) token of length zero. The scan stack has that system-box
  entry at left_total 1 above an empty-text sentinel at -1. Format/tbox/tag/mark
  stacks are empty. Geometry is margin 78, minimum space 10, maximum indent 68,
  space left 78 and indent zero; newline is true, totals/depth are one, maximum
  boxes is 2^62-1, ellipsis is '.', and both tag switches are false.

- **Callback closure and the additional frame.** out_string owns precisely
  Buffer.add_substring escape_buffer; flush is ignore. Default newline, spaces
  and indent retain the same formatter and dispatch through its out_string.
  The setter copies the old five-function record, changes only newline, writes
  the fields, then publishes the ref. Its closure retains the old record, not
  itself. Absent GNATWHY3LOG fails before the second GNAT setter; Debug's earlier
  setter targeted the distinct err_formatter. Thus escape has wrapper depth
  one. Native fun_2950 reserves eight bytes plus its return slot: 16 own bytes.
  The call at 0x559c8d selects captured Format.fun_2407; the tail at 0x559ca7
  selects captured Format.fun_2447. Tail transfer releases the wrapper's local
  slot; its GC poll remains a separate runtime service. This body is additional
  to the earlier F body family. Adding a bare 16 to a whole-exit formula would
  still require wrapper multiplicity, active-frame and runtime-bridge arguments.

- **Earlier signals, failure and first-hook boundary.** The accepted at_exit
  chain only prepends links, and each persistent gate changes true to false
  before calling its callback. Both observed tagged-3 gates therefore exclude
  an earlier partial Stats invocation as well as a successful one. They do not
  exclude earlier signal saves that failed and were caught before exit. Those
  saves use private formatters and disabled diagnostic flags; SIGVTALRM and
  classified native owners do not acquire a new typed escape alias. GNAT's
  caught/uncaught reporting constructs strings with fresh formatters and emits
  through its own standard-output route. Buffer.contents in ordinary ending
  copies without mutating or publishing the Buffer. The selected suffix adds
  no configuration, plugin or interactive client. Hence the same induction
  holds until the first Stats hook, including entry through a signal or failure.
  Registered statistics remain empty because their private list only prepends
  and no external registration client is selected. No no-signal premise was
  introduced.

The focused checker ran **once**:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-why-debug-formatter-control-20261020/check.py
```

It passed all 612 retained source-member identities, the 603-source projection,
five input attachments, 465 sink records and 20 native bodies / 5,139 instruction
bytes. The reviewer measured 5.997741013998166 seconds around the subprocess.
The checker regenerates artifacts; Git status and diff afterward were empty,
so the regenerated files matched the exact reviewed freeze. This attaches
evidence and checks native bytes; it does not mechanically prove the semantic
writer, ownership or first-use induction.

After Stats begins, queue, Buffer, counters and stacks can be partially changed
by an exception. The once gate prevents retry; it does not restore constructor
state. The accepted persistent callback/setting ownership must not be confused
with persistent constructor freshness. No result transfers to std_formatter or
err_formatter. Partial-output bounds, complete Stats composition, subsequent
failure and standard/error phases, full R and ambient A_pre remain open; global
r<=3 and e<=2 do not renew. Complete exit/save flags remain false.

No production, language, Oracle or tool-pin change was made. There was no native
target execution, new capture, disassembly, source fetch, solver/Lean run,
predecessor replay or duplicate successful check. No GitHub or CLI memory write
was made. The child harness goal was null; no goal status changed.
