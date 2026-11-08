# Named-body source check — failed outcome retained

Run `20261108T022400-531d5c89d319` checked the same four focused targets on
governed snapshot `6a74bccc5a`, with eight Lake workers and 22 process threads.
It finished with failure at 2026-11-08 03:24:40 UTC after 3,636.905 seconds.
The build took 3,575.536 seconds; the retained log's build start at 02:25:04
matches the managed phase event. The log and events are indexed with hashes.
This is not a successful source or axiom audit.

The three repairs from the preceding failed run compiled: the Basic_Body and
Loop_Body rendered candidates and the Boolean declaration import proof. The
expanded named-body leaf then reported stale source requirements for body
headers, the Is_Word_Token contract, and three type declarations. Separately,
ComposeSourceBridge reported a record-update layout syntax error and its
resulting unsolved proof. The log contains 23 diagnostics across these two
modules. No native input changed during the run.

The next repair changes two proof files only:

- `PredicateSourceRequirements` records the existing Catalog formal and
  Functions.Valid_Metadata precondition on the recursive body helpers. The
  corresponding `PredicateBodyHelpers` and `PredicateBodyCorrespondence`
  equations already quantify over this catalog and its validity. Existing
  typed tail/read contract renderers remain intact and already pass Catalog.
- The same requirements now record the existing Original parser-state formal
  of Expand_Body, Pure/Integer_Hidden context fields, Return_Only boundary,
  and Function_Keyword/Return_Keyword tokens. `PredicateAdapter`,
  `PredicateNativeState`, `PredicateBodyScanner` and `PredicateBodyExpressions`
  already model and render these constructs. Their implementations are
  unchanged. `body-source-requirements-diff.json` retains every changed
  requirement, literal-token delta and the exact native/old/new hashes.
- `ComposeSourceBridge` places the four unchanged record-update fields on
  aligned lines. Field values, theorem statements and domains are unchanged.

This diagnostic token comparison is not kernel acceptance. All existing
named authoritative-source checks remain required, followed by the complete
Lean/module/axiom audit. The native complete audit and full regression suite
continue independently on their frozen inputs. Independent review of these
changes and the three preceding proof repairs remains pending: restarting
the existing Astra Extra High reviewer was refused by the agent thread limit,
so no reviewer turn or replacement agent was created.
