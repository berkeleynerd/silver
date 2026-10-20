#!/usr/bin/env python3
"""Offline source pins and finite adversarial model; no production proof claim."""
from __future__ import annotations
import hashlib
import itertools
import json
from pathlib import Path
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
COUNTS = {}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def checked(group, condition):
    assert condition, group
    COUNTS[group] = COUNTS.get(group, 0) + 1


def source_checks():
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for path, digest in inputs['archives'].items():
        checked('archive_identity', sha((ROOT / path).read_bytes()) == digest)
    issue = inputs['issue_88']
    checked('issue_identity', sha((ROOT / issue['path']).read_bytes()) == issue['sha256'])
    for name, item in inputs['imports'].items():
        checked('R51_import_identity', sha((HERE / name).read_bytes()) == item['sha256'])
    wb = (HERE / 'source-witnesses.json').read_bytes()
    checked('witness_manifest', sha(wb) == inputs['source_witnesses_sha256'])
    witnesses = json.loads(wb)
    for path in inputs['archives']:
        with tarfile.open(ROOT / path) as arc:
            for w in witnesses:
                if w['archive'] != path:
                    continue
                data = arc.extractfile(w['member']).read()
                excerpt = ''.join(data.decode().splitlines(keepends=True)[w['first_line']-1:w['last_line']])
                checked('source_slice', sha(data) == w['member_sha256']
                        and excerpt == w['text'] and sha(excerpt.encode()) == w['slice_sha256'])
    return len(witnesses)


TABLE = json.loads((HERE / 'canonical-table.json').read_text())
PROVERS = ['cvc5', 'z3', 'altergo']
ROWS = {(PROVERS.index(x['driver']), x['answer_kind'], x['warning']): x['output'].encode() for x in TABLE}
DIRECTIVES = json.loads((HERE / 'loaded-response-directives.json').read_text())
RULE_COUNTS = [len([d for d in DIRECTIVES[n] if d['directive'] != 'time'])
               for n in ['cvc5_gnatprove.drv', 'z3_gnatprove.drv', 'alt_ergo_gnatprove_smt2.drv']]
# magic, 8 one-byte fields, id/pid, status/errno, rule/failure masks, terminal magic.
FRAME = struct.Struct('>8s8BQQIIQQ8s')
IDENTITY = (0, 1, 7)  # domain, prover, original request id
MAX_ID = (1 << 62) - 1


def frame(domain=0, prover=1, request=7, kind='V', warning=0, flags=3,
          termination=1, observation=0, reserved=0, pid=1234, status=0,
          errno=0, rules=0, failures=0):
    return FRAME.pack(b'SLVADP01', domain, prover, ord(kind), warning, flags,
                      termination, observation, reserved, request, pid, status,
                      errno, rules, failures, b'SLVEND01')


def decode(data, identity=IDENTITY):
    if len(data) != 64:
        return None
    (magic, domain, prover, kind, warning, flags, termination, observation,
     reserved, request, pid, status, errno, rules, failures, end) = FRAME.unpack(data)
    if (magic, end) != (b'SLVADP01', b'SLVEND01'):
        return None
    if (domain, prover, request) != identity or not (0 <= domain < 5 and 0 <= prover < 3 and 1 <= request <= MAX_ID):
        return None
    if warning > 1 or flags > 3 or termination > 2 or observation > 3 or reserved:
        return None
    if rules >= 1 << RULE_COUNTS[prover] or failures >= 1 << 6:
        return None
    row = ROWS.get((prover, chr(kind), bool(warning)))
    if row is None:
        return None
    if termination == 0:
        if pid or status:
            return None
    elif pid == 0 or (termination == 1 and status > 255) or (termination == 2 and not 1 <= status <= 255):
        return None
    if observation == 0:
        if flags != 3 or termination == 0 or failures or errno:
            return None
    else:
        required = {1: 0b001111, 2: 0b010000, 3: 0b100000}[observation]
        if chr(kind) != 'H' or warning or not failures & required:
            return None
    return row


class Receiver:
    def __init__(self):
        self.data = b''
        self.closed = False
        self.bad = False

    def add(self, chunk):
        if self.closed:
            self.bad = True
        self.data = (self.data + chunk)[:65]
        self.bad |= len(self.data) > 64

    def eof(self):
        if self.closed:
            self.bad = True
        self.closed = True

    def row(self, identity):
        return decode(self.data, identity) if self.closed and not self.bad else None


