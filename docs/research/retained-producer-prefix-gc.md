# Fixed Why3 prefix: collection control and counter capacity

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
For the five byte-identical fixed library inputs in the
[context record](retained-producer-fixed-context.md), an explicit OCaml runtime
configuration keeps the ordinary Why3 initialization, typing, VC creation and
initial session population prefix free of collections. The largest measured
prefix allocates **86,632,681 OCaml words**. Source and installed-constructor
inspection join this lifetime allocation count to the specific counters below.
Their capacities are sufficient in this configured prefix. This is a component
result; #119 and the whole-pipeline admission rule remain unfinished.

The [evidence packet](../evidence/retained-producer-prefix-gc-20261018/README.md)
contains the five successful guarded runs, three stopped diagnostics, all five
managed-run records, complete selected implementation sources, static installed
disassembly and an offline checker. No external binary, Silver admission rule,
Oracle clause or production runtime configuration changed. In particular, using
this component later requires arranging its configuration and fresh-session
premises; the current default runner has not thereby acquired this property.

## Precisely bounded prefix

The pinned `gnatwhy3` executable embeds OCaml 4.14.2. The runtime source used
for this analysis is upstream tag 4.14.2, revision
`8eb41f72ded84df884c3671734c947f612091f84`. Why3 source is the already inspected
`9390baf120ef260547dfa14f08e11c890b203d9c`. Installed symbol/debug information,
domain-state offsets, constructor instructions and the actual runtime guards
corroborate the relevant source behavior. This does not recover the historical
SPARK archive's source revision; the existing
[tool/source correspondence premise](retained-tool-source-identity.md) remains.

The protected interval begins on entry to the **first Why3 module**,
`camlWhy3__Exn_printer__entry` (static address `0x542910`), before the Why3
counter/cache modules initialize. It ends on entry to `Gnat_checks.init`
(`camlGnat_checks__init_1987`, `0x52ff00`). `init_cont` calls that function
after successful `Controller_itp.add_file`, immediately before server connection
(`gnat_checks.ml:371–412`; installed calls at `0x5300ce`, `0x5301e5`).
`add_file` calls `Session_itp.read_file` and `add_file_section`, and propagates
typing errors (`controller_itp.ml:271–288`). Consequently reaching the endpoint
includes normal typing and VC creation, imported source typing, all configured
driver loads, `Task.split_theory`, goal explanation extraction and initial
task/session records. It is not a type-only or disabled-backend shortcut.

The measured `gnatwhy3` processes start neither server nor prover: debugger
fork/vfork/exec catches and new-thread observations stay clear, and the endpoint
precedes the connection function body. Later goal registration, scheduling,
transformations, solver executions and final output are outside the interval.
Managed-run preflight separately records ordinary tool-version discovery; no
solver proof task, Lean build, complete native audit or test suite was requested.

## Runtime configuration and observations

Each fresh process uses exactly:

```text
OCAMLRUNPARAM=s=256M,h=16M,M=1000
```

Here `s=256M` is 268,435,456 words, the runtime's maximum minor arena (2 GiB
on this host), `h=16M` is a 16,777,216-word initial major arena (128 MiB), and
`M=1000` sets the major custom-resource ratio. These are fixed-prefix runtime
settings, not an aggregate RAM admission gate for variable Silver programs.
Arena and remembered-table reservations are not a measurement of resident RAM.
Ordinary allocator/OS success contracts remain the existing environmental
premise; physical exhaustion is not reclassified as language nonmembership.

The environment is explicitly initialized with `PATH=/usr/bin:/bin`, `LC_ALL=C`,
a private `TMPDIR`, and the runtime setting above. Arguments select ordinary
`--proof progressive --steps 0 --timeout 0 --counterexample off`, the fixed
`cvc5,z3,altergo` prover list and the retained entity ID. Every native filename
is relative and fixed. The plan pins 191 executable, debugger, configuration,
input, driver, library and plugin files before and after the run. Each endpoint
also retains the actual mapped executable/plugin/system-library hashes. Only
`gnat_json.cmxs` and `ada_terms.cmxs` are mapped as Why3 plugins.

| Input | Minor allocation since boundary, words | Major allocation since boundary, words | Total |
| --- | ---: | ---: | ---: |
| Put_Line | 86,006,749 | 625,932 | 86,632,681 |
| Put | 85,310,434 | 624,816 | 85,935,250 |
| First_Or_Default | 81,424,058 | 606,251 | 82,030,309 |
| Input_Is_Valid | 77,996,314 | 594,985 | 78,591,299 |
| Is_Message | 77,194,243 | 592,671 | 77,786,914 |

