# Interrupted attempt-counter continuation packet

Round 29 / 2026-10-20, research #119 / #153. See the
[argument](../../research/retained-why-attempt-counter-continuation.md).

The source result is `increments <= membership-publication events + 1`,
because an abandoned pre-publication constructor cannot resume scheduling.
The accepted conditional membership allowance gives `increments <= K+e+1`.
Fresh counter words from PIDs 17310, 17514, 17631, 17704 and 17869 give later
conditional counter upper values **209, 174, 109, 13 and 10**.

Files:

- `source-excerpts.json` / `source-census.json`: exact retained Why3 and OCaml
  source witnesses; handler bodies and dynamic receiving catches are distinct.
- `inputs.json`: frozen identities of imported evidence, source archives and
  accepted research/review inputs. Capture archives/members are additionally
  checked against the pinned capture manifest.
- `result.json`: fresh captured session record, member identities, existing
  attempt IDs, conditional applications and focused challenge results.
- `transfer.py`: checked arithmetic with explicit missing-premise behavior.
- `check.py`: narrow offline counter projection and checks. It imports accepted
  mutable-state decode/correspondence evidence and does not replay the observer,
  binder or alpha machinery.
- `build_packet.py`: reconstructs source excerpts/census and input identities
  from retained archives; no fetching.
- `round.json`: selected settings, timing, scope and remaining contracts.

From the repository root:

```sh
python3 docs/evidence/retained-why-attempt-counter-continuation-20261020/check.py
git diff --check
```

The default checker verifies the recorded result. `--write` regenerates the
result after intentionally rebuilding the packet. No native/compiler/solver,
proof, capture or old observer/binder/alpha replay was run. There is no new
scheduler/preparation entry envelope or whole-save/pipeline capacity claim.
All displayed upper values remain conditional on the explicitly missing
continued-signal, membership-publication/key-preservation and native-counter
contracts. Numeric headroom is not evidence that allocations succeed.
