# Selected private-printer control review

2026-10-20 UTC; #119 / #153. **Accepted** at author freeze
`631cfc8acbb397f91d1ac67d2a005194055fe756`, based on
`795b52bebde77d2d35533d5ff94c0894ab836afa`. No material defect or required repair
was identified. The acceptance covers the conditional private-printer
preservation and finite traversal result; it establishes neither complete
save capacity nor external-service progress or physical sufficiency.

Selected reviewer setting: GPT-6 Astra / Extra High, explicitly assigned by
the lead. Runtime model/effort confirmation and individual token/cost telemetry
were unavailable. Observed review start was 14:32:50 UTC; semantic review
completed at 14:37:26 UTC, an elapsed 276 seconds. The reviewer used a separate
Linux x86_64 worktree and owns only this report. The lead retains integration,
issues, durable memory and publication. Prior allocation/channel review work
was reused as accepted evidence; the reviewer did not author this new packet.

Exact review inputs are [the research argument](../research/retained-why-save-printer-control.md)
and all 12 files in [its evidence packet](../evidence/retained-why-save-printer-control-20261020/README.md),
including the transfer, checker, source/exception census, retained native
bodies, inspected native control facts, imported identities and five-case
results. The 13-file author change adds only that note and packet. The reviewer
also inspected the relevant retained Why3 Ident/Termcode/Hashtbl source and
native bodies, source `gnat_main.ml:298`, the exposed Termcode interface,
`runtime/fail_nat.c:63` and `runtime/signals.c:201,260,295`, and the inherited
ordinary-ending, pending/native-owner and initial-state contracts. The source
identities remain Why3 `9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml
`8eb41f72ded84df884c3671734c947f612091f84`; the installed ELF SHA256 is
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.

The governing criteria are Oracle 7–9, 13, 21 and 25, the source/native
live-value relation, and the distinction between caller reasoning and trusted
external-service semantics. The following challenges were resolved:

- **First replacement and surviving state.** A normal original-key Hstr.find
  establishes membership before fetch. Fetch has no mutation of the private
  table; the selected identity sanitizers, immutable keys/tags, fresh nested
  printers and preserved native/pending owners exclude an intervening writer.
  A caught Not_found before the first replacement skips that replacement.
  Every reached first replacement therefore follows replace_bucket's found
  arm. It changes only an equal key and a bounded integer payload. An
  interruption between the stores preserves placement, chain topology and
  size; the caught fallback then performs an existing-key replacement with
  zero. This proof does not assume atomicity of the two stores or roll back
  a partially completed update. The native found branch at `0x983094` reaches
  the return at `0x983130` without insertion or resize.

- **Receiving catches and abandonment.** The final Hstr.replace lies after
  find_unique's trap; Hid.replace lies in id_unique's miss handler, outside
  that handler's protected expression. ident_v5 similarly protects only
  Mid.find. Native trap/handler control agrees with the source, including
  `0x56d964`, `0x56d980`, `0x56d9c6`, `0x56de1e` and `0x7ea619`.
  An OCaml handler cannot consume a failure raised by its own body. The only
  enclosing receiver that can advance to another proposition with this same
  printer is do_d's ShapeTooLong catch; other escaping exceptions discard the
  traversal. A higher application catch does not resume the discarded owner.

- **Private exception producer closure.** The four retained ShapeTooLong
  references identify one private declaration, its sole Shape.check producer
  and the legacy/do_d catches. The interface exports neither Shape nor this
  constructor. Every selected shape-check call is under its nearest shape
  catch. The temporary constant/decoder formatter outputs write Buffers and
  cannot call Shape.check inside a table mutation. The accepted collector,
  preemption and exit owners introduce no producer of this constructor;
  Debug has no registered statistics callbacks, and standard flush owners do
  not gain the printer or private exception. A signal save uses its own shape
  catches and cannot be interrupted by another SIGINT save under the retained
  mask contract. These are selected-owner conclusions, not a claim that an
  arbitrary callback or primitive error is impossible.

- **Pending actions while raising.** caml_raise processes pending actions
  before unwinding, so an allocation error can enter a callback and its
  exception can replace the original. The proof tolerates that route. A
  nested shape raise is caught inside that save, while its escaping save/exit
  failure does not manufacture ShapeTooLong. Returning pending work leaves
  the current raised exception; failing pending work replaces it with the
  callback result. No private shape exception is deferred for delivery in a
  later mutation. The save-and-exit callback itself never returns normally to
  the interrupted operation. Thus an interrupted potentially inserting
  replacement cannot reach the printer-reusing ShapeTooLong continuation.

- **From-valid rehash and scans.** Creation supplies disjoint valid chains
  with stable placement. Successful in-place rehash saves each cell's next
  before linking a prior tail. Capacity doubling partitions each old bucket
  into two new indices, disjoint from other old buckets' destinations; links
  go forward in the original order. Hence each cell is visited once even in
  an abandoned prefix, and final tail cleanup restores disjoint valid chains.
  The preceding abandonment argument excludes reuse of an interrupted
  insertion/resize, without applying this lemma to a malformed input table.
  Only one indices insertion site and one values insertion site occur per
  entry, so each table has at most P bindings and each lookup/membership/
  replacement scan visits at most P cells. The capacity/resize thresholds
  are 2048/zero through P=4096 and 4096/one for the two larger retained cases;
  the count includes a final abandoned resize attempt.

- **Earlier bounds and interval composition.** At call k, indices has at
  most k-1 keys, stronger than the previous 2(k-1) allowance. Positive decimal
  and quote suffixes are individually injective and mutually disjoint for a
  fixed base name, including decoder-family changes. Advance consumes
  distinct occupied candidates; retreat strictly decreases a positive index.
  Caught Not_found selects a fallback rather than restarting fetch. Partial
  first updates retain bounded payloads. The earlier Q=P(P+1),
  S=P*(Q+2P+4), successor/string guards and larger allocation charges remain
  valid. The new client bound 5P+S and bucket-visit bound P*(8P+S) include
  all replacement sites and conservatively charged redistribution prefixes.
  There is one interval-global e<=2 escaping signal-save exception budget and
  r<=3 save-entry bound, with no renewal at a printer, root or proposition.
  Consuming one callback exception at an inner catch cannot also spend it at
  an outer catch; ordinary source misses/sentinels are distinct events.

The focused checker ran **once**, without writing author artifacts:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-why-save-printer-control-20261020/check.py
```

It passed five cases, 18 exact source excerpts, all four exception references,
21 retained native bodies / 6,528 instruction bytes, and 11 native control
facts; its reported elapsed time was 0.398429347 seconds. Missing-premise,
threshold, integer-guard and exhausted global-exception-ledger checks passed.
These checks bind extraction, arithmetic, identities and native instruction
bytes; the preservation/producer induction remains inspected reasoning, not
a machine-proved OCaml semantics or native-refinement theorem.

Usable exports remain null without all named source/native, selected-input,
owner-configuration, global-protocol and primitive-outcome premises. The result
does not prove unique shape meanings, arbitrary printer clients, service
termination, physical resources, complete stack or complete save/pipeline
capacity. It supplies a standalone control interface for subsequent stack
composition; this review does not accept an unfinished sibling stack packet.
No new native execution, capture, disassembly, source fetch, proof/solver run,
predecessor replay or duplicate successful check occurred. No GitHub or CLI
memory write was made. The child harness goal was null; no goal status changed.
