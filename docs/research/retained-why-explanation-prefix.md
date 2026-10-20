# Selected GNATwhy3 explanation-prefix configuration

2026-10-20, research [#119](https://github.com/berkeleynerd/silver/issues/119)
and [#153](https://github.com/berkeleynerd/silver/issues/153). The selected
source route keeps `Termcode.expl_prefixes` equal to `["expl:"; "infer:"]`.
Thus **p=2** can instantiate the accepted
[explanation-byte transfer](retained-why-session-shape-transfer.md#explanation-bytes-are-a-separate-interface)
under the existing relevant-source-behavior and preservation premises. This
is a source/configuration argument, **not a captured native value** of that
reference, complete save capacity or a new installed-source identity claim.
Independent review is required before acceptance.

The [small retained checker](../evidence/retained-why-explanation-prefix-20261020/README.md)
joins both original plans to all five process argv records, checks both
14-file driver import closures against their retained bytes, inventories the
complete retained Why3 OCaml source corpus, and instantiates the existing
E(p) transfer. It neither reruns opening/binder analysis nor starts a tool.

## Why the selected route cannot add a prefix

At retained Why3 `9390baf120ef260547dfa14f08e11c890b203d9c`:

1. `src/session/termcode.ml:20–32` initializes a private reference with two
   strings and defines its only setter. The Arg and Getopt wrappers register
   this setter as an option callback; constructing a wrapper does not call it.
   The interface `termcode.mli:13–22` exposes the setter and wrappers, but not
   the reference itself. Explanation extraction only reads the list
   (`termcode.ml:35–99`); it does not change it.
2. The reproducible census covers **556** retained `.ml`, `.mli`, `.mll` and
   `.mly` files under Why3 `src/` and `plugins/`. The setter name occurs only
   in its implementation and interface. Wrapper users outside those files
   are the three other command frontends: `why3ide.ml:175`, `why3web.ml:138`
   and `why3prove.ml:176`. None is the selected GNAT command parser or a
   selected plugin. The selected parser uses its own literal option table,
   followed by `Arg.parse options set_filename usage_msg`
   (`gnat_config.ml:171–267`); it includes no extra-prefix callback.
3. All five actual argv records request `--prover cvc5,z3,altergo` and match
   their retained plan entries. Those names are builtins under
   `gnat_config.ml:12–19,291–306`. The environment builder consequently
   receives `load_plugins=false` (`gnat_config.ml:345–399`). This still loads
   **gnat_json and ada_terms** (`gnat_util.ml:110–116`); their retained source
   is included in the census. It does not load the user-configured plugin
   list. The two retained extra configuration files contain only
   `[main]` and `magic = 14`.
4. Driver loading is a separate possible dynamic-code route:
   `driver.ml:53–56,144` executes a driver `Plugin` declaration. Both retained
   selected import closures contain 14 files and have no `plugin` token,
   even in comments/strings. The lexer recognizes that literal keyword and
   the grammar requires it for a Plugin declaration
   (`driver_lexer.mll:47`, `driver_parser.mly:76`). Every import has the single
   previously established candidate, and the closure bytes hash-equal the
   original plan and driver-resolution records. Therefore this selected
   driver route loads no additional plugin capable of registering a prefix.

This argument uses the established selected-command/configuration route,
including its plugin and driver identities. Under faithful behavior of that
source family and absence of arbitrary foreign writes, initialization is
followed by no reachable prefix mutation. Signals and ordinary saves can
read the list; the selected handlers have no setter call. This also excludes
a new unaccounted configuration/plugin load later in the continuation. It
does not infer preservation from an argv string alone, or assert that a token
census proves arbitrary native code harmless. Any changed command, plugin,
driver closure or relevant native behavior requires rechecking this join.

The relevant source/native behavior relation remains an explicit premise,
as in the prior fixed-forest/save transfers. No exact historical installed
SPARK revision has been established, and this packet does not discharge that
premise merely by matching source hashes. Native observation of the private
prefix reference remains absent. There is no requirement here to reproduce
an already accepted capture just to obtain that observation.

## Numeric transfer

With complete typed attribute closure, u is the number of attribute strings,
s their total bytes, and G the number of APn visits. Reuse the accepted rule:

```
E_one = max(11, 2 * (s + 2*u) + 1)
E_save = G * E_one
```

| Process | u | s | G | E_one, bytes | E_save, bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 195 | 4,102 | 65 | 8,985 | 584,025 |
| Put | 171 | 3,394 | 54 | 7,473 | 403,542 |
| First_Or_Default | 193 | 3,470 | 33 | 7,713 | 254,529 |
| Is_Message | 42 | 679 | 4 | 1,527 | 6,108 |
| Input_Is_Valid | 44 | 700 | 5 | 1,577 | 7,885 |

These are mathematical upper bounds for directly inserted explanation strings,
not measurements. Explanations are not appended to `Shape.shape_buffer`, so
the accepted L values do not change. Existing `derive` behavior is retained:
without p or without complete attribute closure, numeric E remains unknown.
The checker verifies both missing-input cases for each forest.

The four registration snapshots and prior Input_Is_Valid first-inline snapshot
remain phase-distinct. This configuration result does not attach their forests
to every later save entry, establish initial dictionaries/Buffer storage or
complete mutable-table traversal, XML/compression/formatter capacities,
identifier histories or whole-pipeline coverage. Those remain #153/#119 work.

## Work and checks

The lead authored this source/configuration join within the existing research
round; live lead model/effort and per-author token measurements are unavailable.
No source fetch, native capture, compiler, prover, solver or Lean execution was
performed. The preliminary focused check took 4.824752233 seconds; the final
check record includes the added lexer/parser corpus and keyword check. Whole
round accounting and the combined independent review belong to the existing
[round record](../evidence/retained-tool-rounds.md).
