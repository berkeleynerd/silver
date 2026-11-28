# Why the 30/60-second policy yields 121/241-second process guards

The installed cache-command expansion triggers Why3's allowance for a prover
that is expected to enforce its own timeout. In this configuration the expanded
number is only a cache-key salt, and the selected main solvers have no internal
timeout option. This explains the observed factor of four; it does **not** by
itself explain the whole unit's elapsed time or justify reverting the prepared
60-second policy.

This was established read-only from the installed configuration, live arguments,
limits and binary instructions. No live process was attached, signalled or
restarted; no configuration, tool, source or cache was modified. The already
running canonical 60-second helper check remains the next outcome experiment.

## Installed evidence and trace

Let `V` denote the actual installed directory:

```
/home/canto/src/github.com/berkeleynerd/silver/tmp/packages-416-proof-timeout/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef
```

`V/share/spark/config/gnatprove.conf` has SHA-256
`4ff4651508373959ad0d6834e482b539670e9f6f0ca6b90bb3683fd27d8be6cf`.
For main CVC5, Z3 and Alt-Ergo, and CVC5 counterexamples, `args_time` is empty.
The generated Why3 command nevertheless starts with:

```
spark_memcached_wrapper %t file:<policy-specific-cache> <solver> <solver-arguments> %f
```

The generated 60-second configuration is at
`.silver/linux-x86_64/compiler/obj/focused/97769bfda44bef44/gnatprove/why3.conf`
within that private worktree, SHA-256
`76197f1278a80eeceba08932ffda53a955da4ec77203ada9616b01a3453c0284`.
Both it and the original 30-second configuration are retained below. Actual
CVC5 arguments were `--prenex-quant=none --stats-internal <input.smt2>`;
Z3 uses `-smt2 -st smt.arith.solver=6 <input.smt2>` and Alt-Ergo uses
`--max-split 5 --disable-weaks <input.psmt2>`. No internal wall/CPU timeout
argument appears in these main-prover invocations.

The deployed call chain is:

1. `gnatwhy3` substitutes `%t` and sets `on_timelimit = true` solely because
   that placeholder occurs in the command. Its installed `replace_1917`
   instructions at `0x5ce79c..0x5ce7c3` perform this branch.
2. With `--steps 0`, `adapt_limits_2035` takes the `on_timelimit` branch:
   `outer_limit = 4.0 * configured_limit + 1.0`. Instructions
   `0x5cea10..0x5cea46` read constants `4.0` at `0x9ec810` and `1.0` at
   `0x9ec820`. The separate nonzero-step branch uses `2t + 1`; it is not
   the current proof policy. `call_on_file_inner_3796` calls the adapter at
   `0x5ced4c` and sends the resulting limit to the server at `0x5cee8e`.
3. `why3server`'s `create_process` saves that incoming limit, then at
   `0x4445..0x446e` assigns it to both soft and hard Linux `RLIMIT_CPU`
   values. It launches the wrapper, whose solver child inherits the limit.
4. The installed `spark_memcached_wrapper` reads argument 1 and passes it to
   SHA1 at `0x262e6..0x262ff`. It launches argument 3 as the command, with
   arguments 4 onward, through `GNAT.Expect.Get_Command_Output` at `0x26a9b`.
   The numeric salt is not forwarded as a solver timeout. The installed GNAT
   runtime implementation of that routine waits until process death with
   `Expect (..., Timeout => -1)`; it has no timeout parameter.

| Configured policy value | Observed/derived outer CPU guard per process |
| ---: | ---: |
| 30 s main prover | 121 s, observed |
| 60 s main prover | 241 s, observed |
| 10 s CVC5 counterexample | 41 s, derived from the same command/zero-step path |

The 60-second CVC5 child was observed at 144.1 CPU seconds with limit 241.
The retained Signature success also reports a 106.419-second CVC5 proof under
the nominal 30-second policy. A valid solver result after `t` is not rejected
merely for exceeding `t`; it can be returned before the larger outer guard.

## Reported timeout times are normalized

The same installed `gnatwhy3` contains an additional reporting detail:
`parse_prover_run_1744` compares an unsuccessful/unknown result's reported time
with `0.9 * t - 0.1`. When the matching timeout-classification branch applies,
it sets the answer to `Timeout` and the recorded proof time to **the original
`t`**. The installed instructions are retained at `0x5ce122..0x5ce1cb`, with
constants `0.9` and `0.1` at `0x9ec828`/`0x9ec830`.

Consequently, a `.spark` attempt labelled `Timeout` with `time: 30` can be a
normalized report value, not a measurement of only 30 seconds of actual CPU.
XML sessions omit attempt times entirely. Valid-result times can also originate
from cached prover output. These records cannot establish total fresh CPU
consumption or a cache-hit rate by summing their time fields.

## Scope and retained artifacts

`RLIMIT_CPU` limits an individual process's CPU consumption. It is not a wall
clock limit for a helper, verification condition or complete invocation.
A reported check can split into many goals, use multiple provers and undergo
further transformations/counterexample attempts; scheduling and queue delays
add elapsed time. The formula therefore supplies no per-helper/per-run wall
time bound. It also does not attribute the broad run's hours to the eight
unresolved roots.

Changing `t` changes the wrapper's cache salt as well as the runner's focused
policy directory. Copying a cache directory alone would not establish compatible
cache reuse across 30/60 settings. Both current cache boundaries were preserved.
No timeout tuning or performance experiment was launched for this investigation.

The following packet allows independent inspection without relying on an
upstream branch matching the deployed binaries:

- [Exact identities, paths and instruction addresses](timeout-trace/identities.json).
- [Installed binary disassembly and constants](timeout-trace/installed-disassembly.txt.gz).
- [Installed prover configuration](timeout-trace/installed-gnatprove.conf.gz).
- Generated [30-second](timeout-trace/generated-why3-30.conf.gz) and
  [60-second](timeout-trace/generated-why3-60.conf.gz) configurations.
- [Live argument/limit snapshot](timeout-trace/observed-arguments.json) and
  [earlier actual CPU observation](live-timeout-observation.json).
- [Installed GNAT command-capture implementation](timeout-trace/installed-get-command-output.txt).

The `gnatwhy3`, `why3server` and wrapper binary hashes are respectively
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`,
`143e182d167d3e290c974770d0b84b5f59cf70bf331de5208a36bd650b386a80`, and
`4d05cae7a7a0bd20e2df8fa4a152a90bffd4c8d6d71735be593afcc37ec4ee51`.
Readable upstream excerpts are supplied with URLs/hashes in the identity file;
they are explicitly unpinned references, not a whole-source correspondence
claim for the installed release. The decisive arithmetic, wrapper argument
handling, request path and OS-limit assignment were checked in the installed
binaries themselves.
