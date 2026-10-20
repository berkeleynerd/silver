# R58 getcwd/strdup author round

2026-10-20 UTC. Selected author model/effort: GPT-6 Astra / Extra High for
this bounded source/capacity argument. Runtime confirmation and isolated
token/cost telemetry are unavailable. Available clock interval: 23:20:48 to
23:35:15 UTC (14 minutes 27 seconds), including the priority R57 documentation
repair and worktree/source acquisition; this is not isolated inference or
native execution time and supports no model-quality comparison.

Objective: replace the named R57 getcwd and two strdup allocation envelopes
with source-sensitive successful-service requested-object bounds and necessary
caller guards. Owned only the new `retained-server-libc-storage.md` note and
this packet, in a separate worktree. Acquisition began at R57 integration
753623d1ce71be87c3ee436fb7f0b3af733434c8; the author worktree was rebased onto
153f5a415d803f57a6d7f0852640c22f858909d4 before its corrected focused check.
That base includes the independently accepted R57 resource-boundary correction.

Result: `B=max(4096,2*C)`, `D=1048624`,
`G_peak=max(P+C+1,2*B+D)`,
`G_cumulative=P+2*B+C+1+floor(C/2)*D`,
`G_return=max(P,B)`, and each `D_strdup=S+1`.
The native signed-max path gives P<=INT_MAX without pretending a historical
page-size observation. P=4096 is exported only as a conditional tighter example.
The packet separately handles failed final shrinking, kernel/fallback ownership,
realloc overlap, one live directory stream and cumulative directory construction.

Source/native relation: the exact retained installed libc equals the libc in
the retained Ubuntu `libc6_2.43-2ubuntu2.4_amd64.deb`. Matching source-package
metadata and full upstream/patch archives are retained. None of the 103 enabled
patches changes the 47 selected source members. Actual installed constructor
control flow and allocation operands corroborate the source argument. This
is neither a reproducible-build proof nor a historical-server loaded-library
observation. No signature verification is claimed.

Material finding and rework: the first new checker failed at the generic
recurrence's `used<=capacity` assertion. Unrestricted component examples exposed
that a=u=n=4096 would allocate 8192 but need 8193 bytes, including the slash.
The note now requires selected ancestor components <=4095 (or an attachment
establishing that guard); the corrected checker retains this negative example
and rejects out-of-domain component models. This is a source arithmetic
finding, not a native failure observation. Finite successful examples are not
treated as a universal source proof. The first failed check's duration was not
retained. No successful checker was replayed merely to obtain another result.

Corrected focused check: pass, Linux x86_64, 2.663052 seconds internally
measured; four retained package/source artifacts, 47 source members, 103 enabled
patches, 11 static native bodies / 823 instruction rows / 3,635 bytes,
15 operand witnesses, three server call/PLT/GOT/symbol chains, 1,562 finite
growth/shrink examples, two long-path boundary examples and explicit guard/
negative-case checks. `check-result.json` records this corrected run.
`round.md` and the result are excluded from the frozen-input pins, so adding
them changes no successful-check input. The staged whitespace check passed.

Priority R57 repair was committed separately as
`d82165ee7b874e65f64be8181de21763d83bda7e`, changing only the original R57
note's physical-resource scope and its identity pin. The independent reviewer
accepted that bounded diff without replay; it changes no arithmetic evidence.
R58 preserves the same capacity contract: ordinary allocator/OS behavior and
sufficient physical stack/memory/disk stay trusted, with no new aggregate RAM
admission gate or allocator-internals proof. Source correspondence, finite
representations/stack assumptions, request arithmetic, correctness counters
and correct callers remain required.

Independent R58 review is pending at this author freeze. Historical loaded-libc
attachment and the selected filesystem/caller guard remain explicit interfaces;
complete q is not claimed. No server, target, solver, compiler, proof or capture
run; no predecessor checker replay; no installed-tool/Oracle/admission change.
The parent owns GitHub, issue/board/session-memory updates, integration and
publication. #119/#153 remain incomplete, production #88–#94 unstarted, and
PR #121 draft/unmerged. The global two save-entering callbacks / three saves /
e<=2 allowance is unchanged.
