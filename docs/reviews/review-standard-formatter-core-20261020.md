# Interrupted standard formatter core review

2026-10-20 UTC; #119 / #153. **Accepted at its stated conditional core scope**
at author freeze `1d55bd7b334f320ee13dc7674f14f3111a58f8b7`, based on
`ed4061e10245939a893507d10153562077996e67`. No material defect or required
repair was identified. The result supplies cumulative arithmetic, linked
structure, object-request and offered-output bounds for interrupted use of
the two standard formatters. It requires their initial constructor dynamic
states and one whole-interval prospective B/E budget; neither input is
established by this packet or this review. Actual joined exports remain null.

Selected reviewer setting: GPT-6 Astra / Extra High, explicitly assigned by
the lead. Runtime model/effort confirmation and individual token/cost telemetry
were unavailable. Observed review start was 16:22:59 UTC; semantic review and
the comparison check were complete at 16:28:56 UTC, an elapsed 357 seconds.
This interval excludes final report and commit preparation. The reviewer used
a separate Linux x86_64 worktree and owns only this report. The lead retains
integration, shared records, issues, memory and publication. The reviewer did
not author the packet.

Exact inputs are the [research argument](../research/retained-why-standard-formatter-core.md)
and all nine files in its [evidence packet](../evidence/retained-why-standard-formatter-core-20261020/README.md):
README, checker, inputs, transfer interface, source witnesses, native bodies,
native control inventory, result and round record. Review included all 26
source excerpts, the arithmetic interface/checker, and the critical native
queue/stack, core mutation, annotation-parser, signal-handler and runtime
exception-control bodies. The accepted
[standard control review](review-standard-formatter-control-20261020.md),
[ordinary-ending argument](../research/retained-why-ordinary-ending-control.md)
and [private allocation partition](../research/retained-why-save-format-allocation.md)
were reused at their established scopes. Their checkers were not replayed.
The separate initial-state lane was not an input to this acceptance.

