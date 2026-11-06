# B5 / #313 bounded empty-loop identity repair — 2026-11-05

Authorization: parent supplied owner authorization from PR #308 at main
`200e91a892`, and assigned this isolated branch `fix/empty-loop-identities` from
`0d30841795`. This subthread does not amend the Oracle, publish, or update issues.
Selected model/effort: GPT-6.1 Sol / Extra High, as recorded by the lead
assignment. Runtime model/effort were not independently exposed. Token/cost
measurements unavailable. This attribution corrects the scratch handoff wording.

## Change and semantic scope

`Multiply` rejects an empty-operand expression if either factor interval contains
zero. `Modulo`/`Remainder` retain the first divisor-zero rejection, then reject an
empty-operand expression whose divisor interval contains either unit. Remaining
empty expressions retain `Unreachable`; nonempty interval arithmetic and Ada
value semantics are unchanged. Lean keeps the existing soundness/boundedness
arguments, adds explicit unchanged-nonempty and rejected-identity lemmas, and
changes the typed native expression trees and equations together. Trees keep
parenthesized nested conditionals and precedence checks. Root owns source pins,
certificates, current-language/catalogue/docs integration, and the complete
validation checkpoint.

## Bounded pinned-GNAT source argument

Reused the already retained source archive
`docs/evidence/scalar-guard-frontend-20261029/native-source-audit.tar.gz`.
`tmp/gnat-identity-audit.json` rechecks the two actually inspected files against
both SHA256 and Git blob identities in the retained manifest; the fresh Alire
lock selects the same GNAT archive origin/hash. This is upstream release/source
provenance, not independently rebuilt binary-to-source attestation.

