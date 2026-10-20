# Initial managed-channel count and reference headroom

2026-10-20 UTC, #119 / #153. This result supplies a starting bound for the
channel/exit composition without another native capture. It covers the five
retained debugger-controlled prefixes under their existing source/runtime
relation. It does not bound subsequent channel creation or global flush calls.

The accepted [initial-registration argument](retained-why-initial-registration-bound.md)
establishes the minor-heap bump usage B, no collection/reset, the controlled
debugger signal policy and the classified pending clients before each cut.
The [packet](../evidence/retained-why-channel-initial-bound-20261020/README.md)
attaches those facts to the actual channel-wrapper allocation sequence.

## The charge precedes every completed prefix

OCaml's channel constructor initializes `refcount=0`. Each channel-wrapper
constructor increments that C int once, then calls
`caml_alloc_custom_mem(&channel_operations, 8, 65616)`. This includes the
installed inlined increments in `caml_ml_open_descriptor_in`,
`caml_ml_open_descriptor_out` and `caml_ml_out_channels_list`, as well as
`caml_alloc_channel` itself. The last primitive creates additional wrappers for
existing channels: a wrapper count must not be identified with a channel count.

In `alloc_custom_gen`, eight payload bytes give
`wosize = 1 + (8+7)/8 = 2`; its small-object branch allocates three words,
including the header. The retained native bodies attach both the argument
values and the minor-allocation route. The custom-resource accounting and
Memprof call occur after that allocation; neither is a second channel refcount
increment. `refcount` is initialized at offset 64, incremented with `addl`,
and decremented only by the channel finalizer. No arbitrary foreign field
writes or malformed channel objects are added to the existing relation.

The increment occurs **before** allocation. Therefore this argument explicitly
reuses the accepted controlled-prefix exclusion of an abandoned allocation,
rather than inferring the charge from no collection alone. The same native
pending-action route cannot deliver SIGINT/stack-fault handlers before these
successful cuts; the one-worker yield cannot reach a capture endpoint; there
are no application finalizers/alarms or active Memprof callbacks. Ordinary
valid-request allocation services supply their documented behavior. A capture
cannot occur inside a suspended channel constructor through those clients.
If an error occurs after its small allocation, the three words are still
charged: no initial collection/reset is credited. Before that allocation,
the fixed size arithmetic is represented and the classified services supply
no additional abandoned increment. These are properties of the retained
controlled prefixes, not a new production signal exclusion.

Let Q be the mathematical number of channel-wrapper increments before a cut.
Every such increment charges a distinct three-word bump allocation, so

```
3 Q <= B,                 Q <= floor(B/3).
```

Each managed channel has passed a managed descriptor constructor and its first
wrapper increment before the cut. Thus the number of initially live managed
channels, and its output-only subset, are each at most Q. Every individual
initial refcount is nonnegative and at most Q. No finalizer runs in these
uncollected prefixes; ordinary channel close does not decrement the counter.
The first signed 32-bit overflow would require at least 2^31 increments for one
channel, and hence at least 3*2^31 minor words, contradicting B<2^28. This is
a first-overflow argument, not an assumed mathematical reading of a C counter.

| Case | B, minor words | Q upper bound | Additional increments before INT_MAX |
| --- | ---: | ---: | ---: |
| Put_Line | 127,939,731 | 42,646,577 | 2,104,837,070 |
| Put | 116,661,081 | 38,887,027 | 2,108,596,620 |
| First_Or_Default | 87,937,967 | 29,312,655 | 2,118,170,992 |
| Is_Message | 77,776,179 | 25,925,393 | 2,121,558,254 |
| Input_Is_Valid | 79,191,224 | 26,397,074 | 2,121,086,573 |

These deliberately loose values are upper bounds, not a measurement of the
open-channel list or its refcount fields. They include wrappers for input and
already closed channels. Unmanaged C-only channels are not included in the
cardinality result. The exact initial global list, flags, offsets, pointers and
mutex state remain unobserved by this packet.

## What remains

The channel/exit owner must bound post-cut wrapper attempts, including failed
attempts whose increment precedes allocation, repeated `out_channels_list`
calls and channels created by other continuing driver paths. Finalization and
list traversal need their lifetime/ownership argument. Initial headroom does
not establish any of those transfers. The six save-created channel records
already charged by the file packet are not recharged here. No complete channel,
save or pipeline flag is enabled, and no physical-memory claim is made.

Validation binds retained evidence and exact source/native bytes, then checks
the five arithmetic applications and the first-overflow threshold. It runs
no target, new disassembler, predecessor checker, solver, proof or suite.
Independent review is recorded in the combined Round 36 report. Live lead
model/effort and individual token/cost telemetry are unavailable; no setting
change is claimed. Oracle, tools/pins and admission are unchanged.
