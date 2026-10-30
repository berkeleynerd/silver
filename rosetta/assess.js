export const meta = {
  name: 'rosetta-silver-coverage',
  description: 'Assess Rosetta Code tasks for Silver: language surface, proof outlook and size, one agent per task',
  phases: [{ title: 'Assess', detail: 'one agent per task at its tier' },
           { title: 'Escalate', detail: 'confirm unlikely outlooks, conflicts and low-confidence verdicts' }],
}

// Run through `python3 rosetta/assess.py prepare`, which fills in TASKS and writes a runnable copy.
const TASKS = [] // assess.py prepare fills this in
const ROOT = '' // assess.py prepare fills this in
const TIERS = {
  standard: { model: 'sonnet', effort: 'medium' },
  deep: { model: 'opus', effort: 'high' },
}
const EFFECTS = ['console-output', 'arguments', 'exit-status', 'stdin', 'files', 'directories', 'clock', 'delay',
  'entropy', 'environment', 'processes', 'terminal', 'gui', 'graphics', 'sound', 'network', 'hardware',
  'os-services', 'other']
const SURFACE = {
  "fixed-string-replacement": "Ada.Strings.Fixed.Replace_Slice function on bounded Strings with statically valid slice positions and bounded replacement/result lengths",
  "unicode-identifiers": "non-ASCII Ada identifiers in explicitly specified source encoding, with inherited normalization and case equivalence",
  "scalar-guard-refinement": "bare mutable Integer names or loop indexes compared in either order with Ada-static singleton thresholds; nonempty outcome refinement or incoming fallback, assignment replacement, branch hulls, reached short-circuit reads, and captured loop bounds with mutable widening; no expression inversion or variable relations",
  "assignment-target-name": "Ada 2022 @ as a constant view of the current simple Integer assignment target within its right-hand expression",
  "integer-object-size-read": "reading the Size attribute of an initialized stand-alone Integer object as a bounded Integer value, distinct from a representation clause",
  "integer-object-size-clause": "static Size representation clauses for stand-alone Integer objects, initially confirming the pinned 32-bit representation",
  "static-integer-types": "distinct signed integer type declarations with static bounds and initialized objects of those types, including same-type copies",
  'immutable-integers': 'immutable signed 32-bit Integer constants, interval-checked grouped +, -, * and nonliteral unary signs, standalone signed literals, and scalar comparisons',
  'integer-for-loops': 'inclusive ascending or reverse Integer range loops with immutable indexes, nesting and admitted scalar bounds',
  'integer-image': "standard Integer'Image with Ada's leading space for non-negative values and bounded result lengths",
  'bounded-mutable-integers': 'initialized mutable Integer objects and optional static object-local Integer constraints, with nonempty assignment RHS intervals contained in the declared range; selected flow refinement is scalar-guard-refinement',
  'integers': 'integer variables and constants with +, -, * and comparisons (Integer or declared ranges)',
  'interval-integer-division': 'fully grouped /, mod and rem on signed 32-bit Integer expressions, checked against incoming intervals; selected flow refinement is scalar-guard-refinement; abs is excluded',
  'integer-division': '/, mod, rem and abs on integers',
  'exponentiation': '** on integers',
  'modular-types': 'unsigned wraparound types and bitwise operations',
  'named-integer-subtypes': 'nonempty Ada-static Integer range subtypes for initialized scalar objects and fixed-array components; direct Integer parent only, optional narrower scalar object ranges, no aliases, conversions or subtype attributes',
  'ranged-subtypes': 'declared integer or enumeration subtypes with ranges, and conversions between types',
  'scalar-boolean-objects': 'initialized scalar Boolean constants and variables, assignment, visible True/False, not, eager and/or/xor (neither xor operand may contain xor), short-circuit and then/or else and Boolean equality/inequality, composing with current checked predicates; no stored predicate facts, Boolean arrays, subtype declarations, Image, ordering, enum loops or user routines',
  'booleans': 'Boolean variables, constants and Boolean-valued functions',
  'characters': "Character values and literals, 'Pos, 'Val and comparisons",
  'enumerations': "user-defined enumeration types, 'Image, 'Succ, 'Pred and iteration over them",
  'floating-point': 'floating-point types, arithmetic and elementary functions',
  'fixed-point': 'fixed-point or decimal types',
  'fixed-integer-arrays': 'anonymous one-dimensional Integer arrays with nonempty static bounds, mandatory explicit positional initialization or a singleton (L => E), scalar-only interval-checked subscripts and component-preserving indexed writes; declarations retain exact snapshots and body reads use their declared component range (full Integer for of Integer)',
  'constant-integer-array-iteration': 'forward or reverse foreach over an existing constant fixed-size Integer array, with an immutable nonstatic element, declared component entry bounds, identity-based iterable capture, scoped hiding and existing scalar/String flow rules',
  'arrays': 'one-dimensional constrained arrays, indexing and aggregates beyond the fixed-integer-arrays fragment',
  'multidim-arrays': 'arrays of two or more dimensions',
  'unconstrained-arrays': "unconstrained array types and parameters, slices, 'First, 'Last and 'Range",
  'records': 'record types, components and aggregates',
  'variant-records': 'discriminated or variant records',
  'string-indexing': 'reading characters and slices of a String by index',
  'string-building': 'building strings of computed length in bounded buffers',
  'string-ordering': '<, <=, > and >= on strings',
  'scalar-image': "converting integers or other discrete values to text ('Image)",
  'float-image': 'formatting floating-point values as text',
  'text-parsing': 'converting text to numbers, with validation',
  'case-statements': 'case statements',
  'conditional-expressions': 'if and case expressions',
  'membership-tests': 'in and not in tests against ranges or choice lists',
  'for-loops': 'for loops over discrete ranges, including reverse',
  'while-loops': 'while loops and loops with exit when',
  'block-statements': 'declare blocks',
  'local-exceptions': 'exception declarations, explicit raise statements and handlers within one subprogram',
  'procedures': 'user-defined procedures with in, out and in out parameters',
  'functions': 'user-defined functions without side effects',
  'recursive-procedures': 'procedures that call themselves directly or indirectly',
  'recursive-functions': 'functions that call themselves directly or indirectly',
  'generics': 'generic subprograms or packages and their instances',
  'packages': 'user-defined packages and private types',
  'tagged-types': 'tagged types, dispatching and interfaces',
  'access-types': 'access types and allocation',
  'tasking': 'tasks and protected objects',
  'big-numbers': 'integer values beyond 64 bits, in fixed-capacity digit arrays or an admitted library',
  'put': 'output without a line terminator',
  'standard-error': 'output to standard error',
  'more-arguments': 'the argument count and arguments beyond the first',
  'exit-status': 'setting the process exit status explicitly',
  'stdin-lines': 'reading lines or characters from standard input',
  'file-input': 'reading named files',
  'file-output': 'writing named files, including binary formats',
}
const RISKS = ['overflow', 'range', 'index', 'division', 'length', 'discriminant', 'initialization', 'termination',
  'stack', 'heap', 'floating-point', 'tasking', 'other']