class Slot:
    """Abstract one-request publication machine; native I/O is modeled explicitly."""
    def __init__(self, identity=IDENTITY):
        self.identity = identity
        self.receiver = Receiver()
        self.started = False
        self.finished = None
        self.cancel = False
        self.defect = False
        self.state = 'private'
        self.contents = b''
        self.released = False
        self.row = None

    def event(self, event):
        if event == 'S':
            self.defect |= self.started
            self.started = True
        elif event == 'F':
            self.finish(0, False, 'raw-out')
        elif event == 'data':
            self.receiver.add(frame())
        elif event == 'EOF':
            self.receiver.eof()
        elif event == 'cancel':
            self.cancel = True
        else:
            raise AssertionError(event)

    def finish(self, exitcode, signaled, rawpath):
        if self.finished is not None:
            self.defect = True
        self.finished = (exitcode, signaled, rawpath)

    def enabled(self):
        row = self.receiver.row(self.identity)
        return bool(not self.defect and self.started and self.finished == (0, False, 'raw-out') and row is not None)

    def create(self):
        if not self.enabled() or self.state != 'private':
            return False
        self.row = self.receiver.row(self.identity)
        self.state = 'writing'
        return True

    def write(self, count):
        assert self.state == 'writing'
        self.contents += self.row[len(self.contents):len(self.contents)+count]

    def close(self, ok):
        if not ok or self.contents != self.row:
            self.state = 'failed'
        else:
            self.state = 'ready'

    def release(self):
        if self.state == 'ready' and self.enabled():
            self.released = True
            self.state = 'released'
        return self.released

    def late_duplicate(self):
        # It cannot undo bytes already delivered, but blocks confirmation forever.
        self.defect = True


def frame_checks():
    checked('frame_layout', FRAME.size == 64 and RULE_COUNTS == [13, 5, 6])
    checked('canonical_table', len(ROWS) == 31 and max(map(len, ROWS.values())) == 76)
    for (prover, kind, warning), row in ROWS.items():
        record = frame(prover=prover, kind=kind, warning=warning)
        identity = (0, prover, 7)
        checked('canonical_frame', decode(record, identity) == row)
        for n in range(64):
            receiver = Receiver(); receiver.add(record[:n]); receiver.eof()
            checked('all_truncations', receiver.row(identity) is None)
        for extra in [b'x', b'x'*65, record, frame(prover=prover, kind='H')]:
            receiver = Receiver(); receiver.add(record + extra); receiver.eof()
            checked('excess_and_conflict', receiver.row(identity) is None and len(receiver.data) <= 65)
        for cut in range(65):
            receiver = Receiver(); receiver.add(record[:cut]); receiver.add(record[cut:])
            checked('EOF_required', receiver.row(identity) is None)
            receiver.eof()
            checked('all_chunk_cuts', receiver.row(identity) == row)
        for offset in [0, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 23, 56, 63]:
            mutated = bytearray(record); mutated[offset] = 255
            checked('bad_fields', decode(bytes(mutated), identity) is None)
        checked('unknown_rule_bit', decode(frame(prover=prover, rules=1 << RULE_COUNTS[prover]), identity) is None)
    for field in [{'flags':0}, {'flags':1}, {'flags':2}, {'termination':0, 'pid':0},
                  {'errno':12}, {'failures':1}, {'termination':2, 'status':0}, {'status':256}]:
        checked('complete_observation_requirements', decode(frame(**field)) is None)
    for field in [{'termination':1, 'status':17}, {'termination':2, 'status':9}]:
        checked('complete_V_preserves_child_status', decode(frame(**field)) == b'unsat\n')
    for observation, failures in [(1,1), (2,16), (3,32)]:
        checked('failure_record_is_H', decode(frame(kind='H', observation=observation, failures=failures, errno=12, flags=0)) == b'!\n')
        checked('failure_cannot_claim_V', decode(frame(observation=observation, failures=failures, errno=12, flags=0)) is None)


