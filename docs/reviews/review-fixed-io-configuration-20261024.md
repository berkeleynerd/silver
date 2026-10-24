# Independent review: IO report and selected native configuration

2026-10-24 UTC. **No blocking finding in either declared scope.** Accept the
IO source/report specialization and the selected parent/reporter native
configuration operands as two partial #212 results. Their composition still
requires an actual common-path bound. Neither result completes #212/#119,
changes admission or the Oracle, or starts production #88–#94. PR #121 remains
draft and unmerged.

## Exact review inputs

These are separately frozen author targets, not one inferred combined author:

| Result | Exact author commit | Input scope |
| --- | --- | --- |
| IO composition | `0f39a36c1458f7af4f216fce3f9bcde8d8aab123` | Seven files in `docs/evidence/retained-fixed-report-composition-20261024/bodies/`, plus the research-note continuation |
| Native configuration | `9bb63660fd9e29c7b67b359f00acd844f19771cc` | Five files in `docs/evidence/retained-fixed-report-native-inputs-20261024/` |

The review worktree starts at the native commit and cherry-picks the IO author
solely to assemble those inputs; its assembly commit is
`d97a4e10e01feee4dc869bfe9b759a64b8b4d35a`. The
[audit receipt](../evidence/review-fixed-io-configuration-20261024/result.json)
confirms all 13 reviewed files byte-for-byte against their respective original
author commits and records their hashes. It also checks the attached complete
repository/tool-source identities. The accepted specification packet
`057d60cb8e1ff4938bf01667f643d35fc4eb7f0f` and previous review
`7e6879b320f31d25f29a94067e9cabda07bc568b` remain separate, unchanged evidence;
their successful checkers were not replayed.

This resumed bounded review uses the governing Oracle, `AGENTS.md`, assurance,
trusted-boundary and review-bookkeeping requirements already read for the
specification review, with the parent's explicit #119 research authorization
and two-input scope. The harness again reported no live goal. Review ownership
is limited to this report and the matching new evidence directory. No author
file, GitHub issue, production source or launcher was changed.

## IO source and count review

I found no undercount in the three specialized graph domains. The accepted
whole-process A/E=19,837 remains independent of the smaller object, eligible
vertex, metadata and local proof-reference domains.

* The two procedures' objects include Item, Status, Index, the four observation
  objects and File_System, plus two constant surpluses and four scalar capture
  slots. Item and the conservatively charged Written_Bytes bounds facets plus
  synthetic null give F=17. The package's five declarations, one array facet
  and null give F=7. Reference collection filters constant objects without
  variable inputs and removes the quantifier's bound Offset identity; callee
  Parameter_Formal fields do not enlarge the actual variable sets. The larger
  proof/allocation domain is not replaced by these F values.
* The assignment/call/condition/return census matches both current bodies.
  The light-expansion dispatch leaves ordinary assignments and `in` loops
  intact. Range processing can force two bounds of each loop/quantifier;
  the scalar capture route supplies one declaration per bound with checks
  suppressed. Its full-analysis/declaration-context gate excludes additional
  postcondition captures. `Set_Slice_Subtype` at `sem_res.adb:13106–13199`
  creates an index itype and an array subtype; the stated slice slot plus
  surplus slot covers both, in addition to the loop and quantifier index
  positions. These itypes do not create another executing loop or recursive
  cleanup traversal. Static package bounds create no variable captures.
* The constructor rows sum to V=286/241/75. Nonflow pragma vertices are
  separately covered by A_frontend+V and do not silently disappear from
  allocated storage. The previously reviewed clearing/retained-CFG argument
  applies: nonflow nulls do not acquire the preserved original-program flag;
  substantive vertices eligible for dead-code diagnostics are already in V.
* I checked the reduced emitter rows against the `flow.adb` dispatch and
  applicable checker gates. Procedure/function and package branches are kept
  distinct. Explicit Global has no Proof_In, Always_Terminates=False disables
  the procedures' termination-emitting loop, and there is no local abstract
  state. The no-effect helper outside the selected literal regions cannot
  emit: `Warn_On_Subprogram_With_No_Effect` requires absence of user-supplied
  Globals, which both procedures have. No success of sanity, initialization
  or proof is assumed to obtain the bounds.
* Outside-graph required-contract checks retain two attempts. The unfiltered
  incomplete-Global translation loop is separately charged for both IO posts,
  abstract/refined retrieval and duplicate insertion allowance. Their local
  whole-object proof-reference count is bounded by 18; imported callees have
  no pre/postcondition roots, and scalar/array operators add none. This
  supports 146 outside attempts without claiming all proof references fit F.

The independent arithmetic audit separately summed the constructor and
emitter rows: graph flow attempts are 20,724/17,503/2,338, totaling 40,711 with
the outside term. The warning allowance is 16,547+21+17+91+65=16,741. Trace
attempts are 19,570. The full accepted Why-allocation warning allowance is
preserved. The author's earlier mistaken expected vertex totals were already
corrected before this review; no coefficient correction is requested here.

## IO text, schema and metadata review

The narrower text bound is supported by the selected emitter regions and
their helper/exclusion paths. Their largest literal sum is 1,189; source
template/name characters are printable ASCII, with the separately bounded
fixed formatting. The maximum 14 ampersands and one hash permit 50 bytes of
SARIF conversion surplus. Substitution's three names and five location
allowances give raw text 3818+5P, decoded SARIF text 3868+5P, and encoded text
7738+30P including quotes. This depends on the explicitly retained diagnostic
delimiter-free name/path premise. Factor two applies to the fixed/name portion;
arbitrary path bytes retain factor six and the existing UTF-8 premise.

