# Boolean tree proposal and package-call stages — 2026-11-22

Focused Linux x86-64 run `20261122T175405-a8d054a971d2` passed with a fresh audit
of 21,499 declarations and only the documented foundations `propext`,
`Classical.choice` and `Quot.sound`. Evidence elapsed time was 17.199 seconds,
using two managed workers and two threads per Lean process. Matching successful
Boolean candidate compilation was reused; the audit was fresh.

The candidate checks all four complete Boolean reader bodies, result type,
default constant and five headers (including the condition reader's forward
specification). Its literal tokens are an untrusted proposal generated from
the recorded native fragment. Final authoritative whole-source token binding
is still required. The two failed candidate attempts are retained in the managed
ledger: the first used the wrong punctuation tokenizer, the second reached
opaque imported mutual renderer definitions. The existing source-certificate
candidate lexer and explicit renderer equations resolved those local checks.

`callStages_success` and `accepted_call` now extract the actual callee, its
routine record, formal-window checks, parsed actual frame, alias-checked result,
exact finishing equation, cursor progress and final Valid_Body test. Every
witness uses the metadata passed at that call position, including its completion
prefix. They do not assume or establish a semantic signature/checker bridge.
Actual source interpretation and imported-call correspondence remain pending.