Why3 remains `9390baf120ef260547dfa14f08e11c890b203d9c`; OCaml remains
`8eb41f72ded84df884c3671734c947f612091f84`. Installed ELF SHA256 is
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`;
retained disassembly SHA256 is
`f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5`.
The packet identifies its retained source archives and provider inputs.
Oracle 7–9, 13, 21 and 25 govern this review. Installed-byte agreement
corroborates the source argument under the selected external behavior relation;
it is not a full source/native refinement or historical-build identity proof.

The critical challenges were resolved as follows:

- **Mutation followed by normal return is excluded at the required boundary.**
  The inherited returning runtime clients do not mutate these roots. GNAT's
  mutating SIGINT callback calls save and exit outside its signal-setter catch.
  Successful exit is terminal; failures propagate through the runtime exception
  path. The native handler removes its trap before save at 0x52e6fb and the
  exit tail call at 0x52e709. Selected Format, Queue/Stack, output and JSON
  operations do not recover locally. Channel pending-action handling unlocks
  before dispatch and raises instead of taking the ordinary relock/return
  continuation on exception. The annotation parser's Failure trap protects
  substring/integer conversion, after private compute_tag and before standard
  pp_open_box_gen; its handler raises outside the trap. It cannot restore a
  suspended dirty standard-core frame. Higher callers may catch and start new
  events, which must consume the same cumulative budget.

- **Partial publication does not require coherent counters.** Queue.add
  allocates before reading last and only links an older cell to a new cell.
  First moves to nil, a new cell or its current successor. Partial clear/add
  can detach last or lose a suffix, but cannot create a cycle or restore a
  removed first. Queue.take publishes removal before returning the token;
  advance_left calls it at 0x98790b before formatting at 0x98792f. Consequently
  an output failure cannot cause the core to replay that token. Stack tails
  are immutable, and the no-stale-return premise prevents delayed publication
  of an old local tail. Stack.pop_opt publishes its tail and updates its count
  before allocating Some at 0x9641c5. The proof correctly bounds linked lists
  separately from count fields and permits empty scan stacks after failed reset.

- **Abandoned closes are charged independently of completed closes.** A close
  enqueues its end and calls set_size twice before decrementing depth at
  0x987d87. Completed effective closes consume user-open credits; reset only
  discards credits and its system open goes from zero to one. An incomplete
  close consumes its abandoned direct-close or flush event, with at most one
  such close per event because its loop cannot recover locally. Thus
  C<=O+D+F<=E remains valid despite repeated end tokens. Direct insertions,
  closes, reset system boxes and the two initial system tokens fit I=3E+2;
  set_size calls fit 3E, sentinel attempts fit 4E+2, and the stated conservative
  linked-length, count and depth bounds allow partial updates.

- **The old fresh-state invariant is not reused.** Flush stores P=1000000010
  at 0x988242 before the allocating drain, and resets only afterward. A failed
  drain can therefore leave right_total=P for later additions. With L=B+E,
  right lies in [1,P+L], left in [1,1+L], and their difference in [-L,P+L-1].
  A set_size write can precede an abandoned pop; permitting up to 3E additions
  to the same entry gives the conservative [-T,S] range, where T=P+L+1 and
  S=(3E+1)T. The sentinel is not a begin/break entry, and text sizes remain
  actual immutable lengths. Negative unknown sizes map to P for formatting;
  dirty begin/break sizes affect comparisons, not arbitrary text subtraction.
  Space, width and clamped indentation bounds follow from cumulative text/break
  lengths and fixed zero offsets. The three guards cover the selected integer
  operations, including intermediate comparisons and dirty count updates.
  On an uninterrupted flush, P-left>=78 drains each remaining unknown token.
  This establishes neither rollback nor successful physical delivery.

- **The request coefficient is supported by attempted-work counts.**
  Independently checking the reused partition gives
  144I+48I+48I+144I+32I+160I+64I=640I requested OCaml bytes.
  The 5I top and 4I pop allowances cover scan updates and processed tokens;
  removing iterations plus one terminal/failed peek per advance run fit 2I.
  A sentinel group costs 80 bytes, and 4E+2<=2I. Allocations are charged before
  publication and no reclamation credit is taken. Existing formatter/channel
  objects remain A_pre; the two entry-token allowances make the new-request
  bound conservative without treating initial objects as newly allocated.

- **Output is counted once per removed token, including dirty reset boxes.**
  Text contributes at most B offered bytes. Processed user/system begins,
  breaks and forced newlines number at most E+2 and each contributes at most
  a newline plus 68 blanks. Each flush can contribute a final newline and a
  reset system box; these are both charged. Default blanks need at most one
  string-output call at the permitted widths. The stderr wrapper adds one
  flush per newline and no byte. The resulting aggregate bounds
  B+70(E+2) bytes, 4(E+2) core fields and 6(E+2) channel leaves therefore cover
  prefixes and later caller repetitions when those repetitions are in B/E.
  Channel-internal retry work is not included.

- **The interface does not turn assumptions into observed results.** It requires
  explicit premise booleans and arithmetic guards before exporting conditional
  bounds. The committed result leaves actual retained-case B/E, joined core
  bounds, A_pre, R and native-stack joins null. Finite arithmetic partitions
  check coefficient inequalities; they do not establish the source induction.
  The global limit of two save-entering callbacks, three saves and e<=2 is
  never renewed. The once-gated standard exit hook contributes at most two
  flush events across the interval, while every other direct flush still
  consumes E. The initial-state premise requires a separate accepted join;
  acceptance here does not supply it.

The focused checker ran **once**, in comparison mode without --write:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-why-standard-formatter-core-20261020/check.py
```

It passed the input identities, regenerated-product comparisons, 26 source
excerpts, 56 native bodies / 9248 instruction bytes, missing-premise and guard
checks, and 20475 arithmetic partitions. It reported 1.83893490400078 seconds;
the reviewer measured 1.9050322270049946 seconds around the subprocess,
16:28:43.277689–16:28:45.182810 UTC. Git status and diff remained empty after
the check. The author round record and all generated evidence were unchanged.

No target, capture, disassembler, source fetch, solver/Lean run, predecessor
checker or duplicate successful check ran. No Oracle, language, production,
tool-pin, shared record, GitHub or CLI memory change was made. The child harness
goal was null and no goal status changed. JSON escape/annotation/scalar objects,
caller and exception storage, runtime services, native stack and physical
sufficiency remain separate obligations. #119 / #153 remain incomplete;
production #88–#94 remains unstarted and PR #121 remains draft/unmerged.
Complete formatter, save, exit or pipeline capacity is not established.