Inspected revision: GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`,
GNAT-FSF-builds `0334dd54a2c479faa3dfad47a911373581b11739`.
GNAT archive SHA256:
`9f74f58a827a2ad40dd84c72a413e75ea52888e0d8f7e252fba4d26762402703`.

- `exp_ch4.adb:9959-10007`: integer multiply rewrites either known-zero factor to
  a newly analyzed zero literal; known-one factor rewrites to the other operand.
- `exp_ch4.adb:9809-9859`: modulo may redirect to remainder for equal-sign ranges,
  otherwise a known-one divisor becomes a zero literal.
- `exp_ch4.adb:9868-9927`: modulo's possible negative-unit case can generate an
  if-expression selecting zero, under its extra operand-range conditions.
- `exp_ch4.adb:10558-10621`: remainder's known-one divisor becomes zero; possible
  negative-unit operands generate an if-expression selecting zero. Rejecting
  any possible unit when an operand is empty conservatively blocks both routes,
  without attempting to duplicate the frontend's range heuristics.
- `exp_ch4.adb:7931-7945,8131-8135,10701-10709`: `+0`, `0+`, `/1`, and `-0`
  return an operand, not a new constant; multiply-one does likewise.
- `exp_ch4.adb:9698-9737,10484-10502`: unary minus/plus do not add a
  constant-producing integer identity. The optional minus expansion is `0-X`.
- `sem_eval.adb:1971-1990,2007-2013,7226-7350`: arithmetic folding first tests
  foldability. For nonstatic integer arithmetic, both operands must be
  compile-time-known; the exceptional one-sided cases are Boolean And/Or.
  `Expand_N_Op_Subtract` has only the `X-0` identity, so the tempting `I-I`
  expression is not independently rewritten to a literal by these paths.
- `sem_eval.adb:6161-6219`: the resulting illegal static expression is diagnosed
  even when the enclosing counted loop does not execute. This is why returning
  a computed zero interval (or merely testing GCC syntax) is insufficient.

The membership check is at each recursive arithmetic node, so literal, named,
computed and constant-array zero/unit seeds reach the same interval rule. A
sound nonempty interval containing the frontend's value necessarily contains
that zero/unit; an empty child cannot itself become a known literal via these
identified producer rewrites after the new checks. The rule deliberately
rejects conservatively rather than modelling GNAT's rewritten value.

Scope limit: this is a source-based argument for the identified arithmetic
identity producers in the pinned frontend and current arithmetic grammar,
backed by focused controls. It is not a proof of every frontend rewrite or of
all possible empty-loop compilation behavior. The review's prior 322-case
matrix is historical sampled evidence, not an exhaustive closure proof, and was
not rerun here. B1-B4 and other guards/array-reading behavior remain separately
owned and do not follow from this argument.

## Completed evidence and rework

All native runs are Linux x86_64, freshly bootstrapped at this actual worktree
path: GNAT/GNATprove 16.1.0, Alire 2.1.1, GPRbuild package 26.0.1; Lean 4.34.1.
Original bootstrap `--help` was mistakenly treated as help, but those scripts
actually bootstrap. That original chain completed successfully. A concurrently
started second Lean bootstrap failed during extraction; the first authenticated
installation completed and has the expected distribution marker. No proof or
compiler input was changed while its managed run was active.

- Build: `20261105T085743-85abb8750872`, 2 workers, success (10.330 s).
- Admission regressions: `20261105T085829-a5494c5d077f`, 2 workers, 2 methods
  passed (14.310 s unittest time): 11 zero/unit seed forms x 6 expression
  contexts x 3 loop headers = 198 sources. Both `check` and `compile` return 2,
  source bytes are retained, and compile creates no program workspace. Six
  nonempty controls retain admission.
- Full-route retained control: `20261105T090058-59fe629af086`, exclusive native
  slot with full worker reservation, 1 method passed (11.001 s unittest time).
  Same-source proof, compiler report policy, native build, independent report
  audit and execution pass. Empty-loop body covers Image, String assignment,
  inner-loop bounds, comparison, Boolean assignment, nonstatic sibling, plus
  division by one, mod/rem by two, multiply by one and `I-I`. Output is empty,
  status 0. The first attempt `20261105T085932-98a2c6de8ed2` reached successful
  proof/native build but failed the Python report audit because this test
  incorrectly labelled a String-assignment source `static`; fixed to `assigned`.
- Focused native compiler proof: `20261105T090125-005ff9bca9d1`, 2 workers,
  `dev.py tool -- gnatprove -P ../../../silver.gpr
  --subdirs=explore/empty-loop-folds -u silver_scalars.ads
  -XSILVER_HOST=linux-x86_64`, success, 44 checks. This is exploratory unit
  evidence, not a complete native proof/audit manifest.
- Focused Lean initially failed on a newly added theorem binder because
  `left.isEmpty || right.isEmpty = true` needed parentheses around the Bool
  disjunction. The second run then rejected a redundant `rfl` after `simp`
  had already closed the multiply equation; removed that final step. Third run
  passed both targets and the fresh focused module/axiom audit: 8 modules,
  1,548 declarations, allowed foundations only (`propext`, `Quot.sound`,
  `Classical.choice`), run `20261105T090418-fdbc03e9b012`, build 28.056 s +
  audit 5.487 s, managed duration 44.260 s. The preceding failed runs were
  `20261105T090148-7df05d0796c3` (binder) and
  `20261105T090252-13f9a7ff7a0e` (redundant step).

Parent transparently seeded older stable root `.lake/build` objects (467 older
source modules; 7,472 byte-verified artifact files). Parent manifest:
`tmp/root-cache-seed-20261105/manifest.json` in its integration worktree. No
same-target source claim. The managed Lean runner/Lake must revalidate and
rebuild changed dependencies, with a fresh focused axiom/module audit.

- Existing integer-division admission: `20261105T090525-f2b949dad850`,
  2 workers, all 9 methods passed (3.938 s unittest time). Original empty
  mod/rem-one cases remain rejection assertions, with separate divisor-two
  positive controls.

## Outstanding handoff

Focused Lean passed `Silver.ScalarsNativeEquations` and
`Silver.IntegerExpressions`; the existing integer-division admission tests
passed. Final diff review and `git diff --check` passed. Commit with `Refs #313`. Root integrates language,
catalogue, source pins/certificates and full validation; this branch does not
claim capability completion without that checkpoint. No GitHub writes/push.

Final local implementation commit: `db51e1829e` (`Refs #313`), 8 owned files.
The tracked worktree is clean; untracked `tmp/` preserves the above logs, source
excerpts, identity audit, and this handoff. No CLI memory update was performed.
No full native audit, source-certificate regeneration, complete Lean checkpoint,
full suite, macOS validation, push, merge, or tracker update was performed by this
subthread; final integration remains with the parent.
