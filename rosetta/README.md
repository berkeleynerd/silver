# Rosetta Code solutions

Task descriptions and selected solutions from [Rosetta Code](https://rosettacode.org),
one directory per task, grouped by first character like the sections of
[rosetta.md](../rosetta.md), which also has the counts.
[manifest.json](manifest.json) records when the pages were retrieved and the
revision each task came from.

Each task directory holds:

- `task.wiki`: the task description;
- `<language>.wiki`: the solution section as written on the page, including
  notes and sample output;
- `<language>-page.wiki`: the solution's own page, when Rosetta Code keeps the
  solution on a separate subpage. Its code blocks follow the section's;
- `<language>-<n>.<ext>`: the code blocks in page order. Ada and SPARK blocks
  use `.ada`, FreeBASIC `.bas` and Phix `.exw`. Output and other blocks use
  their own extension, or `.txt`;
- `silver.md`: the task's Silver assessment, described below.

Subtasks such as Sorting algorithms/Bubble sort sit in nested directories.

The solution is the page's Ada section, plus its SPARK section where one
exists. Tasks without Ada use FreeBASIC, or Phix where FreeBASIC is missing
too.

Code is copied verbatim. One Rosetta Ada block can hold several compilation
units, so blocks keep the `.ada` extension; `gnatchop` splits a block into
`.ads` and `.adb` files. None of this is Silver source, and the build, proof and
sample checks don't read this directory.

## Silver coverage

`coverage.json` records, for each task, how a program solving it could be
written in Silver as the [Oracle](../oracle.md) envisions it: ordinary SPARK
source whose Bronze and Silver proofs discharge automatically, with no
author-written annotations and external effects only through specified library
operations. One agent per task read the task and its solution and recorded:

- conflicts with the Oracle's fixed rules, such as a task whose point is a
  failed run-time check, an unexpected exception or code evaluated at run time;
- the external effects the program needs, such as console output, files, the
  clock or a GUI;
- the language surface it needs beyond today's Silver, from the fixed list of
  constructs and library operations in `assess.js`;
- its proof outlook: likely, plausible or unlikely to discharge automatically,
  with the obligations at risk;
- its approach and estimated size.

A task is a candidate when it has no conflicts and needs only the effects the
`policy` in `coverage.json` allows: by default console output, command-line
arguments, exit status, standard input and named files. Constructs listed in the
policy's `excluded_constructs` also exclude a task. Candidates whose outlook is
likely or plausible are ordered in `progression.md`, starting from today's
Silver: each step takes the sample whose new constructs the most remaining
samples need, on average, then the one needing the fewest new constructs,
preferring likely proofs, then the shortest program. An assessment with optional
`assessment_status: "design-pending"` has no progression stage: a faithful
program design has not been established, so its missing surface and size are
not asserted. This status records an unresolved design, not an Oracle conflict
or a proof failure. Each stage of the
progression:

- states the admission question for every construct it adds, the decidable rule
  under which every program using that construct proves automatically, with
  the obligations its samples flag and how many are only plausible;
- when it adds an input construct (text parsing, standard input, files, exit
  status or further arguments), is driven by a sample that really uses that
  input, lists such samples first and names the failure paths they must test.

The current policy excludes `local-exceptions` because Silver has no admission,
initialization or path-fact composition rules for exception handlers yet. This
is a scope exclusion: SPARK 16.1 permits locally handled explicit raises and
forward `goto`. Handlers cannot excuse failed language-mandated checks, and
required propagation across program-defined calls needs `Exceptional_Cases`, an
annotation Silver authors cannot write. The [targeted review](review-343c2f8.md)
records the corrected assessments and the pinned-manual references.

The `supported` list in `coverage.json` names constructs Silver has admitted
since the assessments, using the identifiers in `assess.js`; the progression
starts from them. When a milestone admits a construct, add it there and keep
the description of today's Silver in `assess.js` in step.

Each task's `silver.md` explains its verdict, position and failure paths, and
`rosetta.md` marks it. After editing the policy or the supported list, run
`python3 rosetta/refresh.py --render` to update them without reassessing.

Agents ran at a tier chosen from the task's title and Rosetta Code tags: Claude
Opus at high effort near the Oracle's limits, such as exceptions, overflow,
pointers and concurrency, and Claude Sonnet at medium effort otherwise. Opus
re-checks any Sonnet verdict that claims a conflict, an unlikely outlook or low
confidence. Tasks excluded by a conflict or by the effects policy keep their
earlier, shorter assessment, which has no outlook or order.

To assess new or changed tasks after a refresh:

1. run `python3 rosetta/assess.py prepare --output FILE`;
2. run FILE with Claude Code's Workflow tool, once per `args` value it prints
   (each run covers up to 800 tasks);
3. run `python3 rosetta/assess.py import RUN_DIR` with each run's transcript
   directory;
4. run `python3 rosetta/refresh.py --render`.

A verdict whose page has changed since it was assessed is marked stale.

A curated task's optional `review` object records a later targeted review while
preserving the original `assessed`, `revision`, `tier`, `model` and `effort`
attribution. Its `date` and `record` fields supply the rendered revision date
and review link; `record` is relative to `rosetta/` and may include an anchor.
The optional `model`, `effort`, `setting_evidence` and `method` fields retain
review provenance in the JSON; the renderer does not display them. When a later
review replaces this object, preserve earlier review provenance in the linked
record. Review dates and methods describe the actual review, while current
summaries and delivery links describe delivered support and evidence at their
recorded scope.

## Refreshing

`python3 rosetta/refresh.py` downloads the current revisions and rebuilds the
task directories, `manifest.json`, the `silver.md` files and `rosetta.md`. It
regenerates each group directory (`0-9`, `a` through `z`) in full, including
deleting any manually added files inside those directories. Keep local additions
outside the groups. This README, the scripts and `coverage.json` are kept.
Required cached task and solution-subpage pages are read before the existing
groups and manifest are removed, so missing or unreadable pages leave that output
intact. Cache metadata errors are reported before that removal as well.
A full download fetches about 220 MB of page text. Pass
`--cache DIR` to keep pages between runs, so later runs fetch only pages that
changed; add `--offline` to rebuild from that cache without contacting Rosetta
Code.

The scripts live here rather than in `scripts/` because the proof-provenance
record hashes every Python file there.

## License

Rosetta Code content is available under the
[GNU Free Documentation License 1.3](https://www.gnu.org/licenses/fdl-1.3.html).
Each task's page history lists its contributors.
