#!/usr/bin/env python3
"""Explore a sourced finite-state abstraction; not a native execution/proof.

Prerequisites: one signal-dispatching OCaml worker; successful POSIX blocking
and SIG_IGN installation; no SIGINT reinstallation/unmask during the callback;
no other producer of the SIGINT runtime bit. Arbitrary external SIGINT events
are permitted. Failure paths without a successful disposition commit are not
used to claim a bound on total callback allocations or total callback entries.
"""
from collections import deque


def successors(s):
    phase, installed, runtime_bit, os_bit, blocked, saves = s
    if installed:
        if blocked:
            yield 'external_SIGINT_pending', (phase, installed, runtime_bit, True, blocked, saves)
        else:
            yield 'external_SIGINT_recorded', (phase, installed, True, os_bit, blocked, saves)
    if phase == 'idle' and runtime_bit and not blocked:
        yield 'dispatch_clears_bit', ('gap', installed, False, os_bit, blocked, saves)
    if phase == 'gap':
        yield 'block_SIGINT', ('masked', installed, runtime_bit, os_bit, True, saves)
    if phase == 'masked':
        # POSIX SIG_IGN discards pending OS signals, not OCaml's stale bit.
        yield 'commit_SIG_IGN', ('ignored', False, runtime_bit, False, blocked, saves)
    if phase == 'ignored':
        yield 'save_enter', ('saved', installed, runtime_bit, os_bit, blocked, saves + 1)
        yield 'escape_before_save', ('idle', installed, runtime_bit, os_bit, False, saves)
    if phase == 'saved':
        # Conservatively permit a continuing exception after every save.
        yield 'escape_and_restore_mask', ('idle', installed, runtime_bit, os_bit, False, saves)


def explore():
    starts = [('idle', h, p, False, m, 0)
              for h in (False, True) for p in (False, True) for m in (False, True)]
    seen = set(starts)
    queue = deque((s, []) for s in starts)
    maximum = 0
    witness = None
    while queue:
        state, path = queue.popleft()
        assert state[-1] <= 2, (state, path)
        if state[-1] > maximum:
            maximum, witness = state[-1], path
        for label, target in successors(state):
            if target not in seen:
                seen.add(target)
                queue.append((target, path + [label]))
    assert maximum == 2
    return dict(abstract_states=len(seen), save_entries_upper=maximum,
                two_entry_abstract_path=witness,
                arbitrary_external_SIGINT_events_permitted=True,
                native_execution=False, source_refinement_machine_checked=False)


if __name__ == '__main__':
    import json
    print(json.dumps(explore(), indent=2))
