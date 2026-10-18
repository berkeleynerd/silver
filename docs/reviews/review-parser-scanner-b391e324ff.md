# Main parser auxiliary and scanner-node review

2026-10-18. Refs #119. Frozen target: `b391e324ff`.

No material finding. The parser auxiliary bounds and scanner-node extension
are supported for one successful Main parse under the unchanged grammar and
the stated configuration. They supply component inputs; they do not yet bound
all Main parser nodes or all subsequent tool phases.

## Scope and evidence

The reviewed changes are `0cb9369b83` (parser auxiliary tables and corrected
source-loop scope allocation), `2ff5fd9609` (identifier scan multiplicity and
colon-numeral scanner nodes), and their coverage-index update `b391e324ff`.
The target reports are
[table capacity](../research/retained-table-capacity.md#main-parser-auxiliary-transfers),
[frontend entities](../research/retained-frontend-entities.md#loops-three-entities-plus-at-most-two-captures)
and [value capacity](../research/retained-value-capacity.md#main-scanner-node-allocations-including-identifier-rescans).
Earlier literal-scan and allocator reviews retain their separate scopes.

The source is GCC Ada commit `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`,
read from `/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada`.
The submitted table and value generators both reproduced their retained
outputs byte-for-byte. Their SHA256 values, respectively, are:

```text
09113ecd509540403b57bd67abd259db7c1dac80b9f7eb885ffa6e18f8537f0f
7d5a2feb77e23ca862f3f8f4f7a72cf8e2c06ddb54afd0014f0609223b313133
```

An [independent inventory](../evidence/review-parser-scanner-b391e324ff/check.py)
and [its output](../evidence/review-parser-scanner-b391e324ff/result.json)
retain source hashes and check the suspicious-label append/reset sites,
loop-counter assignment, scan-state restoration and unconditional obsolete
numeral diagnostic-node constructor. They corroborate the manual path review;
the lexical inventory alone does not prove reachability or multiplicity.

No compiler, native stress run, GNATprove, Lean, full test suite or tool rebuild
was run. The arithmetic/source checks completed in seconds on Linux. No
existing report, production/proof source, issue or board entry changed here.

## Parser auxiliaries

`Scope.Init` is followed by one dummy entry. Main's sole subprogram parser
pushes once; each nested if/for adds one active entry, and successful matching
ends pop it. Elsif reuses the current if entry. The other push sites require
constructs outside the unchanged Main grammar. Thus `2+d` bounds the peak
entry demand. Reading `Scope.Last+1` after the body ends does not require an
additional peak allocation: that entry was present before the pop. Native
recursive stack space and the exact target record byte layout remain separate.

The complete parser scan found one `Suspicious_Labels.Append` site and no
parser reset. Its successful bare-call path is reachable for `Reject; for`.
Qualified Reject takes the general name path; output calls have arguments.
Each matching adjacency adds one record, and there can be at most one per
for statement. The report correctly carries incoming table demand from earlier
units instead of resetting the count at Main. The three 32-bit fields give
the stated twelve-byte entry.

The loop name helper has one package-level increment and no per-unit reset.
Its `L_` prefix plus a Nat's at most ten decimal digits plus NUL gives thirteen
characters. The incoming counter plus source-loop count must fit signed Int.
This name charge is distinct from later name qualification.

For each unlabelled source for loop, the parser constructs an ordinary name
identifier and appends the loop to `Label_List`. `Par.Labl` creates one
implicit-label declaration and one defining entity. The mandatory SPARK_Mode
pragma makes Main's declaration list already present, so no extra ordinary
list is created. Semantic analysis changes the implicit entity from label to
loop kind; it does not allocate another source-loop scope. The correction to
the entity report therefore preserves its existing count while repairing the
allocation trace.

`Goto_List` and `Label_List` each get a header at parse entry. `Find_Natural_Loops`
allocates a third even when no goto exists. Its two-list merge skips directly
to the unfiltered remainder loop when `Goto_List` is empty, copying all F loop
entries into the new element list. Its following dispatch performs no label or
goto rewrites for those loop nodes. This confirms three element-list headers,
`2F` element entries, `2F` ordinary auxiliary nodes and `F` entities, with
the separate declaration-list linkage and generic table/sentinel charges.

## Identifier scan multiplicity

`Restore_Scan_State` restores the saved Token_Node, so the saved token is
reused and only later tokens can incur another scanner allocation. The new
identifier-specific paths support at most two scans per source occurrence:

- Valid qualified name selectors and Image/Length designators proceed forward.
  Their rewind alternatives require excluded Range/qualified-expression
  syntax or a malformed selector/attribute.
- A first-actual association probe saves its initial identifier and scans
  punctuation after it. Even the named-actual path's second probe scans the
  same arrow, not another identifier. Valid one-actual calls have no comma
  recovery path.
- Statement/declaration classification reuses its initial identifier. Valid
  statement successors are punctuation; valid type-name successors are range
  or assignment tokens. One defining identifier excludes declaration replay.
- The statement keyword heuristic can scan the next identifier and restore.
  Its `Is_Reserved_Identifier` call uses the default `C=None`, which performs
  no nested lookahead itself. The affected names are loop indexes, condition
  starts, the final Main end name, or first statement names following else.
- A grouped lower-bound preliminary parse can rescan its scalar identifiers,
  but its nested groups use ordinary expression parsing. Those lower bounds
  have neither calls nor conditions and cannot overlap the other lookaheads.
- Same-line else lookahead may scan qualified call selectors, named actuals
  and argument names. It saves the first statement token, so a keyword
  heuristic's previous extra scan of that first token does not add another
  copy in this probe. It stops at assignment, if or for before their scalar
  subexpressions.
- The sole pragma actual is On; its probe scans the right parenthesis.
  Main has no configuration pragmas, private context or nested named end.
  Successful end matching therefore does not enter duplicate-end recovery.

Repeated context clauses contribute distinct token occurrences. None of
these paths replays an earlier clause. The extra scans above are disjoint
for each occurrence, consistent with the earlier literal-only review.

## Scanner nodes and obsolete numerals

`Scn.Post_Scan` allocates one node for each identifier, integer literal,
String literal or operator-symbol token. A quoted operator spelling is still
one source String token and receives one scanner node. The current grammar
excludes character/real literals and reserved identifiers.

The numeral path calls `Check_Obsolete_Base_Char`; colon delimiters invoke
`Check_Restriction(..., New_Node(N_Empty, S))` before testing whether the
obsolescent warning is enabled. Therefore warning suppression cannot remove
the extra node. `No_Obsolescent_Features` is a Boolean restriction: bookkeeping
updates fixed flags, and the local-restriction hook returns for it. Under the
stated no-active-restriction, disabled-warning/style settings, no diagnostic
allocation beyond the dummy node is required. Other obsolete lexical forms
are excluded by Silver's lexer.

Combining these per-scan allocations with the identifier/literal factor two
gives `A_scan <= 2*(W+S+N+N_colon)`. Charging all word tokens instead of only
identifiers is safely conservative. This counts scanner-created ordinary
nodes, including discarded lookahead nodes. Parser constructors, kind
changes to defining identifiers, semantic actions and dependency scans still
require their own contributions.

## Remaining limits

These results do not establish exact installed-tool source identity, all
configuration closure, all ordinary parser constructors, physical stack or
complete source-to-tool capacity. The table-record layout still needs its
target byte input. The successful-parse premise also cannot be reused for
the broader grammar of fixed library dependencies. No admission expansion
follows from this component review alone.
