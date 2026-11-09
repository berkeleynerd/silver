# Review-response regression workspace — 2026-11-09

Status: installation and compiler build ready; the full test suite has not
started. The lead coordinates its resource allocation with the canonical Lean
checkpoint. No native compiler proof was run in this separate test workspace.

The checkout is `tmp/review-response-regression`, branch
`validation/review-response-regression-20261109`, initially clean at
`6365003968a3631493e60380d71417fdc42233c3`. Source, proof and test inputs remain
unchanged. The sparse checkout includes all root content, Rosetta pages and
references, excluding historical `docs/evidence` except this regression subtree.
The [setup record](setup-state.json) retains actual host and checkout details:
Linux x86_64, 22 allowed CPUs and 65,928,044 KiB total RAM.

Only the integration worktree's idle `.tools` installation was copied with
`cp -a --reflink=auto`. The [copy record](tool-seed.json.gz) compares its 32,390
entries before bootstrap, including 32,310 regular files; source and copy bytes
match, no regular-file inodes are shared, and tool symlinks remain inside the
independent copied tree. No compiler objects, solver cache or proof workspace
was copied. Native and Lean bootstrap both exited 0 using the existing archives;
their [outcomes](bootstrap-outcomes.json), [native log](bootstrap.log.gz) and
[Lean log](bootstrap_lean.log.gz) retain the actual commands and versions.

Managed build `20261109T142937-cd04c79c8452` used two workers while canonical
validation occupied the integration workspace. It passed in 15.166 seconds;
the native-tool phase and actual driver exited 0. The
[events](build-events.jsonl.gz), [native log](build-native.log.gz),
[driver log](build-driver.log.gz) and [readiness record](build-readiness.json)
retain exact inputs, effective command and tool identities. The resulting
`silver` executable SHA-256 is
`eb8bf88fc550d706da7a9baeca8cd641bc2c81f36e8e277747372c58e223d3ba`;
`silver_image_adapter` is
`299ae169e22e36b3ac6cee8cf0e5949d6b27658ea5f066482b53c9ae877eb524`.

The [source comparison](source-input-parity.json.gz) covers all 12,170 tracked
files in `src`, `proof`, `scripts`, `tests`, `catalogue`, `samples`, `rosetta`
and `references`, plus the two root project manifests. Every file matches the
integration input bytes. The generated `silver_build.ads` and
`silver_image_config.ads` differ only in the installation prefix;
`silver_library_sources.ads` is byte-identical. These generated path differences
and the fresh executable identities are recorded separately from source parity.
