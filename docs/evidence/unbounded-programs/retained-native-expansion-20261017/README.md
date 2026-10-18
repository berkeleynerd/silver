# Native Main expansion accounting evidence

This supports the [native expansion component](../../../research/retained-native-expansion.md).
It is a source-derived direct emitter envelope, not a complete native construct
bound or a selected capacity rule.

Regenerate with Python 3, passing the complete pinned GCC `gcc/ada` source
directory and an output path:

```sh
python3 derive.py /path/to/gcc/ada /tmp/native-concat-local-envelope.json
```

`derive.py` verifies132 source files against the checked-in complete
manifest. It sums the manually derived control-flow rows and emits a lexical
call-site list to help inspect coverage. Neither the sums nor the lexical list
establish transitive helper closure. `local-envelope.json` is the retained
result; it includes the assumptions/omissions and bounded arithmetic examples.
`representative-inputs.json` supplies hash-pinned current sample sources and
manually reviewed syntax counters. The same regeneration derives actual lexical,
scanner and parser inputs for those five programs and applies the22 selected
native table checks plus the parser's two auxiliary tables and loop serial,
conditional on the documented invocation/path premise.
The source/line/selected-name join also checks Source_File, Instances and
SFN_Patterns backing. The fixed vector now adds the two controlled GPR naming
pragmas absent from the direct compiler capture; GPR's additional map/path/
switch storage remains open and explicitly excluded.
The sources all pass those selected checks; these are not complete capacity or
admission results. Arithmetic fixtures remain separately labelled.
No native compiler, GNATprove or Lean run was performed for this source
derivation. The frozen initial component and first delta received
[independent review](../../../reviews/review-retained-native-cbcd679320.md) and
[delta review](../../../reviews/review-native-delta-26b438ab5c.md), respectively.
Those reviews cover their named commits; later scalar, loop, input and runtime
root additions still require review. Whole-Main composition remains open.

The later `fixed-gcc-prefix-witness/` bundle is a separate executed native
Linux setup capture, stopped before Main translation. It retains four hardware
counter watchpoints and 47,707 changes, with the actual driver-created frontend
environment. `reconcile-gcc-prefix-witness.py` replays that stream without
executing a compiler or prover; `native-gcc-prefix-witness.json` records its
result. Its fixed semantic setup allowances depend on the source read
projection in the research report. Source-varying metadata, individual backing
checks and the remaining native phases are still separate; this is not a
complete capacity rule or a completed compiler run.

`reconcile-ggc-storage.py` verifies ten pinned source files and the retained
selected host header, then checks individual GGC object/page/lookup requests,
active-page index backing and finalizer-vector growth. Its result is
`native-ggc-storage.json`. The concrete prefix substitution uses the existing
event witness; it executes no compiler and imposes no aggregate memory gate.
Later phase event/request bounds and whole native capacity remain open.

`reconcile-null-initial-gimple.py` joins the selected null body through initial
GIMPLE, CF/EH, CFG/root-loop setup and SSA. It verifies 41 complete source
identities and four earlier results, then reconciles 41 additional GGC events
and the separate ordinary-container interface. `native-null-initial-gimple.json`
retains the source/location, shared-pool, later-pass and process remainders.
Independent narrow review replayed and accepted that join; it is not a complete
ordinary lifetime inventory or a capacity rule. No native tool was executed.

`reconcile-null-pass-join.py` joins selected warning, summary and IPA requests,
verifying 52 complete sources and four retained results. Its 14 additional
GGC events bring the known subtotal to 40,086; ordinary containers remain
individual request bounds. It reuses the already closed ranger/out-of-SSA and
bitmap interfaces and closes the GIMPLE ET coexistence input. Independent
source review replayed and accepted this pass interface; metadata, cgraph
lifecycle, collector and process composition remain separate.

`reconcile-null-cgraph-lifecycle.py` then checks 32 complete sources and six
prior inputs. It joins the two outer analysis calls to one Main lowering and
expansion, adds two 104-byte ordinary hash backings and the fixed IFUNC bitmap,
and adds zero GGC events. Independent source review replayed and accepted this
lifecycle interface. Source metadata, collector callbacks and whole-process
composition remain open.

