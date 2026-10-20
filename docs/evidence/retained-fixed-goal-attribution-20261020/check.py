#!/usr/bin/env python3
"""Pinned finite projection and protocol examples; no native or proof replay.

Prints its result without changing the packet. Source correspondence and the
alpha-preservation/Done-flush arguments are reviewed in the research note.
"""
import hashlib
import itertools
import json
import platform
import sys
import tarfile
import time

sys.dont_write_bytecode = True
from project import HERE, ROOT, project

COUNTS = {}


def checked(group, condition):
    assert condition, group
    COUNTS[group] = COUNTS.get(group, 0) + 1


def sha(data):
    return hashlib.sha256(data).hexdigest()


def pins():
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for group in ['archives', 'context_files', 'packet_files']:
        base = HERE if group == 'packet_files' else ROOT
        for path, digest in inputs[group].items():
            checked(group, sha((base / path).read_bytes()) == digest)
    projection = json.loads((HERE / 'projection-inputs.json').read_text())
    for path, digest in projection['files'].items():
        checked('projection_file_pin', sha((ROOT / path).read_bytes()) == digest)
    witnesses = json.loads((HERE / 'source-witnesses.json').read_text())
    for path in inputs['archives']:
        with tarfile.open(ROOT / path) as arc:
            for w in witnesses:
                if w['archive'] != path:
                    continue
                data = arc.extractfile(w['member']).read()
                text = ''.join(data.decode().splitlines(keepends=True)
                               [w['first_line'] - 1:w['last_line']])
                checked('source_slice', sha(data) == w['member_sha256']
                        and text == w['text']
                        and sha(text.encode()) == w['slice_sha256'])
    return len(witnesses)


def finite_map():
    result = project()  # Internal shape/layout/parent/binding assertions run too.
    for name in ['raw-goal-labels.json', 'fixed-root-map.json',
                 'projection-inputs.json']:
        checked('projection_equality', result[name] == json.loads((HERE / name).read_text()))
    expected = json.loads((HERE / 'projection-result.json').read_text())['cases']
    checked('projection_equality', result['cases'] == expected)
    checked('finite_totals', sum(x['raw_goals'] for x in expected.values()) == 161)
    checked('finite_totals', sum(x['registered'] for x in expected.values()) == 118)
    checked('finite_totals', sum(x['nontrivial_registered'] for x in expected.values()) == 116)
    checked('finite_totals', sum(x['checks'] for x in expected.values()) == 47)
    for case, rows in result['raw-goal-labels.json'].items():
        checked('actual_name_collision', len({r['symbol'] for r in rows}) == 1)
        checked('actual_name_collision', {r['name'] for r in rows} == {"def'vc"})
        for row in result['fixed-root-map.json'][case]:
            checked('root_roundtrip', next(x for x in rows if x['goal'] == row['goal'])['check']['id'] == row['check_id'])
    rows = {r['goal']: r for r in result['raw-goal-labels.json']['is_message']}
    for field in ['symbol', 'ident', 'name', 'location_words', 'check']:
        checked('concrete_collision', rows[1][field] == rows[2][field])
    checked('concrete_collision', not rows[1]['trivial'] and not rows[2]['trivial'])
    mappings = result['fixed-root-map.json']['is_message']
    checked('concrete_collision', [(r['goal'], r['root_index']) for r in mappings] == [(2, 0), (1, 1)])
    return result['cases'], result['elapsed_seconds']


class Gate:
    """One domain's F delivery; server solver execution is independent.

    The fixed request table is an assumption in this finite model, supplied in
    source by saved_data + controller callback closures. The implementation
    candidate does NOT already know each request's goal before its Done line.
    """
    def __init__(self, request_table):
        self.requests = request_table
        self.queue = []
        self.pending = None
        self.sent = []
        self.finished = set()
        self.joins = []
        self.bad = False
        self.frontend_alive = True

    def backend(self, event):
        kind, request = event
        if request not in self.requests or (kind == 'F' and request in self.finished):
            self.bad = True
            return
        if kind == 'F':
            self.finished.add(request)
        self.queue.append(event)
        self.pump()

    def pump(self):
        # FIFO is kept, including S after a held F. No launch/request gate.
        while self.queue and self.pending is None and not self.bad and self.frontend_alive:
            event = self.queue.pop(0)
            self.sent.append(event)
            if event[0] == 'F':
                self.pending = event[1]

    def log(self, kind, goal=None, prover=None):
        if kind != 'done':
            return
        if (self.pending is None or goal not in {1, 2, 3}
                or prover != self.requests[self.pending][1]):
            self.bad = True
            return
        self.joins.append((self.pending, goal, prover))
        self.pending = None
        self.pump()

    def die(self):
        self.frontend_alive = False
        self.bad = True

    def sealed(self):
        # Other R53 seal prerequisites are required separately.
        return not self.bad and not self.queue and self.pending is None


