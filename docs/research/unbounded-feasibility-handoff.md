# Unbounded programs: research handoff

**Historical handoff.** The subsequent Linux continuation is recorded in the
[feasibility result](unbounded-feasibility-result.md), which supersedes the
unfinished-work status below. This document preserves the transfer-time scope,
access details and evidence; consult the result and live issues for current work.

**Partial research, not a feasibility verdict or implementation checkpoint.**
The owner requested this handoff while #107 and #108 were in progress:
"Let's package up this as a handoff package to another agent with the required access."
Both research issues remain open. No sound source-capacity rule has been
established, and full-domain static-data feasibility remains unresolved.

## Authority and continuation

The owner's research-only "Proceed." is recorded on `main` by
[PR #106](https://github.com/berkeleynerd/silver/pull/106), merge
`66f55f67c053d761c76eb56b0f55ae3717fe95cd`. It authorizes the research in
[#107](https://github.com/berkeleynerd/silver/issues/107), a child of #91, and
[#108](https://github.com/berkeleynerd/silver/issues/108), a child of #93,
including evidence publication and independent review. The handoff transfers
that unfinished research; it does not expand authorization.

**Do not implement #88–#94, adopt membership rules, change the compiler/runtime,
amend the Oracle, or mark either parent complete.** Those packages stay Backlog.
Do not treat a candidate source-derived obstacle as a proved full stop until
its counterevidence and alternatives have been checked. Report any established
full stop to the owner instead of silently choosing a smaller limit.

Read `AGENTS.md`, `oracle.md`, `language.md`, `development.md`, `roadmap.md`,
`docs/session-memory.md`, `docs/planning.md`, `docs/assurance.md`,
`docs/trusted-boundary.md`, the [corrected scope](../unbounded-programs.md),
the [original review](../reviews/review-ec82b4e5f2.md), and the
[repair record](../review-ec82b4e5f2-repairs.md). The original review target is
PR #95 merge `ec82b4e5f2bd1d3001e7117fe09e610d7d69658f`, first parent
`041acd08fb09551ece781c6302cc8b431323703d`; its completing commit is
`d2426c99b4`. Planning repairs were published through PR #105, merge
`cb16b49fb27a0a7e08267cfd6755d554fa2381d6`. Do not reopen that completed pass
by confusing this research with implementation of its specifications.

## Start here

1. Fetch `codex/unbounded-feasibility-research` and inspect its draft PR and
   live issue comments. Use a separate worktree, preserving shared edits and
   existing scratch. Check for a newer claimant before recording continuation
   on #107/#108 and returning their board status to In progress.
2. Read the [source-capacity checkpoint](unbounded-source-capacity.md) and
   [static-data checkpoint](unbounded-static-data.md). Their evidence is under
   `docs/evidence/unbounded-programs/feasibility-20261017/`; verify its manifest.
   Treat both records as claims to challenge, not conclusions to inherit.
3. Determine the actual host and run `python3 scripts/dev.py paths`. The Linux
   repository listed below is at an older commit; select source inputs from
   this branch or verify hashes before borrowing any existing runtime unit.
   Existing installed compiler binaries may be used with recorded identity.
4. Complete the unresolved source reasoning first. Use a new probe only when
   it resolves a named remaining hypothesis. Preserve every successful result
   and do not repeat expensive work merely to obtain fresh timestamps.
5. Compare the most expansive sound rule/representation alternatives, obtain
   independent review, and publish a final recommendation or a precise full
   stop. Then update the scope, affected issues and milestone, recording what
   is derived, observed, proved or still a premise. Do not close #107/#108
   merely because this partial handoff has been published.

## Findings to retain, and conclusions not yet earned

- GNAT source positions are only one budget. The partial audit also identifies
  line-table growth, node/header/slot tables, interned names, String characters,
  numeric-literal temporaries, and physical plus compiler-generated virtual
  source units. No universal per-source-byte coefficient or closed budget vector
  has been established.
- The historical estimate of roughly 1.5 billion Uint **table entries** mixes
  direct encoded values with table references. The relevant table-coded range
  has 100 million values; Udigits is a separate pool. Preserve the original
  research as history and account for the corrected interpretation explicitly.
- Source inspection indicates that the Int-indexed String character table and
  its unsaturated growth arithmetic can obstruct very large constant Strings.
  Tail sharing means cumulative backend constants cannot simply be equated
  with frontend character storage. Finish the Mark/Release and live-value
  analysis and distinguish source-derived growth from observed native behavior.
- Tiny Linux C probes link three Integer'Last-sized zero-fill objects with
  medium and large models; the small model fails. Thus a default small-model
  failure is not an unavoidable Linux language limit. Separate Ada assembly
  probes succeed at 1 MiB under all three models. These are not full large Ada
  builds, proofs, or executions.
- On native macOS, a tiny C zero-fill proxy exposes an ADRP relocation failure;
  the installed Darwin compiler rejects its large code model. This is concrete
  backend evidence, not an admitted Silver counterexample or a universal Mach-O
  aggregate-data bound. GOT indirection/storage alternatives are counterevidence
  that must remain visible.
- No adopted rule, complete frontend capacity argument, universal build
  feasibility proof, or implementation validation follows from these probes.

## Exact remaining hypotheses

For #107, close live String allocation/reclamation and overflow/growth reasoning
against the actual pinned frontend; account for zero-mantissa exponent
temporaries, line-table arithmetic, source-position headroom, generic
instantiation units, and node/name/list allocation histories. Determine whether
a sound source-sensitive accounting rule is tractable and more expansive than
a uniform byte envelope. A checked/instrumented frontend is an alternative to
evaluate, not an authorized implementation. Any changed tool pin, membership
restriction or assurance premise must be explicit.

For #108, integrate those frontend limits before extrapolating backend data.
Inspect the retained Linux Ada assembly for the actual sections/addressing
selected by medium/large models; evaluate linkage/runtime/stack outcomes and
same-source representation alternatives. Darwin evidence is independent and
nonblocking for Linux completion, but any cross-platform claim needs its own
evidence. No giant initialized object is needed merely to rediscover an already
isolated relocation or representation constraint.

## Access and retained workspaces

Linux access was resolved after the earlier question to the owner. From the
originating Mac, `ssh -4 -o BatchMode=yes canto@nix.local` succeeded. The `-4`
avoids an intermittently failing IPv6 route. This uses existing SSH credentials;
none are included in the package. A successor needs its own authorized access
to that host, or may run directly there. Do not reconfigure credentials or the
host merely because a different sandbox cannot connect.

- Linux repository: `/home/canto/src/github.com/berkeleynerd/silver`, observed
  HEAD `041acd08fb09551ece781c6302cc8b431323703d`, tracked clean with untracked
  `tmp/`. Preserve its work and caches.
- Linux compiler: `.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/bin/gcc`
  under that repository. Native identity and hashes are in the evidence.
- Linux raw probe tree: `/tmp/silver-unbounded-feasibility-20261017/static-data/`.
- Mac research worktree:
  `/Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver/tmp/unbounded-planning-corrections`,
  branch `codex/unbounded-feasibility-research`, based on PR #106's merge.
- Mac shared checkout has unrelated tracked edits. Do not reset, clean, stash,
  rebuild, or publish them as part of this research.
- Mac raw research tree: `/tmp/silver-unbounded-feasibility-20261017/`.
  The Linux evidence was copied into its `static-data/linux-retained/` subtree.
- Original retained research:
  [immutable evidence commit](https://github.com/berkeleynerd/silver/tree/0cd253d05b2cb650cc8fca81255e9a711765e16a/tmp).
  Its `MANIFEST.json` SHA-256 is
  `7848544990640d8609ed9d2b445417b19b432973d5597465cdb3adf705af9a63`.
  All 2,154 listed files were rehashed with no mismatch during this pass.
  Recorded omissions remain omissions. The local copy is
  `/tmp/review-ec82-original-evidence/tmp/unbounded-programs-research/`.

The public branch carries compact evidence, exact inputs and the
[raw handoff archive](../evidence/unbounded-programs/feasibility-20261017/raw-handoff.tar.gz).
Its [index](../evidence/unbounded-programs/feasibility-20261017/handoff-index.json)
records the SHA-256 and verified contents. A copy is also available on both
hosts at `/tmp/silver-unbounded-handoff-20261017.tar.gz`. The archive includes
`NEXT_AGENT.md`, a continuation prompt, and `RAW_MANIFEST.json`. A successor can
read the published records without access to the Mac's external drive. Large
assembly outputs omitted from compact evidence remain in the archive and
original scratch; their hashes and relevant excerpts are retained. Archive
documentation is a packaging-time snapshot; the branch's Markdown records and
independent review are the final handoff text.

## Validation cost and side effects

Use static inspection and cheap guarded compiler checks first. No complete or
cold proof runs, Lean rebuilds, kernel replay, full suites, bootstrap, giant
initialized objects or application execution ran in this pass. No further
experiments are required just to accept the handoff. The nine source-capacity
probes and static-data probes ran sequentially, with 512 MiB sampled process
group RSS guards and 30-second per-case wall limits. Static-data probes also
used a 16 MiB per-file limit and disabled core dumps. These are research guards,
not proposed product limits. See each record for the one invalid initial
monitoring attempt and the distinction between sampled RSS and child max-RSS.

Preserve caches, worktrees, raw logs, failed inputs and other-host artifacts.
The only host-access side effect was adding the Linux host's ED25519 key to the
Mac user's known_hosts while establishing the connection; no remote credentials
or configuration changed. Probe outputs were written only to scratch. Research
documents, evidence, issue comments/statuses and the draft handoff PR are the
publication side effects. No harness goal is active; token-usage telemetry and
CLI memory are unavailable, and no CLI memory update is claimed.

Independent review of this package concerns its accuracy and usefulness as a
partial handoff. It is not acceptance of a final feasibility recommendation.
