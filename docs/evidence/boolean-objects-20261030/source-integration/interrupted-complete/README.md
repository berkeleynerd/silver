# Interrupted repaired complete Lean check

Run `20261030T190042-c50bf05fd9bc` began its build at 19:00:54 UTC on
2026-10-30. The host boot time is 19:37 UTC. On continuation, the run had no
live process, held lease or terminal event, so the managed ledger classified
it as interrupted. Its exact stop time and exit code are unknown; no success
is claimed.

`events.jsonl`, `runner.log`, `lean-proof.log` and `launch.json` preserve the
run's records before replacement validation. `interruption.json` records the
observation and confirms that all 687 captured source inputs and both tool
hashes match implementation/proof target `b6aeb9f978`. The files were copied
by the lead; the interruption summary is agent-authored, not a runner result.

Replacement run `20261030T194116-3d6d1353e52b` reuses the existing Lake
workspace and completed objects, with unchanged inputs, one worker, one
thread and the same 24 GiB threshold. No clean build or independent kernel
replay was requested. A complete source/module/axiom audit remains required.