def gate_checks():
    # Preserve each channel's order; exhaust every interleaving of the two channels plus cancellation.
    for events in itertools.permutations(['S', 'F', 'data', 'EOF', 'cancel']):
        if events.index('S') > events.index('F') or events.index('data') > events.index('EOF'):
            continue
        slot = Slot()
        seen = set()
        for event in events:
            slot.event(event); seen.add(event)
            checked('gate_schedule_prefix', slot.enabled() == {'S', 'F', 'data', 'EOF'}.issubset(seen))
            checked('no_early_release', not slot.release())
        checked('gate_schedule_complete', slot.create())
        slot.write(76); slot.close(True)
        checked('fully_closed_release', slot.release() and slot.contents == b'unsat\n')
        slot.late_duplicate()
        checked('late_defect_retained', slot.released and slot.defect)
    # Every proper canonical prefix, including complete-looking unsat, stays private on failure.
    for (prover, kind, warning), row in ROWS.items():
        for n in range(len(row)+1):
            slot = Slot((0,prover,7)); slot.started=True; slot.finish(0,False,'raw-out')
            slot.receiver.add(frame(prover=prover,kind=kind,warning=warning));slot.receiver.eof()
            assert slot.create();slot.write(n)
            checked('partial_write_private', not slot.release())
            slot.close(False)
            checked('all_write_close_failures', not slot.release())
        slot = Slot((0,prover,7));slot.started=True;slot.finish(0,False,'raw-out')
        slot.receiver.add(frame(prover=prover,kind=kind,warning=warning));slot.receiver.eof()
        assert slot.create();slot.write(len(row));slot.close(True)
        checked('every_row_publication', slot.release() and slot.contents == row)
    for status, signaled, path, started in [(0,False,'',False),(0,False,'',True),
                                          (1,False,'raw-out',True),(9,True,'raw-out',True),
                                          (0,False,'raw-out',False)]:
        slot=Slot();slot.started=started;slot.finish(status,signaled,path)
        slot.receiver.add(frame());slot.receiver.eof()
        checked('queued_cancel_or_abnormal_adapter', not slot.create() and not slot.release())
    for n in range(64):
        slot=Slot();slot.started=True;slot.finish(0,False,'raw-out')
        slot.receiver.add(frame()[:n]);slot.receiver.eof()
        checked('F_before_truncated_record', not slot.create())
    slot=Slot();slot.started=True;slot.finish(0,False,'raw-out');slot.finish(0,False,'raw-out')
    slot.receiver.add(frame());slot.receiver.eof()
    checked('duplicate_F', slot.defect and not slot.create())
    for events in itertools.permutations(['child_eof','child_wait','cancel']):
        seen=set(); eof=False; waited=False; completed=False
        for event in events:
            seen.add(event)
            if event == 'child_eof': eof=True
            if event == 'child_wait': waited=True
            if eof and waited: completed=True
            checked('producer_join', completed == {'child_eof','child_wait'}.issubset(seen))


def goal(attempts=(), transforms=()):
    return (tuple(attempts), tuple(transforms))


def proved(g):
    attempts, transforms = g
    return 'V' in attempts or any(all(proved(child) for child in children) for children in transforms)


def relevant(g):
    if proved(g):
        return []
    attempts, transforms = g
    out=list(attempts)
    for children in transforms:
        for child in children:
            out.extend(relevant(child))
    return out


def classify(roots, *, independent=False, normal=True, audit=True, identity=True,
             complete=True, interrupted=False, explained_missing=False):
    if independent or not identity:
        return 'defect'
    if normal and not audit:
        return 'defect'
    facts=[x for root in roots for x in relevant(root)]
    if any(x in ('U','Invalid','H-unexplained','cap') for x in facts):
        return 'defect-candidate'
    if normal and not complete and not explained_missing:
        return 'defect'
    if interrupted or not normal:
        return 'interrupted' if interrupted else 'unconfirmed'
    if all(proved(g) for g in roots) and complete:
        return 'confirmed'
    if facts and all(x == 'R' for x in facts):
        return 'resource-inconclusive'
    return 'unconfirmed'


