# Original specification formal modes

Run `20261127T182715-47e3d0ea2521` passed the focused Linux x86-64 target
`Silver.ApplicationPackageSourceFormalModes` and a fresh audit of 31,819
imported declarations. The run used two managed workers, two Lean threads
per process and an 8192 MiB process threshold. The unchanged native source
identity and retained evidence hashes are in [index.json](index.json).

The original specification derives every active formal's physical table bound
and the input-only mode for functions. Declaration-field preservation carries
these facts through each completion, including its actual body-prefix context,
and into the exact metadata supplied to Main. The fold includes every routine,
independently of whether it is called. No whole-bundle metadata-validity premise
is added to a body-prefix call. The routine-start table projection is also
checked with its consumer.

This is focused model/source-history evidence. The native typed interpretation
is connected separately; original executable/initializer decoding, complete
obligation coverage, external automatic completion and complete validation
remain open. No package-support or feature-completion claim follows from this
check.

The first focused attempt failed on Lean type elaboration of declaration
projections and inferred row binders. Explicit projections and binder types
fixed those errors without changing the theorem's domain. Its failed log
remains in the managed run record and private scratch. The successful build
phase took 4.057 seconds and its fresh audit 3.386 seconds. Selected agent
configuration was GPT-6 Astra Max; runtime-confirmed model/effort and total
agent token/cost measurements were unavailable.
