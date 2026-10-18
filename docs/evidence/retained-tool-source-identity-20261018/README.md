# Retained GNATprove source-identity evidence

Companion to [the source-identity result](../../research/retained-tool-source-identity.md),
collected on Linux x86_64, 2026-10-18, for #119.

`requests.json` lists each read-only GitHub API request and response digest. Raw
responses are retained unchanged, including the HTTP 410 job-log response.
The five decoded `.source` files are checked against their GitHub content blob IDs
and the recipe's untruncated Git tree. `spark2014.anod` is copied unchanged from
the previous toolchain raw-evidence archive and checked against that same tree.
`installed-alire.toml` is an unchanged snapshot of the selected installation's
Alire manifest.

`verify.py` checks these retained relations, reconciles upload timestamps, and
examines only source-identifying metadata in the two installed ELF binaries.
Its narrow ELF/DWARF reader checks line-table field descriptions; it does not
disassemble instructions, establish binary/source equivalence or rebuild tools.
The binary hashes in `results.json` identify the inspected files, and do not
assert a fresh archive-to-installation comparison. The original binary archive
was not downloaded in this task.

From this checkout, rerun the local checks:

```sh
python3 docs/evidence/retained-tool-source-identity-20261018/verify.py \
  --installation /home/canto/src/github.com/berkeleynerd/silver
```

This rewrites `results.json` deterministically when the retained records and
installed inputs are unchanged. It invokes no compiler, prover or network client.
To re-observe a remote endpoint, use `gh api --method GET` with the exact endpoint
in `requests.json`, saving the new response separately: live metadata and log
availability may change. API snapshots establish what was observed, not a
promise of future byte-identical responses.

The complete evidence inventory is `MANIFEST.json`, with raw-byte SHA-256 hashes
and sizes, excluding only the manifest itself. Source identity remains
**unestablished**: no retained record identifies the historical floating SPARK
tarball consumed by the build. The result contains the precise missing link and
keeps it distinct from the verified release/recipe/job identities.
