# R64: private printer name-table representation bounds

2026-10-23 UTC, Linux x86_64; #119 / #153. The
[name-table argument](../../research/retained-why-printer-name-tables.md) is
accepted at `6c8af79092bb7ec63b876582f10b94da95a9072b` through
[independent review](../../reviews/review-printer-name-tables-20261023.md),
freeze `8f7d50cb2651c58721bf6df1ef2962de105fa678`.

The bound counts historical names, including virtual candidates at interrupted
cache updates. Forgetting a name does not reset its base's cached suffix; peak
occupancy alone was insufficient. The source argument bounds suffix/search
operands linearly by naming opportunities. It also handles potentially negative
stored table sizes after interrupted removes. The update inside the broad
Not_found catch is a guaranteed hit and cannot resize; insertion-capable
replacements lie outside that catch and abandon the private owner on failure.
The largest five-case name-call bound is 9,861,957,430,423. This is a conservative
mathematical capacity bound, not a measured execution count or runtime forecast.

Review corrected the term-name census: a nullary application can print its name
twice. Ground result types exclude additional type rendering on that branch,
so the existing T+1 allowance remains sufficient. Numeric results did not change.
The single independent audit passed in 1.568308 seconds over fourteen providers,
two archives, eight complete members, twenty-two valid source ranges and all
five arithmetic rows. [check.py](check.py) attaches those exact frozen inputs;
it does not replay the author model/checker, independent audit or earlier checks.

Raw-name length L remains null. Full name-byte/string guards require the complete
signature/context/generated-head source-origin bound. The theorem does not
establish successful naming semantics after caught exceptions, other private
printer owners, Hsattr, formatter/Buffer output, or complete #119 capacity.
Its retained source/native, guarded-publication, ownership and global-budget
premises are explicit in the author note and review. No new per-table exception
allowance, aggregate RAM gate or tool/Oracle/admission change is introduced.

The [R63 checkpoint](../retained-six-owner-round63-20261023/README.md) separately
accepts the complete input set for the six shared owners. Next attach raw names,
attribute/location origins and Hsattr demand/state, then remaining output and
whole-rule coverage/composition/correspondence/comparison/review. #119/#153 remain
open and In progress; production #88–#94 is unstarted and PR #121 draft/unmerged.
Model choices and measured check scope are in [round.json](round.json).
