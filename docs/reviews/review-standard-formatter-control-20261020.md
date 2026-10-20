# Retained standard formatter control review

2026-10-20 UTC; #119 / #153. **Accepted at its stated source-control scope**
under the selected source/native, typed-ownership, initialization, loader and
runtime premises, at author freeze
`adb3f7e7b06f78aea5598e5f318f93a87362660e`, based on
`f79a5736e42c7cac9b414d929b2c64783a1e7b83`. No material defect or required
repair was identified. The accepted result fixes stdout/stderr callback and
setting ownership; it does **not** establish either initial dynamic formatter
graph, interrupted global-state arithmetic or output capacity. Those exports
remain null.

Selected reviewer setting: GPT-6 Astra / Extra High, explicitly assigned by
the lead. Runtime model/effort confirmation and individual token/cost telemetry
were unavailable. Observed review start was 15:56:32 UTC; semantic review
completed at 16:01:35 UTC, an elapsed 303 seconds. The reviewer used a separate
Linux x86_64 worktree and owns only this report. The lead retains integration,
issues, durable memory and publication. The reviewer did not author the packet.

Exact inputs are the [research argument](../research/retained-why-standard-formatter-control.md)
and twelve files in its [evidence packet](../evidence/retained-why-standard-formatter-control-20261020/README.md),
including the checker, 65 source excerpts, 528-file ML/interface census,
52-initializer call ledger, 87 retained native bodies, five capture/configuration
projections and explicit control/result interfaces. Relevant source was inspected
in GNAT, Why Debug/Loc/Pp/Printer/JSON/config/plugin/driver paths, native Dynlink,
Misc, Location, Profile, Env/Predef, Warnings and Format. Inspected complete
source-file identities matched the frozen witnesses. The inherited
initialization/pending-client, driver, exit-chain and ordinary-ending results
were reused at their existing scopes without replaying their checkers.