const CONFLICTS = ['runtime-error', 'annotations', 'outside-spark', 'unsafe', 'other']
const SCHEMA = {
  type: 'object',
  properties: {
    conflicts: { type: 'array', items: { type: 'object', properties: {
      kind: { type: 'string', enum: CONFLICTS }, explanation: { type: 'string' } }, required: ['kind', 'explanation'] } },
    effects: { type: 'array', items: { type: 'object', properties: {
      effect: { type: 'string', enum: EFFECTS }, explanation: { type: 'string' } }, required: ['effect', 'explanation'] } },
    surface: { type: 'array', items: { type: 'string', enum: Object.keys(SURFACE) } },
    outlook: { type: 'string', enum: ['likely', 'plausible', 'unlikely'] },
    risks: { type: 'array', items: { type: 'object', properties: {
      obligation: { type: 'string', enum: RISKS }, explanation: { type: 'string' } }, required: ['obligation', 'explanation'] } },
    size: { type: 'integer', minimum: 1 },
    approach: { type: 'string' },
    summary: { type: 'string' },
    confidence: { type: 'string', enum: ['high', 'medium', 'low'] },
  },
  required: ['conflicts', 'effects', 'surface', 'outlook', 'risks', 'size', 'approach', 'summary', 'confidence'],
}

