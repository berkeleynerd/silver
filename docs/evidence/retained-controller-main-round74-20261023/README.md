# R74: controller ownership and selected Main contracts

2026-10-23 UTC, Linux x86_64; #119 / #153 / #178. This checkpoint integrates
two independently reviewed interfaces with distinct scopes:

- The [controller join](../../research/retained-controller-owner-join.md) derives
  consumed-root, queue, saved/live-call and result-buffer ownership from the
  selected caller transitions. Under the already selected Why-only SIGINT mask
  and published-mutation resource guard, queues/tables/IDs are bounded by
  n=3g and result-buffer physical occurrences by 2n. Orphans and abandoned
  prefixes remain charged. The largest selected backing is 256 buckets; the
  largest cumulative backing allocation is 928 array slots per table.
- The [Main contract tranche](../../research/retained-main-typed-profile.md)
  supplies the five selected API typed postcondition profiles, separate query
  definition/residual trees, actual seven/eleven-key effect families and local
  h/o/v/p. Program-variable/outcome accounting is conditional on the still
  unfinished ordinary Main traversal. It supplies no numeric arbitrary-Main
  U/H and does not complete #178.

The [controller review](../../reviews/review-controller-owner-join-20261023.md)
accepted exact author e5ae9e7122 with 1,081 checks in 1.159796 seconds, plus
98,820 finite arithmetic states. The
[Main review](../../reviews/review-main-typed-profile-20261023.md) accepted
exact author 3040c6736d with 4,342 checks in 1.080748 seconds. Both final
audits passed on their first run. Finite checks support their source arguments;
they are not separate universal proof obligations.

The new [integration check](check.py) passed once in 0.556285 seconds,
binding all 36 frozen author/reviewer files, their retained input identities,
94 unchanged native source pins and the unchanged installed Why binary.
[inputs.json](inputs.json) records exact freezes;
[integration-result.json](integration-result.json) and [round.json](round.json)
retain the identity and cost scope. No successful component/predecessor check,
native target, compiler, solver, capture or proof was replayed.

Main review resolved pre-freeze questions about typed signatures, implicit
clauses, the body-Off exclusion of a runtime state refinement, typed reads and
the retained True precondition. The controller review requested no rework.
No new unresolved finding remains within either accepted tranche.

Next compose the fixed-library interfaces into a complete guarded conjunction
and finish #178's constructor-preserving Main emitter, primitive contracts and
implicit clauses. These do not yet close full native/current-grammar coverage,
checked whole-rule accounting/correspondence, useful-domain comparison or final
review. #119/#153/#178 remain In progress. The estimate remains approximately
85%, low confidence; the integration alone does not justify raising it.
Production #88–#94 stays unstarted and PR #121 stays draft/unmerged.
Oracle, tools, admission, physical-resource premises and the one global e<=2 /
two save-entering callbacks / three saves allowance are unchanged.
