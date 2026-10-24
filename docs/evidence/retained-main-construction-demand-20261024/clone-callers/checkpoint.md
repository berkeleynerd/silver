# Clone caller continuation checkpoint

Parent authorized the next #202 / #119 attachment after independent acceptance
of bridge `3f4f6143c206518bf257d3d9b63cee2a08d14bcd` by review `536c35cd2c`.
Start clock 2026-10-24 04:34:46 UTC. Same author worktree/branch; preserve old
packet and receipts. Own this subdirectory and a continuation of the research
note only. Selected GPT-6 Astra / Extra High; runtime/tokens/cost unavailable.
No new subagents, native/prover runs, predecessor-checker replay or GitHub writes.

Objective: source-attach whole inherited clone map coverage/capture safety,
including foreign variables, formal/oldie and lexical extensions; derive root
caller multiplicities where this same traversal suffices. Native bytes and
complete kode/SPWP construction remain outside this bounded result.

Initial source findings (not yet a frozen theorem):

- `cl_init` starts `pv_table` empty and does not seed arbitrary `mi_pv`
  replacements. Successful ordinary `PDlet` cloning persists only the maps
  returned by native `clone_let_defn`. `sm_of_cl` therefore has traceable
  inherited provenance.
- `clone_pv`, LDvar, local routine RLpv and `clone_ppat` targets are fresh;
  `sm_save_args`/`sm_save_olds` point at those already fresh outputs. Original
  modules are complete before an export-clone traversal starts.
- `find_old` memoizes by original pvsymbol per label, and `get_oldies` reverses
  that map. Need retain this injectivity at `sm_save_olds`.
- Retained 21-file corpus has 64 explicit clone origins. Narrow source scan
  found only three plain nullary `val` objects: `_gnatprove_standard.Main`'s
  `__HEAP`/`no__return`, and `mach.int.Random63.s`; neither module is cloned.
  Some origins use `_gnatprove_standard.Main` for types, so merely excluding
  it as an origin is insufficient: check actual state references/imported
  callable effects. Raw scans found no `__HEAP` or `no__return` occurrences
  in the origin set.
- Ordinary Main scalar/array origins add Static_Discrete, Rep_Proj_Int,
  Array__1, Constr_Array and Unconstr_Array; Dynamic_Discrete is already a
  fixed origin. The accepted type frontier excludes arbitrary program-module
  origins. An "existing type clone" branch emits an include/alias; native
  converter Include_Decl turns even `Clone_default` includes into **use**,
  not clone. Only actual Clone_declaration invokes cloning.

Next: finish finite corpus coverage (top-level vs lexical lets, foreign-state
dependency), attach source scope/oldie/pattern construction, then formulate
the ordered clone root-call recurrence and focused new evidence. No full
closure conclusion yet.

## Author freeze, 2026-10-24

The continuation now supplies the source induction for all 69 origins:
the inherited pv_table remains empty at declaration boundaries; lexical
formals, oldies, lets, routine representatives and patterns are fresh and
cover source free variables. Original and clone-produced oldie maps retain
injectivity. The type-projection correspondence and no-interface traversal
gate are attached to retained source bytes. Direct caller counts are folded
over actual stored records at each clone boundary; bytes and kode/SPWP remain
open.

Material corrections before freeze:

- The initial three-object scan omitted attribute-bearing `spark__branch`.
  Complete token classification finds four globals, with no references to
  any standard-Main global in the other 96 dependency modules. Random63 is
  outside the closure. This corrects the preliminary inventory above.
- `val eq = ...` in three clone directives is a routine refinement, not a
  val declaration. The new inventory records these separately.
- A refinement also makes one direct `c_app`. A later clone must count its
  transformed origin records, not sum unchanged ancestral caller weights.
- The absence of type witnesses is checked independently using the absent
  `by` token. Parent review requested a separate Main-instrumentation gate:
  Main is never an origin, converter substitutions omit CSvsym, and fixed
  WhyML branch constructors inject no foreign branch variable.

Final new-only result: 674 counted checks, 1.283644 seconds, Linux x86_64.
Two initial checker attempts stopped on inventory classification/expectation
errors; after repair all three successful runs had distinct added questions
(base inventory, explicit witness exclusion, instrumentation source gates).
No predecessor main/native/compiler/prover/solver/Lean run. The old bridge,
repair and receipts are unchanged. Parent owns independent review and any
issue/memory/publication updates. CLI memory was not updated; this subthread's
live harness goal was null at handoff inspection.
