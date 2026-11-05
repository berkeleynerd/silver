# Learning Silver on this Mac

Build and run your first Silver program, then learn Strings, command-line input,
bounded Integers, loops, arrays and Booleans through small working examples.
Silver is a restricted form of Ada/SPARK: you write ordinary source, and the
compiler checks language membership before automatically proving and building it.

These instructions target Rebecca's Apple Silicon Mac and zsh checkout at
`/Users/rebecca/src/github.com/berkeleynerd/silver`. Follow the numbered sections
in one terminal. The [language specification](../language.md) supplies the exact
rules; this tutorial introduces them in learning order.

The tutorial branch starts from `feat/string-indexing` at `e587e7be`.
String indexing, Character values and slices are under repair in
[PR #307](https://github.com/berkeleynerd/silver/pull/307); the final optional
section describes that development work separately. Its complete repaired
validation is still pending.

## 1 Check the host and choose the checkout

Open Terminal with zsh and paste:

```sh
silver_repo=/Users/rebecca/src/github.com/berkeleynerd/silver
silver_python=/opt/homebrew/bin/python3
cd "$silver_repo"
uname -sm
"$silver_python" --version
xcode-select -p
"$silver_python" scripts/dev.py paths
```

On this host, inspected on 2026-11-05, these select Darwin arm64, Python 3.15.2,
Xcode at `/Applications/Xcode.app/Contents/Developer`, and Silver host key
`macos-aarch64`. Python 3.11 or newer is required. This Mac already has Python
and Xcode; there is no prerequisite installation to repeat here.

The paths command shows where the tools, compiler and application workspaces
live. Native tools belong in `.tools/macos-aarch64/`, with generated files and
programs in `.silver/macos-aarch64/`. Other hosts have separate directories.
An existing Linux installation does not supply a runnable Mac compiler.

If using a different checkout, adjust `silver_repo` first. If Python is elsewhere,
use `command -v python3` to find it and set `silver_python` to that absolute path.
If `xcode-select -p` fails on another Mac, run `xcode-select --install`, finish
the Apple installer, and repeat the check before continuing.

## 2 Install the tools and build Silver

Read the native managed-run summary before building. If it reports an active
writer using the compiler workspace, let that run finish first.

```sh
"$silver_python" scripts/dev.py runs status --limit 3
"$silver_python" scripts/bootstrap.py
"$silver_python" scripts/dev.py build --jobs 2 --task tutorial-macos
```

Run each command after the preceding one succeeds. Bootstrap downloads the
pinned tools through Alire and reuses installed packages on subsequent runs.
The build reserves two workers. Internet access is needed for the first install;
this repository does not require a global Alire or GNAT installation on `PATH`.
Use bootstrap as shown: it performs setup even if passed `--help`.

The native setup here installed Alire 2.1.1, GNAT 16.1.0, GNATprove 16.1.0 and
GPRbuild package 26.0.1 (whose executable reports 26.0.0). Downloads and generated
artifacts stay in the ignored host directories.

This builds the development compiler. Each later `silver compile` or `silver run`
performs application and selected-library verification. Compiler-wide SPARK and
Lean assurance checks are the separate [developer workflow](../development.md);
they are not a first-program setup step.

After switching to a branch with compiler/runtime changes, or moving the checkout,
repeat bootstrap and build before trying that source. The executable records its
installation paths and expected runtime source bytes.

## 3 Add a convenient command

Paste this into the same zsh session:

```sh
silver() (
  local silver_bin
  silver_bin=$("$silver_python" "$silver_repo/scripts/dev.py" paths --field executable) || return
  if [[ ! -x "$silver_bin" ]]; then
    print -u2 'Silver is not built. Complete tutorial step 2 first.'
    return 127
  fi
  ulimit -s 8192 || return
  "$silver_bin" "$@"
)

silver check "$silver_repo/samples/hello_world.adb"
```

The check should print `Accepted: silver.`. The function finds the native binary
through `dev.py paths`, forwards arguments without losing quoting, and keeps the
caller's working directory. Its subshell sets an 8 MiB stack for Silver and its
children without changing the parent shell. That setting was exercised on this
Mac for the tutorial examples; it is not a worst-case resource bound.

From another directory, use an absolute source path or a path relative to that
directory. For example:

```sh
cd /private/tmp
silver check "$silver_repo/samples/hello_world.adb"
cd "$silver_repo"
```

### Keep the command in future terminals

The function above lasts for this terminal session. To make it persistent, open
your zsh configuration in an editor:

```sh
nano "$HOME/.zshrc"
```

Add the two `silver_repo` and `silver_python` assignments from step 1 followed by
the complete `silver() (...)` definition above, once. Preserve existing settings.
Save, then open a new terminal or run `source "$HOME/.zshrc"`. If you already
have a command named `silver`, use a different function name consistently.
The tutorial does not require exporting these variables or altering `PATH`.

### Choose the operation you need

| Command | What it does |
| --- | --- |
| `silver catalogue` | Prints the machine-readable language catalogue. |
| `silver check SOURCE` | Checks membership without starting a prover. |
| `silver compile SOURCE` | Checks, proves, audits reports and builds an application. |
| `silver run SOURCE -- ARGUMENTS` | Compiles as above, then runs with those arguments. |

`compile` prints `Source:`, `Proof:` and `Executable:` paths in a fresh
`.silver/macos-aarch64/program-XXXXXX/` directory. To run a compiled program again,
copy its actual `Executable:` path, quote it, and append application arguments
directly. Do not include Silver's `--` separator when invoking that executable.
This avoids another proof/build cycle when only the input changes.

For example, after compiling `samples/command_line_greeting.adb`, set
`silver_app` to the printed executable path, then use `"$silver_app" Ada`.
The executable paths vary each time; do not reuse a path from somebody else's
transcript.

Create a separate directory for your own exercises. This gives you a fresh path
without changing the checked-in samples:

```sh
silver_lessons=$(mktemp -d "${TMPDIR:-/tmp}/silver-lessons.XXXXXX")
printf 'Exercise directory: %s\n' "$silver_lessons"
```

Keep this terminal open so the variable remains available. macOS may eventually
remove temporary files; copy exercises you want to keep into your own project
directory.


## 4 Run your first program

The remaining commands assume that the setup above defined the `silver` zsh function,
`$silver_repo`, and `$silver_lessons`. Keep the same terminal open:

```sh
cd "$silver_repo"
silver check samples/hello_world.adb
silver run samples/hello_world.adb
```

The sample's complete source is:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
begin
   Silver_IO.Put_Line ("Hello, world!");
end Main;
```

Application output:

```text
Hello, world!
```

`with Silver_IO;` makes the output package available. `Main` is the program's single procedure.
Declarations go between `is` and `begin`; statements go between `begin` and `end Main;`. `Put_Line`
writes a String followed by a newline. The semicolons end declarations and statements.

Silver programs are actual Ada/SPARK source, with this one pragma and no additional proof
annotations. Sources have 1 to 4096 bytes, including comments and whitespace. Save plain ASCII text
without a byte-order mark or smart quotes; tabs and line endings are also permitted. See the [source
rules](../language.md#source-and-lexical-rules).

`check` decides membership without invoking a prover. `compile` admits, proves and builds a byte-identical source snapshot and its selected libraries. `run` adds execution. Output blocks here show
application output, excluding Silver's build/proof diagnostics. Another `run` repeats the
proof/build cycle; use its printed executable path to repeat a built application directly.

Expected sample output comes from [the manifest](../samples/manifest.json). Examples do not
establish universal assurance; see [assurance](assurance.md) and the [trusted boundary](trusted-boundary.md).

## 5 Keep a snapshot, then change a String

Run the next sample:

```sh
silver run samples/shared_bindings.adb
```

Application output:

```text
Before: draft; copied: draft; current: ready
```

Here is the complete source:

```ada
with Silver_IO;

procedure Main is
   pragma SPARK_Mode (On);
   Original : String := "draft";
   Saved : constant String := Original;
   Working : String := Saved;
   Approved : constant String := "ready";
   Prefix : constant String := "Before: ";
begin
   Original := Approved;
   Silver_IO.Put_Line
     (Prefix & Saved & "; copied: " & Working & "; current: " & Original);
end Main;
```

Declarations run in order. `:=` initializes an object or assigns a new value. `constant` prevents
later assignment. Omitting it permits assignment. `Saved` and `Working` copy the current bytes of
their initializer; neither becomes an alias that follows later changes to `Original`. `&` joins
Strings.

`Original` starts with five bytes and retains its fixed bounds. Assigning the five-byte `"ready"` is
permitted; assigning four-byte `"done"` would be outside Silver. See the [declaration
rules](../language.md#ordered-declarations-names-and-copies) and [assignment
rules](../language.md#statement-sequences-and-fixed-bound-assignment).

## 6 Read one command-line argument safely

Run these commands one at a time:

```sh
silver run samples/command_line_greeting.adb
silver run samples/command_line_greeting.adb -- Ada
silver run samples/command_line_greeting.adb -- ""
```

Their application output, in that order, is:

```text
Hello, world!
Hello, Ada!
Hello, !
```

`--` separates Silver's arguments from the application's arguments. Quoting an empty String forwards
one empty argument; omitting arguments uses the default. The sample's complete source shows both
checks required before this greeting:

```ada
with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Name : constant String := Silver_Arguments.First_Or_Default ("world");
begin
   if Silver_Arguments.Input_Is_Valid
     and then Name'Length <= 4088
   then
      Silver_IO.Put_Line ("Hello, " & Name & "!");
   else
      Silver_Arguments.Reject;
   end if;
end Main;
```

`First_Or_Default` initializes immutable input before the body runs. `Input_Is_Valid` checks the
input contract. `and then` evaluates the right side only when the left side is true. `Name'Length`
counts bytes: eight greeting bytes plus at most 4088 input bytes respect the 4096-byte String-expression limit.

With no argument, the initializer selects its default. With exactly one
argument, it accepts 0 through 4096 printable ASCII bytes. Extra arguments,
oversized arguments and nonprintable bytes make the input invalid. This greeting
also rejects otherwise valid input longer than 4088 bytes to leave output space.

Try an invalid argument count:

```sh
silver run samples/command_line_greeting.adb -- one two
printf 'exit status: %s\n' "$?"
```

The application produces no stdout or stderr and returns status 1; the `printf` line therefore
prints `exit status: 1`. Silver additionally reports `Execution returned status 1.` as a driver
diagnostic. Both argument boundaries matter: `-- "one two"` would pass one argument instead.

`Reject` records failure and returns to the following statement. Keep output in the valid branch:
placing an unconditional greeting after `end if;` would still allow invalid input to reach it. Every
possible invalid-input path must reject and make no output call. See [command-line path
requirements](../language.md#command-line-initialization-and-path-requirements).

## 7 Calculate with Integers and counted loops

Read and run [the step sample](../samples/for_loop_step.adb):

```sh
silver run samples/for_loop_step.adb
```

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Step : constant Integer := 2;
begin
   for I in 1 .. 5 loop
      Silver_IO.Put_Line (Integer'Image ((I * Step)));
   end loop;
end Main;
```

Application output:

```text
 2
 4
 6
 8
 10
```

The inclusive range `1 .. 5` visits five values. `I` is an immutable loop index, available only
inside this loop. There is no explicit step syntax here; the multiplication calculates the desired
value. Binary arithmetic is fully parenthesized: write `(I * Step)`, not `I * Step`. `Integer'Image`
converts the Integer result to decimal String bytes, including a leading space for a nonnegative
value. That space explains the indentation in the output.

For a descending loop, [the countdown sample](../samples/for_loop_countdown.adb) uses `for I in
reverse 0 .. 10 loop`. `reverse` changes the visitation order of the same inclusive range; it does
not swap endpoints. A lower bound greater than the upper bound performs no iterations in either
direction. Bounds are captured on entry; the current fragment has no `while` or `exit`. See [counted
loops](../language.md#scoped-finite-for-loops) and [Integer Image](../language.md#standard-integer-image).

Every intermediate must fit Integer: -2147483648 through 2147483647. Admission tracks intervals;
mutable objects initially contribute their declared ranges in the body. Selected direct guards and
assignments can narrow intervals, but loop-body analysis widens mutable objects to their declared
ranges. Put a needed guard inside the loop. See [Integer expressions](../language.md#integer-objects-expressions-and-comparisons).

## 8 Try a small guarded-counter exercise

Create your own file outside the checkout, then check its membership:

```sh
cat > "$silver_lessons/counter.adb" <<'ADA'
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Count : Integer range 0 .. 3 := 0;
begin
   for I in 1 .. 5 loop
      if Count < 3 then
         Count := (Count + 1);
      end if;
      Silver_IO.Put_Line (Integer'Image (Count));
   end loop;
end Main;
ADA
silver check "$silver_lessons/counter.adb"
silver run "$silver_lessons/counter.adb"
```

Predict the output before running it. Expected application output:

```text
 1
 2
 3
 3
 3
```

The direct guard narrows this iteration's read of `Count` to 0 through 2, so adding one fits its
declared range. Try changing the loop's upper bound to 7: the final ` 3` repeats twice more.
Removing the guard would permit an inferred result of 4, so membership fails.

## 9 Use arrays and named Integer subtypes

Start with iteration over a constant array:

```sh
silver run samples/rosetta_loops_foreach.adb
```

Complete source:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Values : constant array (1 .. 5) of Integer := (-1, 0, 1, 2, 3);
begin
   for Value of Values loop
      Silver_IO.Put_Line (Integer'Image (Value));
   end loop;
end Main;
```

Application output:

```text
-1
 0
 1
 2
 3
```

Arrays have fixed, nonempty bounds and an explicit initializer for every component. `for Value of
Values` visits increasing indexes; `of reverse Values` would visit decreasing indexes. `Value` is an
immutable scoped element. This fragment requires a constant iterable; mutable arrays use checked
indexing and counted loops. See [arrays](../language.md#fixed-size-integer-arrays) and [element
iteration](../language.md#constant-integer-array-iteration).

For arithmetic on elements, a named subtype communicates the permitted range. Read and run [the sum of squares sample](../samples/rosetta_sum_of_squares.adb):

```sh
cat samples/rosetta_sum_of_squares.adb
silver run samples/rosetta_sum_of_squares.adb
```

Application output:

```text
 0
 133
```

These declarations are the key:

```ada
subtype Element is Integer range 0 .. 9;
Values : constant array (1 .. 6) of Element := (3, 1, 4, 1, 5, 9);
Count : Integer range 0 .. 6 := 0;
Sum : Integer range 0 .. 2147483647 := 0;
```

`Element` names a reusable Integer range. Array body reads use the declared component range,
independent of initializer values. `of Integer` would contribute the full Integer interval, which
does not justify squaring arbitrary components.

The first loop uses `for I in 1 .. Count loop`. Its initial zero count models an empty logical
vector in nonempty fixed-capacity storage, giving the first output. The second loop visits all six
components and sums their squares.

Look for `if Sum <= 2147483566 then` in both loops. Since elements lie in 0 through 9, their squares
lie in 0 through 81. The threshold is the Integer maximum minus 81, providing room for `(Sum + (Item
* Item))` throughout that interval. The indexed version uses `Values (I)` instead of `Item`.

## 10 Store Boolean decisions without storing proof facts

Use flags to remember ordinary computation results:

```sh
cat samples/rosetta_common_list_elements.adb
silver run samples/rosetta_common_list_elements.adb
```

Application output:

```text
[ 3, 9, 6]
```

For each item in the first list, the sample resets two Boolean flags, scans the other lists, and
stores `True` on a match. `if In_Second and In_Third then` selects common items. Another flag,
`Printed`, controls commas. Look for their `Boolean := False` declarations and the assignments that
change them.

A stored Boolean carries its value, not the safety facts of the predicate that computed it. For
example, storing `Count < 3` in a flag and later testing that flag does not narrow `Count` for
`(Count + 1)`, even if `Count` has not changed. Keep the direct `if Count < 3 then` guard in the
counter exercise. The same rule applies to saved input-validity and String-length tests. Boolean
copies are snapshots too. See [Boolean objects and expressions](../language.md#boolean-objects-and-expressions).

## 11 Preview String indexing and slices on the development branch

This optional lesson uses the additions under repair in draft
[PR #307](https://github.com/berkeleynerd/silver/pull/307). Complete validation of
the repaired feature is pending. A successful example does not clear that work;
see the [interim review response](interim-review-response-20261105.md).

Create a small program in the exercise directory:

```sh
cat > "$silver_lessons/characters.adb" <<'ADA'
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Text : String := "hello";
   Tail : constant String := Text (2 .. 5);
   First : Character := Text (1);
begin
   Text (1) := 'H';
   if First = 'h' then
      Silver_IO.Put_Line (Text);
   end if;
   Silver_IO.Put_Line (Tail);
end Main;
ADA
silver check "$silver_lessons/characters.adb"
silver run "$silver_lessons/characters.adb"
```

Application output:

```text
Hello
ello
```

`Text (1)` reads one Character, written with single quotes as `'h'`; `"h"` is a
one-byte String instead. The element write changes one byte without changing
`Text`'s bounds. `First` and `Tail` captured their initial values, so they retain
the original character and slice after the write.

The slice `Text (2 .. 5)` retains bounds 2 through 5, rather than starting at 1.
Consequently, a later read from `Tail` must use those bounds. A Character cannot
be passed directly to `Put_Line`; this example outputs Strings. Indexing is
limited to Strings with bounds known at declaration time, so a length guard on
command-line input does not enable input indexing. In conditional regions, the
repair rules also require Ada-static slice endpoints. The complete
[indexing rules](../language.md#character-objects-and-fixed-bound-string-indexing)
and [slice rules](../language.md#common-string-expressions) include null slices
and the other restrictions.

## 12 Diagnose a rejected program and continue learning

When experimenting, run `silver check` first. A rejection currently says
`Rejected: source is outside the Silver catalogue.` without a line number or
the particular violated rule. Compare your change with the last accepted version.

For example, copy the counter exercise to a second file and remove its
`if Count < 3 then` and corresponding `end if;`, leaving the update in the loop.
Check that copy:

```sh
cp "$silver_lessons/counter.adb" "$silver_lessons/unguarded.adb"
nano "$silver_lessons/unguarded.adb"
silver check "$silver_lessons/unguarded.adb"
printf 'exit status: %s\n' "$?"
```

After that edit, the check rejects the program with status 2: the inferred range
of `(Count + 1)` includes 4, outside `Count`'s declared range. Restore the direct
guard to make the update admissible. Adding a proof annotation is not a Silver
repair.

| Symptom | Next step |
| --- | --- |
| `command not found: silver` | Define the function from step 3 in this terminal, or load the saved definition. |
| `Silver is not built` | Confirm the checkout path and finish bootstrap/build in step 2. |
| Missing native tools, or stale installed runtime sources | Rerun bootstrap and build from the selected checkout; preserve existing host directories. |
| Membership rejection, status 2 | Check exact syntax, types, fixed lengths and ranges; use the specification links for the changed construct. Incorrect CLI usage can also return 2. |
| Verification or compilation failure after acceptance, ordinarily status 3 | Retain the diagnostics and printed workspace/report paths for investigation. This is an implementation/toolchain failure, not a request for author-written contracts. |
| `Execution returned status 1.` | Inspect the application's input and output conditions; the greeting deliberately rejects invalid input, and external output/launch failure can also produce status 1. |

Useful boundaries to remember are the 4096-byte source limit, 4096-byte String
expression limit, 64 operands per applicable expression and 63 shared String
concatenation/scalar arithmetic operators per source. The [specification](../language.md)
defines their exact counting rules, supported constructs and compositions.
The [sample manifest](../samples/manifest.json) links additional programs to
their capabilities and expected results. Roadmap proposals do not admit syntax.

For further practice, inspect and run the
[countdown](../samples/for_loop_countdown.adb),
[branching](../samples/input_branching.adb), and
[partial output](../samples/partial_output.adb) samples. `Put` writes bytes
without a newline; `Put_Line` adds a newline, which explains how the Boolean
list example prints brackets and commas across several calls.

The [host verification record](evidence/tutorial-macos-20261105/README.md)
records the native setup, checked lesson programs and shell checks performed
on 2026-11-05. These example checks do not replace the language's complete
assurance requirements.
