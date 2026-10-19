# Output-binder assembler completion input

See the [source argument](../../research/retained-literal-binder-assembler.md).
`capture.tar.gz` contains exact source, assembly, objects, command results and
both managed-run records. `inputs.json` pins those bytes and the reviewed
GCC/Binutils source inputs; tool identities describe the retained execution.

Offline replay (no compiler/assembler execution):

```sh
python3 docs/evidence/retained-literal-binder-assembler-20261019/derive.py \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source \
  --gas-root /tmp/silver-backend-compose-20261018/gas-source \
  --output tmp/binder-assembler-replay.json
```

`Context(gcc_root, gas_root).result` exposes the fixed-family source transfer;
the complete native adapter must bind it to the current actual-source binder
and assembler invocation. `numeric(checksum)` is pure boundary arithmetic and
does not recognize a Main program. No supplied success or opaque residual
premise can establish complete native capacity. Independent review is pending.