def policy_checks():
    for loser in ['U','Invalid','H-unexplained','R','I']:
        for order in [(loser,'V'),('V',loser)]:
            checked('loser_policy', classify([goal(order)]) == 'confirmed')
            checked('independent_precedence', classify([goal(order)],independent=True) == 'defect')
        checked('different_root_not_loser', classify([goal(['V']),goal([loser])]) != 'confirmed')
    checked('AND_OR_subgoals', classify([goal(transforms=[(goal(['V']),goal(['R']))])]) == 'resource-inconclusive')
    checked('proved_transform_losing_alternative', classify([goal(['U'],[(goal(['V']),goal(['V']))])]) == 'confirmed')
    checked('empty_transform', classify([goal(transforms=[()])]) == 'confirmed')
    for order in itertools.permutations(['R','U','R']):
        checked('mixed_unproved', classify([goal(order)]) == 'defect-candidate')
    checked('all_resource', classify([goal(['R','R'])]) == 'resource-inconclusive')
    checked('normal_missing', classify([goal(['V'])],complete=False) == 'defect')
    checked('interrupted_missing', classify([goal(['I'])],normal=False,complete=False,interrupted=True,explained_missing=True) == 'interrupted')
    checked('interrupted_existing_defect', classify([goal(['U'])],normal=False,complete=False,interrupted=True,explained_missing=True) == 'defect-candidate')
    checked('strict_audit', classify([goal(['V'])],audit=False) == 'defect')
    checked('identity_precedence', classify([goal(['V'])],identity=False) == 'defect')
    # Finite ambiguity witness: identical categorical forest, opposite attribution placement.
    forest=[goal(['V','H']),goal(['H'])]
    observations=['H-resource','H-unexplained']
    assignment1={'proved-root':observations[1],'unproved-root':observations[0]}
    assignment2={'proved-root':observations[0],'unproved-root':observations[1]}
    checked('mixed_H_needs_join', assignment1['unproved-root'] != assignment2['unproved-root'] and not proved(forest[1]))
    checked('uniform_cohort_sufficient', all(x=='H-resource' for x in ['H-resource']*3))


def size_checks():
    for stdin, d, p, i in itertools.product([False,True],range(5),range(3),[1,7,MAX_ID]):
        solver=['solver','--flag','vc.smt2']; prefix=['runstdin' if stdin else 'run',str(i),'0','0']
        original=prefix+solver+(['stdin-file'] if stdin else [])
        args=['/bin/adapter','--control','.slv-a0','--domain',str(d),'--request',str(i),'--prover',str(p),'--']
        wrapped=prefix+args+solver+(['stdin-file'] if stdin else [])
        wire=lambda xs: (';'.join(xs)+'\n').encode()
        expected=len('/bin/adapter')+46+7+len(str(d))+len(str(i))+len(str(p))
        checked('wrapper_wire_formula', len(wire(wrapped))-len(wire(original)) == expected)
        checked('wrapper_bound', expected <= len('/bin/adapter')+74 and len(wrapped)-len(original)==10)
    for d,p,i in itertools.product(range(5),range(3),[1,7,MAX_ID]):
        payload=f'{d:x}{p:x}{i:016x}'
        raw=f'(:reason-unknown {payload})\n'.encode()
        warning_prefix=b'unknown\n(:reason-unknown resourceout)\n'
        checked('U_only_ticket_size',len(payload)==18 and len(raw)==37 and len(warning_prefix+raw)==75)
        checked('U_only_ticket_class_O',payload not in ['', 'resourceout', 'timeout', '(not unknown!)']
                and all(c in '0123456789abcdef' for c in payload))
    for root in ['/tmp/r','/a/longer/root']:
        path=f'{root}/d0/{7:016x}.out'
        checked('canonical_path',len(path)==len(root)+24)
        for t in ['0.000000','123.456789']:
            wire=f'F;7;0;{t};0;{path}\n'
            checked('F_wire_formula',len(wire)==8+1+1+len(t)+len(path))


def main():
    start=time.monotonic()
    slices=source_checks();frame_checks();gate_checks();policy_checks();size_checks()
    result={'status':'pass','source_slices':slices,'checks':COUNTS,'total_assertions':sum(COUNTS.values()),
            'frame_bytes':64,'receiver_bytes':65,'canonical_rows':31,'maximum_canonical_bytes':76,
            'rule_counts':dict(zip(PROVERS,RULE_COUNTS)),
            'scope':'finite offline adversarial model and source identity; not production verification or complete LeafMap/q',
            'elapsed_seconds':round(time.monotonic()-start,6)}
    (HERE/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps(result,sort_keys=True))

if __name__=='__main__': main()