I traced the schema reduction through the whole reached construction path:

1. Both `Error_Msg_Flow` overloads converge on the entity overload. Its
   `Compute_Message`/`Substitute` operations return String, not Message or
   secondary-location metadata. `Create(Msg3)` supplies empty Names and
   No_Location, independent of any markers left in its text.
2. `Print_Regular_Msg` receives an input-only record. It constructs terminal
   copies of the message/continuations; even the oneline Fix secondary-location
   operation is local. It cannot add Names or Secondary_Loc to the record
   later passed to `Add_Json_Msg`. `Add_Default_Name` on terminal/warning paths
   likewise does not mutate the flow record.
3. The selected source has no Annotate suppression. Default response fields
   therefore remain absent; check_tree is `{}`, and the default failed-answer
   object emits only status unknown. Keeping optional empty warning suppression,
   tracefile and msg_id is conservative. The fixed warning templates' previously
   established absence of surviving placeholders suppresses their argument
   arrays, despite the wrapper's native default name. Their empty entity and
   other defaults justify the separate warning shape.

The six metadata identities cover the analyzed package/procedures and the
three imported callees introduced by six caller/callee pairs. Thirty claims
and 42 edges follow the accepted claim transfer. No generated subtype or
operator becomes an extra report identity. Full_Source_Name<=34 and metadata
location depth one apply only to this list, not all frontend or warning
locations. The source CP roots have the declared primitive/name/attribute
domains, giving CP=15,581 and proof text=31,439 through the unchanged provider.
Source-span allocation and failed-fix storage remain separate obligations.

## Useful IO interval

The independent audit reproduced full pretty bytes
**478,273,421 + 1,568,238P**, the retained projected formula and schema
dimensions. All listed guards pass for the stated interval 0<=P<=607,
native max-path<=4096 and page size<=65536. Monotonicity follows the nonnegative
shape coefficients and nondecreasing backing/alignment operations; the audit
checks zero, one, the endpoint and its first successor.

| P | Full pretty bytes | Writer backing operand | Disposition |
| ---: | ---: | ---: | --- |
| 607 | 1,430,193,887 | 2,145,291,022 | All listed guards pass |
| 608 | 1,431,762,125 | 2,147,643,379 | Sufficient unbounded-alignment guard fails |

This is a useful **conditional representability interval**. P is not yet
attached to every actual path role. The failure at 608 is a failed sufficient
guard, not demonstrated native overflow or permission to reject valid Silver.
Native warning chains, initial counters, full storage and the required
five-report aggregate are not discharged by this table.

## Native configuration review

The source declarations and selected installed code support the stated scoped
operands. The historical source's `0.0w` literal is explicitly distinguished
from installed behavior. I independently disassembled both version getters:
each is a straight-line 66-byte function requesting 20 secondary-stack bytes
at alignment four, storing descriptor bounds 1..10 and the ten ASCII bytes
`FSF 16.1.0`, and returning the data/descriptor pair. The 16-byte static symbol
includes six zero padding bytes and is not the return length.

The author's SHF_ALLOC filter correctly excludes nonmapped debug sections
from virtual-address lookup. The independent audit instead maps addresses
through ELF PT_LOAD file ranges, and verifies the same function/data bytes,
complete target hashes, descriptor, allocator call destination and native
signed32 max-path scalar 4096. The source import/export relation attaches that
scalar to ordinary runtime normalization in each named executable.

For the reporter, disassembly confirms the wrapper's call, negative-result
branch and nonnegative return conversion. The audit independently follows
the call to the PLT entry, its GOT slot and the dynamic-symbol relocation,
resolving `getpagesize`. The retained host observation is 4096; I did not
repeat the libc query. Using it remains conditional on the stated ordinary
loader/libc/OS behavior, valid fixed runtime state and stable host configuration.
This is neither a proof about arbitrary interposition/writes nor a portable
service constant.

Accept `version_bytes=10`, `max_path=4096` for the two named parent/reporter
ELFs, and the reporter's recorded `page_size=4096` under those premises. They
fit the IO service conditions, but establish no complete common P and no
GNAT2Why owner attachment. That limitation is preserved in the author packet
and this review.

## Disposition and measurements

Both freezes are accepted in their stated partial scopes with no requested
author correction. Arguments, complete common paths, GNAT2Why and other owner
bindings, warning-chain/initial-counter/storage joins, source-span/failed-fix
storage and full five-report composition remain open. The global e<=2, two
save-entering callbacks, three saves and physical-resource premises are
unchanged.

Reviewer selected **GPT-6 Astra / Extra High**, as explicitly assigned by the
parent; live runtime confirmation and token/cost telemetry are unavailable.
Host: Linux 7.0.14 x86_64; `scripts/dev.py paths` reports linux-x86_64. The one
combined audit passed in 1.524831 seconds. Three targeted objdump reads supported
manual instruction review; the first attempt using an unqualified executable
name failed because objdump was absent from PATH, after which the installed
toolchain executable was used. No selected target, compiler, prover, author or
predecessor checker, native capture or libc query ran in this review. Timing
scope is recorded in the [round record](../evidence/review-fixed-io-configuration-20261024/round.json).
CLI memory was not updated. Parent issue/session-memory integration remains
separate from this review commit.
