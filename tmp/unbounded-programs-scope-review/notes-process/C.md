TITLE: Unbounded programs: Pinned-frontend lexical limits
LABELS: type: work package, area: language, area: compiler, area: assurance
---
**Backlog; not authorized.** This package needs the owner's "proceed", recorded in session memory. The [scope proposal](https://github.com/berkeleynerd/silver/blob/main/docs/unbounded-programs.md#pinned-tool-and-inherited-limits) governs it.

**Order 3.** Make the maxima of the pinned GNAT 16.1 frontend explicit, decidable language rules, documented as tool-derived limits rather than Ada requirements. While the 4096-byte source bound remains they are unreachable, so no admitted program changes until #{F}.

- **Physical line width.** Lines end at LF, CR, CRLF or end of file. After expanding each horizontal tab to the next multiple of 8 columns, a line is at most 32,765 columns.
- **Identifier length.** At most 4,096 characters, an independent constant not tied to source length.
- **Total source length.** At most the exact maximum the pinned frontend accepts. Bisect it across `gcc -gnatc`, full builds and GNATprove with the six runtime units. 2,130,706,432 bytes (2^31 − 2^24) is the largest value tested so far; 2,147,483,647 crashes `gnat1`.
- **GNAT internal tables** (100,000,000 Names, Lists, Elists, Strings and Ureal entries; 2,000,000,000 nodes). Either derive a rigorous source bound from the minimum source bytes per table entry and adopt it, or record the explicit premise that they are exhausted only after host resources.
- Native recognizers, Lean membership, catalogue, `language.md` and the frontend premise in `docs/trusted-boundary.md` agree. Document re-probing for every toolchain change and on macOS.

**Completion criteria**

- Each rule is implemented in both recognizers with complete Bronze and Silver evidence, modeled in Lean with a fresh axiom audit, and listed in the catalogue.
- Boundary tests exercise each limit and one past it, comparing admission with the pinned frontend.
- The bisection and table-capacity evidence is recorded with exact inputs, tool identities and timings.
- No admitted or rejected program changes status at the current source bound.