All five start the protected interval with 29,354 current minor words and
7,671 current major words allocated. The largest endpoint has 86,036,103
current minor words and 633,603 current major words. At native OCaml boundaries
the checker uses **register `%r15`**, the active allocation pointer: the stored
`Caml_state.young_ptr` lags and would undercount. `%r14` agrees with Caml_state;
the domain offsets are corroborated by installed `caml_gc_quick_stat` code.

All endpoints preserve the baseline GC statistics and idle major phase, with
zero pending requests. The largest custom-resource fractions are
0.00030517625373250803 (minor) and 0.005134110578642445 (major), below 1. The
largest remembered-table usages are 63,348 reference entries, 142,594 ephemeron
entries and 83 custom entries, each below its 33,554,432-entry threshold.
No dependent-memory accounting is present. The offline checker reconstructs
these comparisons from the snapshots rather than trusting a success label.

Thirteen entry guards stop **before executing** a protected collection,
collection request or GC-setting override: dispatch, empty-minor-heap,
major-slice, finish-major-cycle, minor-collection, the six exposed Gc control
primitives, and the two request functions. Their actual addresses and first
32 bytes are retained. No inferior function call or memory-field modification
is used; the diagnostic installs debugger breakpoints and reads state.

## Why this transfers to the fixed context

Byte-identical JSON alone is insufficient: collection timing can clear weak
caches and change allocation history. The transfer uses the following stronger
source projection and runtime argument.

1. Fix the executable, runtime settings, config, configured drivers/libraries,
   two selected plugins, relative input filename, input bytes and fresh-session
   branch. Retain the recorded pathname layout, or an allocation-equivalent
   relocation preserving path component lengths and equality relationships.
   Arbitrary path growth, a populated session, extra plugins or config changes
   are not covered. `Gnat_config` derives the session path from the relative
   filename (`:715–741`); its cwd read sets TEMP/TEMPDIR (`:690–694`). Session
   relativization receives fixed relative paths (`controller_itp.ml:277`;
   `sysutil.ml:209–229`). The entity selector affects the later report, outside
   this prefix (`gnat_report.ml:222`). This projection includes the startup
   pathname storage as well as semantic input; it does not silently discard
   allocation costs of paths.
2. Cache/hash behavior is fixed independently of numeric addresses. OCaml
   `Hashtbl` only selects randomized defaults when its runtime parameter string
   contains uppercase `R` (`hashtbl.ml:49–76`), absent here; its unseeded functor
   and `Ephemeron.K1.Make` force `random:false` (`:477–484`,
   `ephemeron.ml:553–560`). Why3 `Weakhtbl` hashes and compares explicit integer
   tags (`weakhtbl.ml:60–85`). Hcpt hashes key IDs and subtree IDs; its physical
   equality tests express sharing, preserved by a consistent address renaming
   (`hcpt.ml:132–158`). The six hashcons keys use strings, scalar tags and
   structure, with physical equality where nodes are shared; none converts an
   allocation address into its hash. Standard structural hashing of these
   values is independent of their placement. The retained scan of 293 complete
   Why3 implementation/parser files finds no GC or randomization override; the
   only Random calls belong to the unselected `genequlin` plugin. The selected
   plugin branch is explicit at `gnat_util.ml:110–123`. Thus absence of weak
   clearing preserves the configured prefix's cache decisions and allocation
   requests; this is a source condition, not an inference from input hashes.
3. Before the first Why3 module, Re's fixed Dense_map/Cset initialization
   forces one minor collection: `caml_make_vect` promotes a young initializer
   when constructing a major array (`array.c:239–243`). A larger arena cannot
   remove it. The installed module order puts it before Why3's counters and
   caches; the retained trace has one minor collection, zero completed major
   cycles and an idle phase at the protected boundary. This fixed startup
   establishes the recorded baseline instead of claiming no GC since process
   entry.
4. Suppose a first protected collection/request occurs in another execution
   satisfying this fixed context, before resource failure. Until that event,
   there is no weak clearing and the projected requests agree. The minor
   pointer remains above its trigger; cumulative major allocation stays below
   the minor-arena threshold (`memory.c:494–497`); custom fractions stay below
   1 (`custom.c:33–106`, `memory.c:577–585`); remembered tables stay below their
   thresholds (`minor_gc.c:585–610`). No dependent-memory request, explicit
   protected collection or setting change is selected. These quantities are
   monotone in this interval; any request/slice would also hit an entry guard.
   The hypothetical first event therefore has no triggering route. This is
   the first-collection argument, using source projection **and** entry guards,
   not only final heap statistics. Signals/profiling that alter GC behavior
   are outside the fixed controlled invocation; ordinary external process
   interruption has no successful-completion claim.

With no protected collection, allocated managed words are not reclaimed and
reused. Minor-pointer consumption and the cumulative major-allocation counter
therefore bound lifetime managed allocation in this prefix. C/library backing
allocations are not silently counted as OCaml words; their GC resource triggers
are accounted separately above.

## Allocation-to-counter join