Why3 remains `9390baf120ef260547dfa14f08e11c890b203d9c`; OCaml remains
`8eb41f72ded84df884c3671734c947f612091f84`. Installed ELF SHA256 is
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`;
retained disassembly SHA256 is
`f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5`.
Oracle 7–9, 13, 21 and 25 govern the review. These identities and instruction
checks attach concrete evidence; they do not replace the selected external
behavior relation or prove historical build identity/native refinement.

The critical challenges were resolved as follows:

- **Distinct globals and one stderr wrapper.** Format constructs separate
  stdout and stderr channel formatters, publishing their pointers in module
  slots +0x360 and +0x368. The native channel arguments, two constructor calls
  and stores agree with this source ownership. Debug initialization installs
  one wrapper on stderr, retaining the old five-function record; newline calls
  the saved default newline and then the saved channel flush. GNAT later
  selects a distinct escape formatter, and the absent log branch would create
  another fresh channel formatter. Neither adds a second stderr wrapper.
  Stdout has no Debug wrapper. The accepted Debug escape freshness result is
  not used to infer standard-formatter freshness.

- **Setter aliases and private destinations.** Pp.wnl is treated as a real
  exported setter. Its actual source clients first allocate Buffer100
  formatters. Pp's margin/max-box/ellipsis setters likewise receive fresh
  local formatters; Loc.warning creates its own Buffer100 formatter before
  setting the large warning margin. sprintf/asprintf use fresh Buffer512
  formatters, not str_formatter. Independent searches also covered standard
  setter/tab API names beyond the packet's census pattern and retained
  non-ML/interface Why sources. The lexer.mll module-print diagnostic is
  guarded by print_modules=false; the why3wc lexer is an unselected frontend.
  No additional standard setter or tab producer was found. These inspections
  support the typed client argument rather than making lexical absence an
  arbitrary-alias proof.

- **Linked Color/Location code is not silently discarded.** Color.setup can
  install marker wrappers and enable tags on global formatters. Location's
  output-counting wrapper can remain installed if its print/flush raises before
  restoration. The review therefore checked selected entry and loader paths.
  Misc initialization constructs the Color state/closures/list but does not
  invoke setup. Its two List.map callbacks, including the checked static
  closure words, construct Cmx/Cmxa values. Location registration only prepends
  to its private error-printer list; it does not invoke the printer or reporter.
  The native initializer census independently matches all 52 retained
  compiler-library initializer symbols. Its construction/registration calls,
  fixed warning-option parsing and local-store operations add no report route.
  The two indirect initializer sites are resolved: Profile finishes a
  Printf.sprintf string; Env finishes add_extension partial application before
  building the environment with check=false callbacks. A failed initializer
  does not become an invented compiler diagnostic callback.

- **Native loader and selected plugins.** Native Dynlink performs map/header
  consistency work and selected initializers. Its duplicate-symbol message is
  a private asprintf; initializer failures wrap/reraise. Dynlink.error_message
  forms strings and does not dispatch Location reporting. Opening the packed
  compiler-library module is not invocation of its diagnostic functions.
  GNAT's built-in-prover branch directly loads only gnat_json and ada_terms;
  their initializers register formats, parsers and Why exception printers.
  Those printers receive the caller's formatter. The accepted continuation
  adds no interactive compiler or additional loading path. Why's ANSI installer
  belongs to the separate why3prove main. Color/Location remain possible in
  the general wrapper family, but their installation is excluded in this
  particular source/control scope.

- **Warning destination and exact configuration.** Native entry order places
  Gnat_report after Gnat_config. Before that point Loc's default hook prints
  to stderr; afterward add_warning retains a string in the warning list.
  Optional location text uses private sprintf. The only selected alternative
  hook is the absent log branch. The common 1946-byte base config contains
  the required main/editor/prover fields, with source defaults for the rest;
  both 18-byte overlays contain only main magic 14. These actual records avoid
  the ordinary MissingField and strategy-space warning branches. Configuration
  failures privately format and raise ConfigFailure, then GNAT aborts; that
  handler does not resume configuration. No SIGINT save handler is installed
  yet. This reasoning concerns the selected ordinary configuration prefix,
  not every later failure or a newly executed configuration parser.

- **Diagnostics are retained where their guards are not proved.**
  Printer.int_of_string catches every exception from the conversion, then
  prints to stderr before asserting. Intended decimal syntax alone cannot
  exclude this writer. The model parser's malformed-expression diagnostic is
  also retained: Call_provers requires get_model=Some, and Driver derives that
  value from task meta. CE-off is not substituted for the missing actual-meta
  attachment. Conversely, the generic plugin catch-and-print loop, interactive
  cleaning notification and archive_session message are outside the selected
  built-in loading/ordinary-ending/save_session routes. None of these retained
  failure writers installs callbacks/settings/tags/tabs. No diagnostic frequency
  or payload bound follows from this classification.

- **JSON and callback separation.** Normal reporting uses single-line JSON;
  abort uses structured JSON before exit. Their recursive %a functions are
  JSON printers. Key/string bytes, including @ and tag-looking text, are data
  escaped by the JSON routines and cannot install Format state. Exception
  printers run while constructing a private error string. The escape Buffer
  contents copy later becomes warning data; it does not copy formatter state
  or change standard callbacks. StandardFloat's %f, copy/escaping extents and
  service capacity remain separate obligations. The standard exit hook flushes
  stdout first, then stderr; an exception in the first flush skips the second.
  A consumed gate proves neither completed output nor a successful reset.

- **The pre-cut partial-output possibility is stated at the right strength.**
  iter_leafs protects List.iter including register_goal with Not_found -> ().
  register_goal can select abort after label processing, and parse_check_string/
  read_label have Failure handlers around conversions/location processing.
  Exception-class catches are not proofs that the exception arose from malformed
  text. Abort can mutate stdout before it calls exit; an escaping Not_found
  can be consumed by the outer registration catch. Thus gate truth alone is
  insufficient to establish untouched stdout. The packet does not claim the
  complete interruption sequence occurred, or even establish its eligibility
  on the actual label/service domains. This is an unresolved exclusion/accounting
  path, not a reproduced counterexample. The review does not extend the global
  post-cut r<=3/e<=2 budgets to an earlier prefix or introduce a no-signal premise.

- **Exact missing input and interrupted reuse.** The per-process load bias is
  attached through the known Debug hook and checked against the standard hook.
  The retained read scan finds no complete 8-byte coverage of either standard
  root slot in any case. Debug's observed formatter record is a different
  object and cannot supply either global graph. The missing specification
  correctly names both slot words, 28-field records, queue cells/payloads,
  scan/format lists with identity relationships, and dynamic fields 8–13.
  Native pp_enqueue stores right_total at 0x986e1d before tail-transferring to
  Queue.add at 0x986e2e. A pending exit can therefore reach a standard flush
  during a partial enqueue. Nonreturning signal control does not make that
  mutation transactional or preclude higher-level reuse. A bounded initial
  graph would still require a separate interrupted-prefix arithmetic proof.

The accepted fixed profile is margin/minimum-space/maximum-indent 78/10/68,
max_boxes=2^62-1, ellipsis '.', ordinary channel output/flush and default
spaces/indentation, default tag callbacks with both switches false, empty
tag/mark/tab stacks, no Color/Location wrapper, and exactly one stderr Debug
newline wrapper. The selected source producers and setter exclusions preserve
that profile through the continuation. This does not bound dynamic indentation,
queued bytes, ordinary queue/scan/format stack sizes, or line/depth counters.
Both initial dynamic states, freshness, prefix preservation, model diagnostic
exclusion, whole-output capacity, complete R and complete U remain null.

The focused checker ran **once**, in comparison mode without --write:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-why-standard-formatter-control-20261020/check.py
```

It passed all imported/archive identities, exact regenerated-output comparisons,
65 source excerpts, 87 native bodies / 87617 instruction bytes and all five
zero-coverage root-slot results. It reported 19.23211169500064 seconds; the
reviewer measured 19.301776399999653 seconds around the subprocess. Git status
and diff remained empty. No substantive or timing artifact changed: the author's
round.json timing was retained, while the new timing appeared only in command
output and this report. The checker binds witnesses, not semantic reachability
or formatter invariants.

No new research or capture was undertaken to close freshness. The remaining
source-prefix or existing-read attachment and interrupted global-state proof
are recorded obligations, not authorization for new acquisition. No production,
language, Oracle, tool-pin, GitHub or CLI memory change was made. No target,
capture, disassembler, source fetch, solver/Lean run, predecessor checker or
duplicate successful check ran. The child harness goal was null; no goal status
changed. Complete exit/save capacity and #153 completion are not claimed.
