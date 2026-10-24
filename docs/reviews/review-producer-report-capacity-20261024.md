# Producer/report capacity review

2026-10-24 UTC, independent review for #193 under #119. Selected reviewer:
GPT-6 Astra / Extra High; runtime confirmation and token/cost telemetry are
unavailable. This record separates completed component review from the still
pending integrated producer/report freeze. It does not close #193 or #119.

## Interrupted response provenance: accepted conditionally

Review target: `20c8f6b75a5761f87309afb3805c2167bf504a3b`,
[response provenance](../research/retained-response-provenance.md) and its
five-file evidence packet. No correctness blocker was found in its stated
source/configuration scope. Its accepted conclusion is preservation of native
identifier provenance whenever the response reaches native entity/result
handling. It is not a theorem from arbitrary parsed JSON to live native IDs.

The earlier challenge remains material: bounded, syntactically valid JSON can
contain an unallocated represented Node_Id. The revised argument instead
uses the actual immutable producer record and publication control. I reviewed
normal serializer/Format/channel ordering, error dispatch, the two abort roots,
once-gated exit flushing, external-server selection and terminal stderr.

The finite checker correctly treats an abort as a token prefix, permits a
proper byte prefix of a lost token, carries the three-loss allowance across
both aborts, and begins at every unfinished `entity` spelling. The symbolic
unknown-errno digits have exactly the same target-word transitions as actual
signed-int32 digits. Layout-whitespace erasure enlarges this lexical language.
The full-key/numeral seams require the separate source argument: three losses
cannot remove the leading abort discriminator and expose the colon or numeric
delimiter needed to complete or shorten the native entity. Earlier intact
JSON nesting cannot be reinterpreted retroactively.

Extra private-printer layout whitespace does not invalidate the finite lemma.
Spaces cannot supply target letters. Escaped LF/CR/TAB tokens begin with a
backslash and end in `n`, `r` or `t`; a suffix loss cannot retain that final
letter alone, and none begins the target word. Such inserted tokens either
break a candidate match or can be erased for free in the overapproximation.
Direct abort layout whitespace is already erased by the checker.

The three-loss bound comes from three actual control entries, not `e<=2`:
main abort, the sole standard-formatter drain, and uncaught-handler abort.
Each stops at its first exception even when draining old queue contents.
Repeated base channel flushing preserves debt and does not delete Format
tokens. Raw stderr fallback is terminal and starts with its fixed `Fatal`
prefix. Post-normal `putenv` may raise Unix_error, but by then the complete
normal text is in FIFO/channel order; its different diagnostic alphabet does
not belong to the active-write case.

The quiet-entry result depends on the selected SIGINT mask **from exec**,
adequate resources and all retained representation/source/descriptor guards.
The accepted missing-parent getter maps ordinary lookup failure to BadID;
the raw-backtrace recipient needs an excluded signal-origin Not_found.
The selected valid driver placeholders have at most two digits. Fresh
nonreplay and actual `get_model=None` exclude the other classified direct
stderr roots. Debug/Stats and location warnings retain private destinations;
the external socket stays connected, so neither an internal child server nor
an editor inherits this response destination. These are source/configuration
facts, not measurements of the historical unmasked captures.

I matched all five reviewed files byte-for-byte to the frozen commit and ran
the new checker once. It passed: eleven source identities, 132 fixed errno
strings, 435 payload templates, six partial-key seams, two abort prefixes,
three token-suffix losses, and both terminal raw fallback prefixes. It retained
24 reachable states without the target word. Checker time was 3.914032 seconds;
invocation wall time was 4.037362 seconds. Exact hashes and output are retained
in [the audit record](../evidence/review-producer-report-capacity-20261024/provenance-audit.json).
No compiler, prover, provider, capture, or predecessor checker was rerun.

This bounded frozen review completed at 01:27:37 UTC. The first recorded
review clock for the broader source work is 00:44:21 UTC; actual earlier start
is unavailable. The intervening 43m16s includes incoming-state and printer
source challenges and author coordination, so it is not a timing measurement
of this checker or this component alone.

## Integrated review still pending

The incoming flow/warning/string/counter source derivation has received a
scoped no-undercount-found disposition, including the explicit warning gates.
The complete #193 writer, native frontend prerequisite, third-pool lifetime,
printed-expression bounds and final option tuple still require their coherent
freeze and integrated review. The preserved global allowances remain `e<=2`,
two save-entering callbacks and three saves; downstream collector/Silver-reader
work remains #194.
