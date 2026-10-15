# Native shebang

**Excluded from Silver: directories, processes, environment.** The task asks for a launcher that compiles a script when its source is newer than a cached binary, then execs the binary. This needs argument, file, directory-metadata, environment and process effects that Silver lacks today, but nothing breaks a fixed Oracle rule. Ada can express it with bounded path strings and iteration.

## Language surface beyond today's Silver

String operations.

## External effects

- **arguments** (allowed): The launcher is invoked by the kernel as 'script_foo ./echo.foo args...', so it reads the script path and forwards the remaining arguments.
- **files** (allowed): Reads the script source and writes the compiled executable into a cache location.
- **directories** (not allowed): Chooses a writable cache directory, creates it if needed, and compares source and cached binary modification times to decide whether to recompile.
- **processes** (not allowed): Runs the native compiler on the script, then exec-replaces the launcher with the cached binary so the process id is kept.
- **environment** (not allowed): Cache location is derived from the home directory or temp directory environment variables and write permissions.
- **exit status** (allowed): Returns a failure status when no script is given or compilation fails.

Assessed on 2026-10-15 against page revision 414356 of the [task](https://rosettacode.org/wiki/Native_shebang) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