const RUBRIC = `You are assessing one Rosetta Code task for Silver, a language being designed as a subtractive profile of SPARK (Ada 2022) under an Oracle. The aim is to plan how Silver's surface grows, one Rosetta sample at a time in order of increasing complexity, to its natural conclusion under the Oracle. Judge whether a Silver program solving this task could be written so that its proofs would likely discharge automatically. No tools are run; this is an expert judgment.

The Oracle's rules for every Silver program:
1. A Silver program is ordinary Ada/SPARK source. Silver only removes or restricts constructs; it never adds syntax or changes meaning.
2. Every admitted program must prove automatically, with no developer intervention, at SPARK's Bronze level (initialization and data flow) and Silver level (absence of run-time errors: no overflow, range, index, length, division-by-zero or discriminant check can fail, no unexpected exception is raised, no assertion fails).
3. Program authors write no contracts or proof annotations of any kind (no Pre, Post, Contract_Cases, Global, Depends, Loop_Invariant, Loop_Variant, Subprogram_Variant, Always_Terminates or Side_Effects) and no pragma except pragma SPARK_Mode (On). Safety must follow from declarations, types, expressions and executable control flow (explicit guards wherever necessary), plus the verified contracts of admitted library operations.
4. Proof must never be obtained by silently changing behavior, narrowing the input domain or suppressing checks. A guard must lead to a specified, visible outcome (for example rejecting an input), never quietly alter a result the task requires.
5. Guarantees cover every permitted input and execution path: input is validated and invalid input has a specified outcome.
6. External effects happen only through admitted library operations with specified behavior, failure outcomes and environmental assumptions.
7. Explicit, documented resource limits are allowed: bounded strings and arrays, integer ranges, fixed-capacity big numbers.
8. Constructs SPARK excludes, such as unrestricted aliasing and backward goto, are never available. SPARK 16.1 permits forward goto and handlers for expected explicit raises within a subprogram; handlers cannot excuse failed language-mandated checks. Silver currently excludes local exceptions because their admission, initialization and path-fact composition rules are not established, and excludes goto because its control-flow rules are not established; these are scope exclusions, not permanent Oracle conflicts. An exception propagated from a program-defined called subprogram needs an Exceptional_Cases annotation in that subprogram, forbidden to Silver program authors by rule 3.

What GNATprove establishes without annotations decides the outlook:
- With no loop invariant, after the first iteration it knows only the types of the variables a loop modifies. A check on a loop-carried value (an accumulator, a computed index) discharges only if that value's type range, or a guard just before the use, makes it safe.
- Checks that follow from declared ranges, static bounds, for-loop indexes over an array's own range, and conditions tested just before the operation discharge reliably.
- Nonlinear integer arithmetic and floating point are harder for the provers. They discharge when types or guards bound the operands so that results cannot overflow.
- Every loop and call inside a function (a subprogram without side effects) gets a termination check. For loops terminate by themselves, but while loops and recursive calls need a variant annotation, which Silver authors cannot write. Procedures get no termination check.
- Functions cannot have side effects (that needs the Side_Effects annotation), so input and output happen in procedures.
- GNATprove does not check stack or heap exhaustion (Storage_Error). Recursion whose depth depends on input, and heap allocation, leave that risk outside any proof; Silver treats sufficient memory as a fixed environmental premise, which does not cover unbounded depth.
- SPARK permits tasks and protected objects only when the Ravenscar or Jorvik profile is specified, which takes a pragma that Silver source cannot contain.

Silver today supports only: a parameterless Main procedure with pragma SPARK_Mode (On); with and use clauses for Silver_IO and Silver_Arguments; String literals, String constants and fixed-length String variables with equal-length assignment; bounded concatenation; String equality and 'Length comparisons with integer literals; Boolean conditions with and then, or else and not; if, elsif and else; statement sequences and null; output with Silver_IO.Put_Line, and with Silver_IO.Put, which writes no line terminator; the first command-line argument through Silver_Arguments.First_Or_Default, with Input_Is_Valid and Reject; immutable signed 32-bit Integer constants and interval-checked scalar comparisons and arithmetic using +, -, *, /, mod, rem and unary signs; explicitly initialized mutable Integer objects and optional static object-local Integer range constraints; named nonempty static Integer range subtypes, with direct Integer parents, used by initialized scalar objects and fixed-array components; assignments whose full RHS interval is nonempty and lies in the target declared range; inclusive ascending and reverse Integer for loops, including nesting and immutable index references; standard Integer'Image with bounded result lengths and Ada's leading space for non-negative values; and anonymous one-dimensional constant or mutable Integer arrays with nonempty Ada-static bounds and mandatory explicit initialization (positional for multiple components, (L => E) for a singleton). Array reads and indexed writes require scalar-only subscripts whose nonempty inferred intervals fit the declared bounds, even in unreachable arms and empty loops. Declaration reads retain exact initialized snapshots, while body reads use declared component intervals, including constant arrays (full Integer for of Integer); guards do not refine individual elements. Indexed writes use the incoming state, preserve other components and existing scalar/String facts, and do not change previously captured loop bounds. Forward and reverse foreach loops use for E of [reverse] A over a visible existing constant Integer array, visiting each actual component once in index order. The iterable identity and bounds are captured on entry. Elements are immutable and nonstatic with declared component entry bounds; existing bare-name scalar guards may refine them within an iteration. Scoped hiding follows the index rules: the new binder is unavailable in its own iterable specification, and hiding an array spelling later does not change its captured identity. Mutable scalar facts widen on loop entry and exit; outer immutable and enclosing-loop facts are restored on exit, element facts do not carry between iterations or escape, and nonempty-array String/input flow retains body exit facts. Existing body statements, including nested loops, writes to other mutable objects and Reject, compose with iteration. Named array types, dynamic or null arrays, array attributes, whole-array operations, mutable iterables, element writes, subtype indications, filters, slices and general iterators remain outside this fragment. Every binary scalar arithmetic operation and every unary sign on a nonliteral needs explicit grouping; a signed numeric literal may stand alone, but a signed binary operand must be grouped, as in ((-1) + 2) or (1 + (-2)). Declaration initializers use exact earlier values, including immutable snapshots copied from mutable objects or initialized array components; later component writes preserve those snapshots. The delivered scalar-guard refinement begins mutable body reads at declared ranges (full Integer when unconstrained), then assignments replace only the target current interval after declared-range containment checks. Comparisons refine only bare mutable names, loop indexes or foreach elements against Ada-static singleton thresholds in either order; parenthesized scalar names, arithmetic targets, nonstatic snapshots and variable-to-variable comparisons do not refine. Both operands are checked first; an empty refinement retains incoming bounds, and disequality cannot represent an interior hole. Whole-condition grouping, not, branch hulls and reached short-circuit flows compose these facts, including Image arguments within String expressions. Scalar impossibility does not prune input/String facts. String writes preserve scalar flow, and scalar writes preserve already established immutable-input-length facts without retaining a relation to later live Images. Loops capture bounds in entry flow, then widen all mutables for body entry and possible execution exits while restoring entry immutable and enclosing-loop facts; empty range loops restore entry flow. More precise bounds can reveal an empty index-dependent assignment RHS, intentionally excluded by the retained nonempty rule. These delivered rules and their assurance and validation evidence are recorded in docs/scalar-guard-refinement.md, including retained regression results and focused repair validation; interval division delivery is recorded in docs/integer-division.md, the fixed-size Integer-array scope and assurance/validation status are recorded in docs/fixed-integer-arrays.md, constant-array iteration is recorded in docs/constant-array-iteration.md, and named Integer subtypes and bounded components are recorded in docs/named-integer-subtypes.md. Constraint endpoints must be Ada-static, so a constant copied from a mutable object cannot supply one. Integer assignments require a nonempty inferred RHS interval even inside an empty loop, because the pinned frontend still checks predictable assignment range errors there under SPARK_Mode (On). Loop endpoints are evaluated on entry, and loop indexes remain immutable. Division truncates toward zero; mod has the divisor sign and rem the dividend sign. Each nonempty divisor interval must exclude zero, including before empty-operand propagation. Quotient rejects Integer minimum divided by -1; mod and rem permit the zero result for that pair. Exact singleton operands retain exact values; non-singleton modulo and remainder use sound sign/magnitude bounds. The shared source budget remains 63 operators in at most 4096 bytes. Independently, each expression permits at most 64 operands; an indexed array atom counts its array name plus every subscript operand toward that limit. Subtype alias chains, derived types, conversions, subtype attributes, abs, exponentiation, general discrete iteration and non-Integer scalar images remain future surface.

Silver also supports initialized scalar Boolean constants and variables, assignment, visible predefined True and False, not, eager and/or/xor, short-circuit and then/or else and Boolean equality/inequality, composing with the existing checked predicates, strings, scalars, arrays and loops. Neither operand of xor may contain xor; independent xor expressions remain permitted. This explicit restriction avoids repeated formula multiplication in the pinned proof producer and is not an Ada restriction. Eager operands are both checked under incoming facts; only short-circuit forms pass the appropriate path facts to their right operand. Stored flags carry values without retaining earlier predicate relations. Predefined names follow Ada visibility and hiding. The source, operator and leaf budgets remain unchanged. The precise Rosetta identifier is scalar-boolean-objects; Boolean arrays, Boolean subtype declarations, Boolean Image, ordering, enumeration iteration and user routines remain outside it. Broad booleans still includes Boolean-valued functions and remains unsupported. The three driver mappings and the contingent delivery status of this unmerged metadata patch are recorded in rosetta/assessment-boolean-objects-20261030.md.

Plan the most Silver-friendly faithful program: iteration rather than recursion, arrays rather than pointers, for loops where they fit, while loops only in procedures, a deterministic pseudo-random generator rather than system randomness, text or file output rather than a display, and fixed bounds sized for the outputs the task requires. Treat optional and extra-credit parts as optional. When a task asks to draw, plot or render a picture without requiring a window or an on-screen display, text art or an image file meets it. The existing solution is only evidence of what the task involves; it is not Silver and need not be followed.

Use the smallest surface that keeps the program faithful: prefer what Silver already supports and the plainer of two equivalent constructs (if statements rather than conditional expressions, ordinary declarations rather than declare blocks, comparisons rather than membership tests), and embed the task's example data in the program unless the task requires reading input.

Report only what the program you settled on needs. Never list an item and then explain that it is not needed, not real or only an alternative; leave it out instead. Base conflicts only on what the task requires, never on how the existing solution happens to be written.

Fields:
- conflicts: requirements that break a fixed Oracle rule, so that no future Silver could meet them. Kinds: runtime-error (the task requires demonstrating or observing a failed run-time check, an unexpected exception, overflow behavior, undefined behavior, or stack or memory exhaustion), annotations (the task requires assertions, contracts, pragmas or other compiler directives in program source, including Exceptional_Cases for required cross-call exception propagation), outside-spark (the task requires something Ada/SPARK cannot express, such as evaluating code at run time, reflection or introspection of program structure, dynamic typing, closures, handling unknown method calls, self-modifying code or extending the syntax), unsafe (the task requires unchecked conversion, address arithmetic, unrestricted aliasing, foreign-language calls or machine code) and other (explain). A locally handled explicit raise is local-exceptions surface, never a conflict by itself. Needing an external effect Silver lacks is an effect, never a conflict. Leave conflicts empty when the task only needs constructs or effects Silver does not have yet.
- effects: every external effect the program needs, each with a short explanation: console-output, arguments, exit-status, stdin, files, directories (listing, creating or inspecting directories or file metadata), clock, delay, entropy (system randomness, only when a deterministic generator would not satisfy the task), environment, processes, terminal (cursor control, colors, screen size, raw keystrokes), gui, graphics (drawing on a display), sound, network, hardware, os-services or other.
- surface: every construct or library operation beyond today's Silver that the program needs, from this list:
${Object.entries(SURFACE).map(([id, text]) => `  ${id}: ${text}`).join('\n')}
  List recursive-procedures, recursive-functions, access-types or tasking only when the task requires them, not when the program could avoid them.
- outlook: likely when every check follows from types, static bounds and guards placed just before the operation; plausible when discharge depends on careful program shape (many loop-carried values need guards, nonlinear or floating-point arithmetic needs range guards, or fixed-capacity big numbers carry arithmetic through loops) but nothing needs an annotation; unlikely when the program needs a fact only an annotation could supply (a variant for a loop or recursive call inside a function that cannot be restructured into a procedure, or a bound that only an invariant could establish and no guard can express without changing required behavior), or depends on recursion depth or heap use that grows with input, or on tasking.
- risks: the proof obligations that are not routine for this program, each explaining how the program discharges it or why it would not. Use overflow, range, index, division, length, discriminant, initialization, termination, stack, heap, floating-point, tasking or other. Leave it empty when every check is routine.
- size: the estimated number of lines of the Silver program.
- approach: two or three sentences describing the program: its data representation, control flow and guards.
- summary: one or two sentences a reader can check, explaining the outlook.
- confidence: high, medium or low.
Keep every explanation to one sentence.

Use only the Read tool, on the files named below, reading at most the first 400 lines of each. Do not run commands (in particular no Lean, GNATprove or test runs), write files or browse the web.`