`reconcile-null-source-locations.py` joins the null source/filename/ordinary-map,
GNAT association-array and ad-hoc location interfaces. It checks50 complete
sources and five prior results, adding12GGC events for a known subtotal40,098.
The result retains the actual line/name/node requirements and the delivered
indexed configuration; it does not complete Ada callbacks, collector/process
composition or capacity assurance. No native tool ran.

`reconcile-null-callback-collector.py` applies the fixed float and direct-layout
callback transfers to the actual Ada table backing rules and substitutes40,098
known GGC events into the page/finalizer transfer. It also charges the 104-byte
ordinary scratch backing constructed by the initialized empty value-expression
cache marker. It checks54 complete sources
and eight earlier inputs without rerunning their scripts or native witnesses.
Its result closes the null Ada numeric callback join, while complete generated
root/custom collector callback and process composition remain open.

`reconcile-collector-closure.py` follows registration sinks and selected typed
constructors, checks the full 4,929-file source manifest and generated options
header, and records the 149-type/223-site lexical census. The report supplies
the selected member/destructor and generated/custom-marker arguments. The
selected null collector adds no GGC events and retains the existing 104-byte
ordinary cache-marker scratch; the known subtotal remains 40,098. Whole-process
setup, ordinary library storage and teardown remain open. No native tool ran.

### Process-shell buffers and explicit cleanup

`process-shell-inputs.json`, `reconcile-process-shell.py` and
`native-process-shell.json` pin/replay55 GCC/Ada sources, seven earlier records
and the installed generated options header. They join the current indexed
argument count with the two proposed native options, correct the historical
config/map option-prefix bound from P+7 to P+8, price selected argument and
diagnostic startup buffers, and close the explicit successful cleanup path at
zero GGC events/ordinary requests. Static process finalization, host-library
buffers and remaining fixed startup managers stay separate. The research
section supplies the selected source paths and layout argument; anchors alone
do not prove reachability. Replay without compiler/prover execution:

```sh
python3 docs/evidence/unbounded-programs/retained-native-expansion-20261017/reconcile-process-shell.py \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --options-header /path/to/pinned/plugin/include/options.h \
  --output /tmp/native-process-shell.json
```

### Fixed startup registry and coverage buffers

`startup-registry-inputs.json`, `reconcile-startup-registry.py` and
`native-startup-registry.json` pin192 sources and two earlier records. The
replay inventories394 generated pass instances/304 factories, their constructors,
clones, fields and parameter setters; derives registry/map/ID/name requests;
and prices unconditional coverage/getpwd caller-owned buffers. The research
section supplies the selected-branch and layout argument. Largest fixed
ordinary request is65,536 bytes; no GGC event is added. This component does not
close the remaining GCC-owned startup/static-exit join. Standard-library and
OS implementation internals are the existing boundary, not a new prerequisite.

```sh
python3 docs/evidence/unbounded-programs/retained-native-expansion-20261017/reconcile-startup-registry.py \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --plugin-include /path/to/pinned/plugin/include \
  --cxx-include /path/to/pinned/include/c++/16.1.0 \
  --output /tmp/native-startup-registry.json
```
# Static lifecycle and fixed ordinary prefix transfer

`static-lifecycle-inputs.json` pins46 source/generated/header files, the
installed gnat1 ELF and prior component records. Its complete69-target
destructor disposition table joins the actual57 GCC-owned initializer roots
and94 registration sites. `static-lifecycle-disassembly.txt` retains complete
instruction bytes; `reconcile-static-lifecycle.py` checks them against the ELF,
reconciles the roots/registrations and replays small fixed allocation formulas.
The result is `native-static-lifecycle.json`.

The companion research section explains the successful-prefix transfer for
fixed ordinary startup requests and the explicit variable metadata exclusions.
No ordinary heap total is inferred from GGC bytes. Selected GCC static exit
adds no allocation; the known40,098 GGC subtotal stays unchanged. The packet
does not close the source/invocation descriptor integration or alter admission.
No compiler, prover or debugger was executed. The initial read-only objdump
capture used `-d -C --insn-width=16`; replay invokes no disassembler.
