# Standalone raw scalar constraint inventory

Authorized repair of [#428](https://github.com/berkeleynerd/silver/issues/428),
discovered during the complete-obligation review for
[#416](https://github.com/berkeleynerd/silver/issues/416), 2026-11-28.
This stream owns `PredicateScalarHeaderInventory.lean`, the standalone joins in
`Current.lean` and `PredicateCorrespondence.lean`, and this evidence packet.
It reuses the unchanged `ApplicationPackageOriginalScalarHeaders.lean` helper
from `a568b637c2c91fd9ee8b59f65acc51a3acdac706` (local dependency cherry-pick
`f991090695`). The lead owns the final integration, documentation and publication.

## Finding and scope

The inherited standalone proof already establishes raw inline Integer endpoint
**safety**: `ScalarConstraintAt.evaluated`,
`scalar_declaration_source_bounds`, and `Predicate.meaning_scalar_source_bounds`
retain the original endpoint readings and their safe evaluations. This review
does not establish an unsafe admitted program or a native proof failure.

The modeled obligation inventory was incomplete. `ScalarDeclarationChecksAt`
retains raw initializer RHS arithmetic, while the normalized
`Integer.Declaration` retains the resulting interval rather than the arithmetic
written in its inline `range`. `Predicate.Program.checks` consequently omitted
the raw endpoint expressions for Main objects and local callable objects.
`Predicate.Check.Refines` requires equality for scalar obligations, so unrelated
existing scalar schemas cannot cover the omitted arithmetic. The documented
external generation/static-elimination premise does not itself supply those
missing source schemas. This distinction is material to the complete modeled
inventory, despite the existing semantic safety theorem.

## Repair

`Predicate.ScalarHeaders.TopTokensAt` and `CallableTokensAt` follow the complete
original shell histories. At declaration tokens they reuse the previously
reviewed `TopHeadersAt` and `CallableHeadersAt` inventories. These retain each
original declaration's incoming scalar and array scope, low/high expression
order, and all local function/procedure definitions, including unused ones.
The top-level and callable projections share the selected original shell and
initial/final parser states. `Inventory.SourceAt` has no added safety, checker
or discharge field.

`source_inventory` constructs both complete source projections from
`Predicate.SourceMeaning` and separately derives their arithmetic discharge.
The proof-level `inventory` uses `Classical.choose` on that proved existence;
`inventory_source` and `inventory_discharge` expose the two conclusions. This
finite mathematical inventory is not compiler code, a new authoring format,
an admission condition or an assurance fact supplied by a program author.

`Current.checks source program` appends the selected original header obligations
to the existing normalized checks; `Current.obligations` uses the same source.
The universal fragment/discharge proofs cover the combined list, and
`admitted_assurance`, `every_meaning_assured` and the executable correspondence
conclusion expose its `ScalarHeaderSource` relation. `Tools.generate`,
`generationFaithful`, the modeled tool witness, and the pipeline retain that
same source, so emitted scalar obligations refine the exact combined list.
Generation completion is needed only for admitted `SourceMeaning` pairs.

The normalized `Predicate.Program`, admission and runtime behavior are unchanged.
The existing `automaticDischarge` remains its executable uniform certificate;
the source-specific combined list has the separate universal finite-step
discharge theorem. Faithful and complete GNATprove generation, applicable static
elimination and external solver completion remain the documented tool premises;
this repair does not verify the external tools or predict their work.

## Validation

The host is Linux x86-64. The assigned CPU mask 4–5 yields automatic two Lake
workers and two threads per process; each Lean process has an 8192 MiB threshold.
No manual worker/thread reduction was requested. Managed summaries were read
before validation, and no shared/native job was modified.

Helper focus `20261128T052017-3302987d6c6f` passed with Lean 4.34.1 and a fresh
29,131-declaration foundation axiom audit. All 1,752 captured source inputs
matched immediately after the run; the helper also matched its compiled
workspace copy. The command was:

```sh
taskset -c 4,5 python3 scripts/check_lean.py \
  --target Silver.PredicateScalarHeaderInventory --memory-mb 8192 \
  --task packages-428-standalone-scalar-headers
```

The first helper draft, `20261128T051931-c157b3b70a3e`, failed on the namespace of
`Compose.StepAt` and a deprecated simplification lemma. Correcting the reference
and using `dite_eq_left` fixed those elaboration errors without changing the
contract, inventory or resource settings. Its failed log and input mismatches
are retained honestly; the failed draft does not represent the final source.

The initial endpoint batch `20261128T052244-e933332b514d` was interrupted after
12.417 seconds of build work when dependency inspection revealed that
`PredicateCorrespondence` reaches the large `OutputBodyCertificate` closure.
It has no successful audit and supplies no endpoint-validation claim. That
target is deferred to the lead's coordinated source-certificate validation;
the narrow standalone target is validated separately.

Endpoint batch `20261128T052345-335ae16c2505` passed `Silver.Current` and
`Silver.PredicateExamples`, including the existing admission/discharge examples,
with a fresh 29,351-declaration audit. All 1,752 captured inputs matched. That
run preceded the final contract adjustment limiting `generationCompletes` to
admitted source/program pairs; the input snapshots preserve that distinction.

Final endpoint focus `20261128T052653-b8a68a5f7d5e` passed `Silver.Current` with a
fresh 29,297-declaration audit after that adjustment. All 1,752 inputs matched,
and the owned sources matched their managed workspace copies. It took 22.745
seconds including setup, with 5.200 seconds for the build and 3.663 seconds for
the audit. The affected complete tool contract, model witness and pipeline
theorems are all in this target. The command was:

```sh
taskset -c 4,5 python3 scripts/check_lean.py --target Silver.Current \
  --memory-mb 8192 --task packages-428-standalone-endpoint
```

The final source hashes are:

| File | SHA256 |
| --- | --- |
| `PredicateScalarHeaderInventory.lean` | `8e125dfc6cabdd4b186cdf9832d4954b6178778e3235732149cec93b4d426083` |
| `Current.lean` | `c5d36ab7d85f6eca2c03caaf9a91e5b81844bd2fa23f4293f4c1d2b002baeacc` |
| `PredicateCorrespondence.lean` | `ee4ba117a88ff3f9202e018aa730b3a155b6e5e82560443488628b1eeba03c8f` |
| Reused `ApplicationPackageOriginalScalarHeaders.lean` | `166bd5eecefeed8513b8a9bf803e4908fd05c45e2f3f9081b9422482604bf243` |

`PredicateCorrespondence` is captured as a source input but is **not validated**
by the successful narrow targets. Its changed executable conclusion, the
authoritative-source closure and independent critical review remain for the
coordinated integration stream. The earlier examples run is also not presented
as a fresh check of the final contract revision. A consumer search found no
other `Current.checks`, `Current.obligations` or `Current.Tools.generate` call
sites requiring edits; `SupportedTools` has a separate unrelated contract.

The bounded implementation and narrow checks are complete. No private proof run
remains, and CPUs 4–5 are released. This handoff does not close #428 or establish
the complete #416 capability checkpoint.

The project-selected policy category is Astra Max for contract and source
correspondence design. Available tools do not independently expose the live
agent's model, effort, token usage or cost, so those actual settings are
unconfirmed. No CLI memory update was performed; the live harness goal was
absent. No native proof, clean replay, complete project validation or publication
is claimed by this bounded stream.
