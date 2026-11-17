# Rosetta refresh repair — #29

Author commit `58306e9d9a651e7f9b9e88fb021807b272ec046a`, integrated as
`791b122423`, validates required task and solution-subpage cache inputs before
removing generated groups. It reports missing/unreadable pages clearly and
documents whole-group replacement. The lead reviewed the three-file change
and its required-subpage selection, including shared Ada/SPARK sections.

Managed Linux run `20261109T230606-6cf4a949f72f` passed all 12 Rosetta methods
in 10.069 seconds (12.456 seconds managed, one worker). The retained phase-end
record has test-process exit 0 and the managed outcome is success; a separate
driver-exit artifact was not retained. Earlier two focused successes preceded
the final shared-section/online-error refinements and remain in the run ledger;
only this final run establishes the finished repair.

The tests exercise preserved output after missing or unreadable late task and
solution pages, malformed/incomplete cache metadata, a mocked incomplete online
download, successful small-corpus rebuilding, and cache-free render behavior.
The existing real-corpus deterministic-render tests also pass. The implementation
assumes cache inputs remain stable during the refresh; this is no transaction
guarantee for later filesystem failures. No generalized cache framework was added.

`result.json` is an agent-written summary. The compressed logs are original
runner output. Its four affected source/data inputs match the integrated repair;
this focused result makes no procedure/compiler/Lean assurance claim. No full
corpus download, complete test suite, native proof or Lean run was performed for
#29. Source/capability work under #370 receives its separate shared checkpoint.
