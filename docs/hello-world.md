# Hello World implementation checkpoint

The owner authorized this goal on 2026-10-08. The Oracle remains unchanged.
The starting implementation commit is `fa558c6`; the supported language is
initially still null-only.

## Scope

- Preserve the null program and establish a small supported sample collection.
- Admit a bounded class of printable ASCII string literals passed to one
  qualified output operation, with the required context clause.
- Preserve the same actual application source through admission, proof and
  compilation. Verify selected Silver-owned library bodies and their source
  correspondence.
- Specify successful output, failure outcomes and environmental progress
  assumptions before admitting the operation.
- Complete the SPARK and Lean assurance, integration tests, documentation and
  local commits. Linux validation is primary; native macOS and remote CI remain
  independently pending.

## Work in progress

The sample move and manifest are complete, with focused native Linux tests.
The null source remains exactly 69 bytes. The manifest test checks actual
application stdout, stderr and exit status independently of compiler messages.
It replaces the former duplicate baseline compile/run integration case; the
maximum-source-length and source-preservation case remains.

Runtime feasibility is being investigated in an isolated native workspace.
`Silver_IO.Put_Line` is the candidate API. New source files and proof modules
under development do not yet constitute an admitted output capability.

The existing null recognizer and its proofs will remain as a subgrammar of the
one current language. A separate literal-output recognizer and current-language
union avoid disturbing that completed argument. This is implementation
modularity, not a policy of maintaining historical language versions.

The source limit remains 4096 bytes. The proposed literal class includes empty
strings and Ada doubled-quote escaping, preserves case, and excludes nonprintable
bytes inside literals. These are implementation targets, not current admission
rules until the required assurance is complete.
