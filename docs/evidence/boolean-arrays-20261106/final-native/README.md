# Complete Boolean-array native checkpoint — 2026-11-07

Full native audit `20261107T065643-5c23478ef04b` passed at 13:35:16 UTC on
Linux x86-64, followed by ordinary build `20261107T133600-c3cee7a3d07c` at
13:36:14 UTC. The audited implementation is `ce97ede446`; the native checkout
had no tracked changes. The [record](record.json), [build result](build-result.json)
and [provenance](proof-provenance.json) retain exact inputs and commands.

The strict audit passed **17,681 checks: 1,513 flow and 16,168 proof**, across
76 units and 1,112 owned entities. All retained flow/proof records are
informational, with no justified or suppressed obligation. The raw report
inventory also includes imported entities (2,266 total); it is not the owned-entity
census. The original declaration assertion and the repaired Primary/Relation
obligations passed in this complete run.

The audit used four workers, forced full analysis (`-f`), unchanged normal proof
limits and the retained ordinary proof cache. It took **23,909.634 seconds**;
this is not a cold run. The ordinary four-worker build passed in **9.156 seconds**.
[Input comparison](input-comparison.json) records 144 selected feature/native
inputs and complete source/script inventories; all 2,586 native proof inputs
remained unchanged after the build. Final compiler and Image-adapter hashes,
installation-specific configuration and tool routing are retained in the build
result and provenance. Final behavioral-result applicability is assessed in the
[closing review](../../../reviews/review-boolean-arrays-delivery-20261107.md).

The compressed report and managed-run archives retain full reports, commands,
phase outcomes and logs. `artifact-inventory.json` binds the original 21 retained
machine-produced or retention-helper artifacts; this later explanatory README
and the inventory itself are outside that list. The earlier 143 producer/stack
observation files keep their original source and binary scope under
[observations](observations/scope.json). Fresh ordinary-build DWARF record sizes
match those earlier observations; the retained `.su` file is historical and
establishes no final fixed-frame or universal stack bound.

Native implementation and retention selected GPT-6.1 Sol / Extra High. Runtime
setting confirmation and token/cost measurements were unavailable. No extra
native proof, build or application test was run to prepare this packet. Earlier
failed/interrupted runs remain retained with their actual outcomes.
