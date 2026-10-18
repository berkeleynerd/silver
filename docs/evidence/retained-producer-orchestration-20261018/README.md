# Indexed null producer orchestration evidence

Supports the [parent source/read argument](../../research/retained-producer-orchestration.md).

`observations.tar.gz` preserves four isolated native runs, their exact argv,
environment, fixture/tool identities, outputs, managed logs and observer scripts.
The final observer retains all three per-phase GPR configurations and all three
naming files. Earlier incomplete observers and their logs remain included.
`sources.tar.gz` contains eight complete inspected GPR/SPARK source files.
`identity.json` pins both archives, every member and the two reused components.

Run the offline reconciliation:

```sh
python3 docs/evidence/retained-producer-orchestration-20261018/check.py
```

`--source <path>` selects another source in the same null-token family;
`--output <path>` recomputes instead of comparing `result.json`. This invokes
no compiler, prover, debugger or network operation. It checks the retained
execution/configuration inventory and actual-source arithmetic. The linked
record supplies the source argument and fixed-context conditions. A passing
component does not establish whole-toolchain capacity or change admission.
