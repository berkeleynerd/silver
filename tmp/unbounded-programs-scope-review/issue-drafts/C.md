TITLE: Unbounded programs: Pinned-frontend and derived source limits
LABELS: type: work package, area: language, area: compiler, area: assurance
---
**Backlog; not authorized.** This package needs the owner's "proceed", recorded in a dated session-memory entry on `main`, before it moves to Ready. Its derivations can start after #{A}. Its native rules follow #{D}'s recognizer restructuring, or live in a separate lexical pre-pass unit that #{D} does not rewrite. Its Lean rules are stated over #{E}'s symbolic limits. The [scope proposal](https://github.com/berkeleynerd/silver/blob/main/docs/unbounded-programs.md#pinned-tool-and-inherited-language-limits) governs it.

**Order 5.** Make the maxima of the pinned GNAT 16.1 frontend explicit, decidable language rules, documented as tool-derived limits rather than Ada requirements. While the 4096-byte source bound remains they are unreachable, so admission does not change until #{F}.

- **Physical line width.** Lines end at LF, CR, CRLF or end of file. After expanding each horizontal tab to the next multiple of 8 columns, a line is at most 32,765 columns.
- **Identifier length.** At most 4,096 characters, using the identifier constant from #{D} and #{E}.
- **Exponent maximum.** 799,999, adopted by #{F}.
- **Total source length.** The rule is the smaller of two derived bounds:
  - *Source-position bound.* GNAT places every unit of one compilation in a single 2^31 source-position space with 4 KiB alignment. The bound is 2^31 − 1 minus a stated upper bound on all other units and alignment, in null and output modes. 2,130,706,432 bytes (2^31 − 2^24) is the largest accepted size tested so far; 2,147,483,647 crashes `gnat1`. Confirm the value with `gcc -gnatc`, full builds and GNATprove.
  - *Internal-table bound.* The largest size for which no GNAT internal table can be exhausted: 100,000,000 Names, Lists, Elists, Elmts, Strings and Ureal entries, about 1.5e9 Uints and 2,000,000,000 nodes. Derive it from the maximum table entries per source byte with a per-construct entity-count analysis of the frontend. The research estimates the List cap near 50 million `elsif` arms (about 1.5 GB of source needing about 44 GB), and `table.adb` does not check overflow, so a premise is not acceptable.
- Re-derive both bounds whenever the runtime library (#{G}) or the toolchain changes, and on macOS.
- The native recognizers, Lean membership, catalogue, `language.md` and the frontend premise in `docs/trusted-boundary.md` agree.

**Completion criteria**

- Each rule is implemented with complete Bronze and Silver evidence, modeled in Lean with a fresh axiom audit, and listed in the catalogue.
- Boundary tests exercise each limit and one past it, comparing admission with the pinned frontend.
- The derivations record exact inputs, tool identities, timings and the per-construct analysis.
- No source changes admission status at the current 4096-byte bound.