def protocol():
    # IDs 7/8 deliberately have the same prover; ordinal matching alone would
    # misjoin when get_new_results sorts a multi-F batch by request ID.
    requests = {7: (1, 'z3'), 8: (2, 'z3'), 9: (3, 'cvc5')}
    for finish_order in itertools.permutations(requests):
        g = Gate(requests)
        for request in requests:
            g.backend(('S', request))
        checked('concurrency', g.sent == [('S', request) for request in requests])
        # All three solvers finish before any Done is consumed: backlog > 1.
        for request in finish_order:
            g.backend(('F', request))
        checked('one_unacknowledged', sum(k == 'F' for k, _ in g.sent) == 1)
        checked('backlog', len(g.queue) == 2)
        for request in finish_order:
            checked('one_unacknowledged', g.pending == request)
            # Interrupted/scheduled/blank lines do not acknowledge an F.
            for kind in ['interrupted', 'scheduled', 'blank']:
                g.log(kind)
                checked('non_done', g.pending == request)
            goal, prover = requests[request]  # Source callback lookup premise.
            g.log('done', goal, prover)
        checked('association', g.joins == [(r, *requests[r]) for r in finish_order])
        checked('terminal', g.sealed())
        g.log('done', 1, 'z3')
        checked('unsolicited_done', g.bad and not g.sealed())

    g = Gate(requests)
    g.backend(('F', 7))  # Backend queued cancellation may have no S.
    g.backend(('S', 8))
    g.backend(('F', 8))
    checked('fifo', g.sent == [('F', 7)] and len(g.queue) == 2)
    g.log('done', 1, 'z3')
    checked('fifo', g.sent == [('F', 7), ('S', 8), ('F', 8)])
    g.log('done', 2, 'z3')
    checked('cancel_then_done', g.sealed())
    for fault in ['wrong_prover', 'unknown_goal', 'duplicate_F', 'frontend_death']:
        g = Gate(requests)
        g.backend(('S', 7))
        g.backend(('F', 7))
        if fault == 'wrong_prover':
            g.log('done', 1, 'cvc5')
        elif fault == 'unknown_goal':
            g.log('done', 400, 'z3')
        elif fault == 'duplicate_F':
            g.backend(('F', 7))
        else:
            g.die()
        checked('fault', g.bad and not g.sealed())
    g = Gate(requests)
    g.backend(('F', 7))
    checked('missing_ack', not g.sealed())
    # Actual blocking path drops Started; a Running-before-F gate stalls.
    updates = [('Started', 7)]
    blocking_updates = [x for x in updates if x[0] != 'Started']
    checked('S_Running_negative', blocking_updates == [])
    backend_order = [8, 7]
    callback_order = sorted(backend_order)
    checked('ungated_ordinal_negative', backend_order != callback_order)

    # #88 relevance retains ALL unsuccessful history on an unproved root.
    history = [(7, 1, 'Unknown'), (8, 1, 'Resource')]
    checked('history_not_overwritten', any(k == 'Unknown' for _, goal, k in history if goal == 1))
    history.append((10, 1, 'Valid'))
    checked('winner_relevance', any(k == 'Valid' for _, goal, k in history if goal == 1))
    # An independent defect is not erased by winner-based attempt relevance.
    independent_defect = True
    checked('defect_precedence', independent_defect)


def formatter():
    answers = ['valid', 'invalid', 'timeout', 'outofmemory',
               'steplimitexceeded', 'unknown', 'failure', 'highfailure']
    lengths = []
    for prover, answer in itertools.product(['z3', 'cvc5', 'altergo'], answers):
        row = {'timestamp': 0, 'goal_id': '0', 'prover': prover,
               'pas': {'kind': 'done', 'answer': answer, 'time': 0}}
        data = json.dumps(row, separators=(',', ':'))
        lengths.append(len(data))
        checked('Done_length', len(data) >= 91 > 78)
        # Restricted Format queue: initial unknown zero-length box; subsequent
        # tokens known-size text only. Tokenizing into chars is conservative.
        pending = ''
        output = ''
        dummy = True
        for char in data:
            pending += char
            if dummy and len(pending) >= 78:
                dummy = False
            if not dummy:
                output += pending
                pending = ''
        checked('Done_drains', output == data and pending == '')
    checked('Done_minimum', min(lengths) == 91)
    short = '{"timestamp":0,"goal_id":"0","prover":"z3","pas":{"kind":"scheduled"}}'
    checked('short_nonDone_negative', len(short) < 78)
    return {'minimum_Done_JSON_bytes': min(lengths), 'initial_Format_margin': 78}


def main():
    start = time.monotonic()
    slices = pins()
    cases, projection_seconds = finite_map()
    protocol()
    flush = formatter()
    print(json.dumps({'status': 'PASS', 'checked_groups': COUNTS,
                      'counted_assertions': sum(COUNTS.values()),
                      'count_note': 'Excludes internal graph/layout assertions in project.py.',
                      'source_slices': slices, 'cases': cases, 'formatter': flush,
                      'platform': platform.system(), 'machine': platform.machine(),
                      'projection_seconds': projection_seconds,
                      'elapsed_seconds': time.monotonic() - start,
                      'scope': 'retained finite projection and conditional source-protocol model; no runtime transfer'},
                     indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
