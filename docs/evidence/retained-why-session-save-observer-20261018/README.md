# Restricted session-save observer preparation

Research #119, Linux x86_64, 2026-10-18–19. This implements the
[missing-root plan](../retained-why-session-save-capacity-20261018/observer-plan.json)
after the parent's explicit instruction to prepare the observer and offline
fixtures. **No target has been started by this packet.** A coordinated attempt
is a separate next step; numeric `B_binders` and `R` remain unavailable.

The frozen workspace is
`/home/canto/src/github.com/berkeleynerd/silver/tmp/why-session-save-capture-ready-20261018`.
Its launch wrapper, for the parent to run after resource coordination, is:

```sh
python3 /home/canto/src/github.com/berkeleynerd/silver/tmp/why-session-save-capture-ready-20261018/managed.py
```

The complete underlying `scripts/dev.py tool --task '#119' --jobs 1` argv,
including all input pins, is retained in `prepared.json` and
`managed-command.txt`. `harness.tar.gz` retains all prepared files and the empty
temporary directory. `inputs.json` pins it and the packet's sources. The actual
plan has **exactly one input**, enforced by preparation and check assertions.
The unchanged inherited `run.py` docstring still says “Five serial prefix-only
cases”; it is historical text, not the plan's cardinality.

The executable, plugins, input/configuration/driver closure, external-server
selection, environment, arithmetic/resource/thread guards and first driver
preparation/inline stop are inherited with path relocation. The server is
separate, uses `--single-client -j 1`, and no prover request is allowed.
The original printer/prover-call stop guards remain. New break-before-body
guards cover `camlGnat_main__save_session_and_exit_3133` and
`camlWhy3__Session_itp__save_session_4339`, preventing an incidental signal save
from running. No signals are injected, no signal policy is changed, and no
inferior functions are called. The target never continues past the selected
first-inline entry. Native limits remain one worker, 6 GiB address space and
120 seconds; the parent owns the live resource check and launch coordination.

## Persistence and scope

`gdb_adapter.py` joins runtime symbols to the pinned ELF load bias and checks
the retained code prefixes. After the original private-counter capture, it
reads the six prospective root words and flushes each read to both the original
raw-read log and a session-only replay log. Each complete block is flushed
before a typed check. Small root/controller decoding failures are caught so
the original Hsdecl/input capture continues. The original counter, Hsdecl and
logical graph files are saved before deep optional decoding starts. The large
original Python graph is released first.

`session_observer.py` uses a 256-block cache, streams retained blocks, and limits
the graph to one million blocks/edges and 128 MiB of payload. Limits fail with
retained diagnostics; they establish no capacity bound. Complete session tables
preserve bucket order, collisions and duplicate bindings. The forest traversal
preserves repeated visits and detects cycles. Every raw-task value, task chain
and logical declaration graph is retained. Missing raw tasks are recorded as
detached, respecting the existing guard.

The integer-table lookup matches the pinned source, rather than assuming a
generic seeded hash: `wstdlib.ml:16–23` has `Int.hash x = x` and
`Hint = Exthtbl.Make(Int)`; `exthtbl.ml:41–44` includes `Hashtbl.Make`.
OCaml `hashtbl.ml:477–484` makes that functor's hash ignore its seed, while
354–355 uses `hash key land (Array.length data - 1)`. Thus the observer validates
integer-key bucket placement by `key & mask` and preserves the first matching
binding. It does not apply that integer rule to prover or timing tables.
These sources are already pinned by the preceding packet's new and reused
source archives.

Exit/statistics collection follows the source/native-validated link and wrapper
layouts. It retains callback/printer closure words and statistic values;
unknown cases and helper failures remain explicit. A helper failure does not
discard a successful session projection. The helper `complete` flag refers
only to this named root projection; `complete_R` is always false. Formatter
state is retained shallowly, and mutable globals referenced by callback code
still need source analysis. Neither a closure dump nor one observed run proves
the helper registration bound or callback preservation.

`session-observer.json` binds PID, runtime symbols, code checks and identities of
the original process/counter/input/Hsdecl artifacts. `replay.py` checks that
join and reproduces every session read and output file offline. A new retained
graph must be analyzed with that new process's counter and source-bound input
assumptions; it must not be spliced into historical PID 74171.

## Offline checks and remaining work

`checks.json` retains the exact commands, output and measured time. Nine tests
passed, with **0.091 seconds** reported by unittest. They cover shared blocks,
colliding integer keys and duplicate-binding lookup, repeated proof-node visits,
detached tasks, table/forest cycles, diagnostic limits, raw retention before
rejection, helper failure preserving session data, exact sequential read replay,
standalone replay and rejection of a changed core-process file. The final
prepared-harness check passed in **0.40227985799720045 seconds**, checked 205
planned input identities, and verified the minimal probe changes, unchanged run
script, preserved guards, two added save stops and fresh one-input directory.
No successful old graph/counter proof or broad suite was rerun.

The parent may now coordinate one attempt using the frozen command. Afterward,
required work remains: retain and replay the actual bytes; validate the current
session visit/formula certificate; compute fully opened occurrence mass with
delayed substitution; source-bind `R` and preservation across callbacks; and
re-establish the same-process source registration bound. The accepted two-save
result remains conditional on its existing POSIX/dispatcher/producer/mask
premises. This preparation does not complete #119 or any broader capacity claim.
