# Serial application proof policy — 2026-11-21

The host's eight-CPU allocation is enforced by shared managed reservations and
inherited OS affinity. The application driver uses one worker so every compile
fits even a one-worker managed allocation. The pinned Why3 scheduler tries
solvers sequentially in that mode; a successful CVC5 attempt may prevent the
other configured solvers from running.

The regression helper keeps the exact configured prover portfolio and every
per-attempt resource limit. It requires a completed external solver result,
rather than requiring attempts from all three configured solvers. Why3
`<undone/>` entries do not count as completed results. Independent selected
Astra Max review is retained in `serial-scheduling-review.md` (runtime settings
were not independently exposed).

Managed run `20261121T202537-af32fdd0a5e1` passed the final helper controls:
the retained successful serial hello-world report is accepted; wrong step
limits, declaration-only sessions and undone-only sessions are rejected.
The earlier `20261121T195849-f7409996950f` controls predate the result-child
refinement. `check-policy-repair.py` is the original agent-authored fixture
script, relative to the native worktree where it ran; the adjacent logs retain
its managed run identity. The report fixture and copied observations are hashed
in `sha256.json`.

The corrected 92-sample manifest run `20261121T195853-82a961e9e416` passed in
806.234 seconds using the helper at `4582003a5f`. It does not establish a pass
on the later result-child refinement at `8d591cd634`; a fresh final suite is
still required. The earlier manifest run `20261121T195239-ff7d003f92b0` remains
interrupted after the old all-three-solvers assertion failed.

The maximal-expression regression `20261121T191653-cdd01ba978f7` remains failed
at its 1,800-second harness deadline. Its original prover continued after the
parent exited. Observation-only managed run `20261121T194920-1da1c3dafb35`
accounts for that computation, without claiming a successful test, final audit,
build or executable result. At this checkpoint that original proof is still
running; a measured runtime and fresh end-to-end regression remain pending.
