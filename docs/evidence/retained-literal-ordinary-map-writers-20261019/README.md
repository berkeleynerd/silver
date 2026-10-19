# Selected ordinary-map writer closure evidence

Research #119, 2026-10-19, Linux x86-64. The
[source argument](../../research/retained-literal-ordinary-map-writers.md)
excludes later ordinary-map allocation for the selected native Main route.
The accepted preallocation, invocation and frontend evidence is reused unchanged.
No compiler, debugger, solver, build, proof or full test suite is run here.

- `references.json` records symbol and ordinary storage/count references over
  the retained GCC `gcc` and `libcpp` trees, including comments/declarations.
- `inputs.json` pins every matching file, supporting entry-point sources and
  the accepted preallocation/invocation inputs. No hash is a substitute for the
  source reachability argument.
- `check.py` checks identities, exact reference census, self-test section
  bounds, the Ada preallocation-only API sites and retained selected argv.
  It is not a generic call-graph checker or an admission function.
- `check-results.json` records this focused offline run and its inputs. Prior
  successful suites and the fixed frontend runtime census are not repeated.

Replay from the repository root:

```sh
python3 docs/evidence/retained-literal-ordinary-map-writers-20261019/check.py \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source \
  --output /path/to/new-check-results.json
```

The new source conclusion is zero **additional** ordinary-array GGC events;
the accepted three preallocation requests cover this array's lifetime under
the existing selected premises. Review and aggregate lifetime attachment remain
pending. This adds nothing to, and does not complete, the shared/partial native
ledgers, collector, proof or parent. Oracle, tools and production admission
are unchanged. Lead live model/effort and round token/cost measurements are
unavailable; no setting change or model-quality claim is made.
