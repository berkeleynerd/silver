# F1 / #215: exact raw directory spellings

The independent prospective-configuration review found that `pathfile_entries`
accepted any number of trailing slashes via `rstrip('/')`, although the
source contract permits only the directory or one trailing slash. Native
`Normalize_Directory_Name` preserves a spelling already ending in a slash.
The original checker therefore accepted a runtime-source directory that could
produce a 439-byte `system.ads` path, exceeding P=188 and the Arguments
sufficient endpoint 395. This is an interface counterexample; the selected
GPR recipe was not shown to generate it, and no native overflow was observed.

The correction compares the **raw value** with the finite set of allowed
directories and their one-slash alternatives. It returns the original values,
preserving sequence order and multiplicity. It neither canonicalizes an
unchecked value for later forwarding nor changes the selected normal paths.
Empty, malformed, foreign, NUL-containing and repeated-slash entries cannot
equal an allowed spelling. The prior source argument covers every remaining
accepted spelling, so P=188 and the command/configuration coefficients stay
unchanged. Cardinality/storage and physical-directory relations remain their
separate stated obligations.

One [focused check](result.json) passed 78 assertions in 0.110041 seconds.
It reproduces the counterexample from the exact original Git recipe, checks
every allowed source/object directory with zero/one trailing slash, preserves
raw return values/order/multiplicity, and rejects repeated slashes and other
unsupported inputs. It also checks that the rest of the recipe's AST and all
unmodified original author artifacts are unchanged. Only the two needed
functions and their constants are loaded; no provider/author/predecessor
checker, filesystem fixture, target, compiler, prover, Lean or service query ran.

Original author `9432b9d69498cce7e2474d7a96c4adc37f97b7ae` and its result,
round history, source archive and initial failure diagnostic remain retained.
The repair was written by the lead; its live model/effort and isolated token/cost
measurements are unavailable. Independent review is pending. This closes no
whole-configuration, #212 or #119 obligation by itself. Oracle, admission,
installed tools, physical premises and the one global callback/save allowance
are unchanged.
