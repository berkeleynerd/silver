# Unbounded programs scoping evidence (transfer branch, not for merge)

This orphan branch carries two untracked directories retained on the Linux x86_64
sandbox host `claude-silver` at `/home/canto/src/github.com/berkeleynerd/silver/tmp/`,
so that other hosts (for example the macOS reviewer) can inspect them. It is not
part of `main`; do not merge it.

- `tmp/unbounded-programs-research/`: raw research for the Unbounded programs
  scope (workflow wf_93cb95b1-98d, tracks T1-T5), with `MANIFEST.json`
  (expected SHA-256 7848544990640d8609ed9d2b445417b19b432973d5597465cdb3adf705af9a63)
  and `research-results.json`. Files over 2 MB and prover session directories were
  omitted when the evidence was retained; MANIFEST.json lists them.
- `tmp/unbounded-programs-scope-review/`: the pre-publication accuracy, process and
  technical reviews of the scope drafts, the reviewers' notes and the issue drafts.

Restore them at the same paths in a checkout's root:

    git fetch origin evidence/unbounded-programs-scoping
    git archive FETCH_HEAD tmp | tar -x
    shasum -a 256 tmp/unbounded-programs-research/MANIFEST.json   # macOS
    sha256sum tmp/unbounded-programs-research/MANIFEST.json       # Linux

Published scope: docs/unbounded-programs.md on main (PR #95, merge ec82b4e5f2).