Let `W` be the measured total allocation since the first Why3 module for the
selected fixed input. All the following counters initialize after that boundary.
Each increment can be charged to a fresh managed allocation in its construction
path. Distinct calls within one counter family get distinct charges; different
families need not have disjoint charges because the bound is **per family**.

| Counter family | Initial value | Allocation witness |
| --- | ---: | --- |
| Ident registration | 0 | Fresh identifier record, `ident.ml:187–192`; installed constructor allocates 40 bytes |
| Six Hashcons instances: attributes, logical types, program types, declarations, theory declarations, tasks | 0 each | `H.tag` creates a record before `next_tag` increments on merge miss or unique (`hashcons.ml:35–49`); installed tags allocate 24, 24, 32, 32, 24, 56 bytes respectively |
| Hcpt IDs | 1 | Every hashcons call comes from a fresh Leaf/Branch constructor (`hcpt.ml:153–158`), installed allocations 32/48 bytes |
| Dterm fresh type variables | 0 | Dind, ref and Dvar allocation, `dterm.ml:27`; installed constructor allocates 48 bytes |
| Program declaration tags | 0 | Fresh pdecl record, `pdecl.ml:310–316`; installed constructor allocates 56 bytes |
| Program expression IDs | 0 | Fresh expression record, `expr.ml:483–493`; installed constructor allocates 64 bytes |
| Environment tags | -1 | Fresh environment record, `env.ml:43–46`; installed constructor allocates 24 bytes |
| Driver tags | -1 | Fresh driver/result-parser records after load, `driver.ml:254–280`; installed allocation retained |
| File tags | 0 | Fresh hash-table bindings before increment, `loc.ml:46–58` |
| Synthetic Ptree location line | 0 | `get_pos` increments then constructs `Loc.user_position`, `ptree_constructors.ml:6–13`, `loc.ml:279–282`; installed call and 32-byte record retained |
| Native converter call IDs | 0 | Sole caller formats a fresh label and constructs its attribute, `gnat_ast_to_ptree.ml:330–335`; installed path also allocates the enclosing variant |

These are the normal typed-data constructor paths, under the existing runtime
allocation-success contract. Hashcons increments only after its fresh tag
record exists; Hcpt increments only after its fresh node exists. Helpers between
the pdecl/environment increment and record creation are structural folds over
the typed data; `get_news` additionally allocates `ClashIdent id` before its
duplicate-check operation. The installed disassembly prevents treating a
source record optimized away by the compiler as an allocation witness.

Using the deliberately loose one-word charge, each family's increment count is
at most `W`, and its value at most `W + 1`. Here
`W + 1 <= 86,632,682 < 2^47 - 1 < 2^62 - 1`. The first bound is sufficient
for the synthetic location line domain; the second is the positive domain of
the 63-bit signed OCaml integer on this host. Before a hypothetical first
overflow, every earlier increment has its allocation witness, so the same
inequality rules out that first overflow without assuming counter correctness
circularly. Synthetic positions use column zero; real imported-file positions
remain the separately pinned fixed-file context.

This table is intentionally an explicit inventory, not a claim that every
integer in Why3 has been covered. In particular, the separate Hashcons instance
in `transform/introduction.ml:33–51` returns its input from `H.tag`, so it does
not inherit the fresh-tag-record argument. Session IDs, other traversal/output
counters and later transformations require their own joins if used in a
whole-process claim. The packet does not extend this result to variable Main,
solver internal domains, solver output or final report capacity.

## Diagnostic history and cost

The successful managed run is `20261018T125544-a11ebc3568d2`: 8.3794 seconds
including orchestration/preflight, with 6.2251 seconds across five serial
debugger invocations. It ran once. Three earlier stopped native diagnostics
used respectively 0.2668, 0.2794 and 0.3308 debugger seconds:

- `20261018T125109-75dbac3c2161` stopped at the mandatory pre-Why3 array
  promotion. Source/module-order inspection justified moving the protected
  boundary to the first Why3 module.
- `20261018T125317-d20cf1a42135` exited before typing because the diagnostic
  invocation omitted required `--entity`. The IDs were restored from retained
  successful `.spark` records; this was an invocation repair.
- `20261018T125415-3ad60d9a0950` stopped at the first major custom-resource
  request while opening a driver input channel. The driver DAG expands to
  57 driver opens, alongside 21 library files. The `s`-only setting left the
  initial major-resource denominator too small; explicit `h` and `M` corrected
  that premise. The successful run retained guards for all resource routes.

An earlier managed setup attempt, `20261018T125058-ed97efbc898e`, failed before
launching the diagnostic because this offline worktree has no native setup.
Subsequent runs used the configured root installation and isolated `/tmp`
workspaces. All stopped attempts remain in the packet. No identical-success
native rerun was used for packaging or review; the checker is offline.