function prompt(t) {
  const files = t.files.map(f => `- ${ROOT}${t.path}/${f}`
    + (f === 'task.wiki' ? ' (the task description)' : ' (an existing solution, as evidence only)')).join('\n')
  return `${RUBRIC}\n\nTask: "${t.title}" (a Rosetta Code ${t.status}). Files:\n${files}`
}

function run(t, tier, phase) {
  return agent(prompt(t), { label: `${tier}:${t.title}@${t.revision}`, phase, schema: SCHEMA,
                            model: TIERS[tier].model, effort: TIERS[tier].effort })
}

function escalation(t, r) {
  if (!r) return t.tier
  if (t.tier === 'deep') return null
  if (r.confidence === 'low' || r.outlook === 'unlikely' || r.conflicts.length > 0) return 'deep'
  return null
}

const start = (args && args.start) || 0
const end = (args && args.end) || TASKS.length
const chosen = TASKS.slice(start, end)
log(`Assessing tasks ${start} to ${start + chosen.length - 1} of ${TASKS.length}`)
const outcomes = await pipeline(chosen,
  t => run(t, t.tier, 'Assess').then(r => ({ t, r })),
  ({ t, r }) => {
    const tier = escalation(t, r)
    if (!tier) return { done: !!r, escalated: false }
    return run(t, tier, 'Escalate').then(x => ({ done: !!(x || r), escalated: true }))
  })
// Results are read from the run's journal by `assess.py import`, so only counts come back here.
const finished = outcomes.filter(o => o && o.done)
return { tasks: chosen.length, finished: finished.length,
         escalated: finished.filter(o => o.escalated).length, missing: chosen.length - finished.length }
