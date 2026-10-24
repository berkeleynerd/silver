# Incoming producer report evidence

Offline source and arithmetic evidence for
[the incoming-state argument](../../research/retained-producer-report-incoming.md),
research #119 and #193. This packet covers the state already present at the
phase-2 Why-response cut. It does not bound the response or final report by
itself and does not reset any process-wide counter or rounding allowance.

Run from the repository root:

```sh
python3 docs/evidence/retained-producer-report-incoming-20261024/check.py
```

The successful check reports 113 flow calls, 60 warning calls, 25 error calls,
nine assumption-pool conversion calls and one message-ID caller. Its literal
calculation gives `C_flow=5288`, `Q_at=2`, and a maximum raw warning text of
192 characters. `result.json` contains the caller locations, per-source
identities, literal census and explicitly noncertifying orientation examples.
`source-excerpts.md` is generated from the same pinned sources.

SPARK revision `42554fc241fcd1fdf08d3a2feccb3f86912acbc0` is retained in
`../unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz`
(SHA-256 `f2e7dd7bbef086a36ddf97f9bd3bd669ca895fcc28e3ac23ffe0c9f85fc5d952`).
The eight complete GCC files in `gcc-sources.tar.gz` are from revision
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; the check verifies each against the
earlier complete frontend-source manifest. `identity.json` records the GCC
archive identity, starting commit, and exact six local interface/body hashes.
The check rejects changed local inputs rather than silently adopting them.

The script verifies source identity, lexical caller coverage, literal sums,
and focused integer/counter models. Those models exercise deduplication order,
same-location distinct messages, trace writes before deduplication, fixed
global-domain closure, compressed initialization keys and combined incoming
plus suffix counter overflow. They do not execute the native implementation.
Ada reachability, selected-source exclusions and the constructor/loop bounds
are the companion document's manual argument and independent review; a lexical
census does not establish them. The generic null arithmetic example is not a
replacement for the earlier tighter null-source bound.

No compiler, prover, provider or native validation ran for this packet.
Source-to-installed-binary correspondence, physical RAM/stack/disk availability
and external faithful behavior retain their existing status. Each size and
index still requires its own representability guard; aggregate resource
estimates are not new admission gates.
