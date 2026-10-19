#!/usr/bin/env python3
"""Focused executable illustrations of the source invariant and arithmetic."""
import argparse
from collections import Counter
import copy
import datetime
import json
from pathlib import Path
import platform
import runpy
import time

HERE = Path(__file__).resolve().parent
api = runpy.run_path(str(HERE/'derive.py'))
checks = []


def check(name, value):
    assert value, name
    checks.append(name)


def rejects(name, thunk):
    try:
        thunk()
    except (ValueError, AssertionError):
        checks.append(name)
        return
    raise AssertionError('mutation accepted: '+name)


class Pool:
    """Returned-before-virgin slot mechanics, not GCC executable semantics."""
    def __init__(self, q):
        self.q, self.blocks, self.virgin = q, 0, []
        self.returned, self.live = [], set()
        self.peak = 0

    def allocate(self):
        if not self.returned:
            if not self.virgin:
                start = self.q*self.blocks
                self.blocks += 1
                self.virgin = list(range(start, start+self.q))
            self.returned.append(self.virgin.pop())
        slot = self.returned.pop()
        assert slot not in self.live
        self.live.add(slot)
        self.peak = max(self.peak, len(self.live))
        self.valid()
        return slot

    def remove(self, slot):
        assert slot in self.live
        self.live.remove(slot)
        self.returned.append(slot)
        self.valid()

    def valid(self):
        allocated = self.q*self.blocks
        free = len(self.returned)+len(self.virgin)
        assert 0 <= free <= allocated and allocated-free == len(self.live)
        assert len(set(self.returned+self.virgin)) == free
        assert not self.live.intersection(self.returned+self.virgin)
        assert self.blocks <= (self.peak+self.q-1)//self.q

    def release(self):
        self.blocks, self.virgin, self.returned, self.live = 0, [], [], set()
        self.peak = 0
        self.valid()


class Recognition:
    def __init__(self, c):
        self.spec, self.frequency = {}, {}
        for group in range(c):
            a, b, d, e = (100+group*4+i for i in range(4))
            for j, regs in enumerate([(a,), (b, a), (1, b), (d,), (e, d), (2, e), ()]):
                uid = 7*group+j
                self.spec[uid] = regs
                self.frequency[uid] = 1000
        self.records, self.refs, self.freq = {}, Counter(), Counter()
        self.rpool, self.ipool = Pool(819), Pool(2730)
        self.c, self.finished = c, False

    def get(self, uid):
        assert not self.finished and uid in self.spec
        if uid not in self.records:
            self.records[uid] = dict(slot=self.rpool.allocate(), regs=[], code=0)
        return self.records[uid]

    def invalidate_registers(self, uid):
        for reg, slot in self.get(uid)['regs']:
            self.ipool.remove(slot)
            if reg >= 92:
                self.refs[reg] -= 1
                self.freq[reg] -= self.frequency[uid]
                assert self.refs[reg] >= 0 and self.freq[reg] >= 0
        self.records[uid]['regs'] = []

    def rebuild(self, uid):
        self.invalidate_registers(uid)
        for reg in dict.fromkeys(self.spec[uid]):
            self.records[uid]['regs'].append((reg, self.ipool.allocate()))
            if reg >= 92:
                self.refs[reg] += 1
                self.freq[reg] += self.frequency[uid]
        self.valid()

    def invalidate(self, uid):
        self.invalidate_registers(uid)
        self.rpool.remove(self.records.pop(uid)['slot'])
        self.valid()

    def recode(self, uid):
        self.invalidate(uid)
        self.get(uid)['code'] = 1
        self.valid()

    def final_renumber(self):
        # Source operands change; stored list identities deliberately do not.
        self.spec = {u: tuple(1 if r >= 92 else r for r in regs)
                     for u, regs in self.spec.items()}
        self.valid()

    def valid(self):
        assert len(self.rpool.live) == len(self.records) <= 7*self.c+20
        lists = [r for d in self.records.values() for r in d['regs']]
        assert len(self.ipool.live) == len(lists) <= 10*self.c
        refs, freq = Counter(), Counter()
        for uid, data in self.records.items():
            assert len({r for r, _ in data['regs']}) == len(data['regs'])
            for reg, _ in data['regs']:
                if reg >= 92:
                    refs[reg] += 1
                    freq[reg] += self.frequency[uid]
        assert self.refs == refs and self.freq == freq
        assert all(0 <= x <= 2 for x in refs.values())
        assert all(0 <= x <= 2000 for x in freq.values())

    def drain(self):
        self.refs = self.freq = None  # register metadata has already been freed
        for data in self.records.values():
            for _, slot in data['regs']:
                self.ipool.remove(slot)
            self.rpool.remove(data['slot'])
        self.ipool.release()
        self.ipool.release()  # actual finish path releases this pool twice
        self.rpool.release()
        self.finished = True
        # Map cells in C++ are dead values after free; no active-state check.


def main(gcc):
    started = time.perf_counter()
    verification = api['verify_inputs'](gcc)
    check('full source/repository/Git pins, LF excerpts, headers and inventories', bool(verification))
    result = api['fixture']()
    check('unchanged complete fixed accepted owner and 367 maps', result['new_allocation_owners']==0)
    arithmetic, i32 = api['arithmetic'], api['I32']
    for c, n in [(1, 0), (2, 157), (5, 153), (273, 0), (274, 0), (5000, 0)]:
        a = arithmetic(c, n)
        check(f'C{c} N{n}: inherited implication computed', a['computed'])
        check(f'C{c} N{n}: no new charge or broad promotion',
              a['new_pool_or_bitmap_charge']==0 and not a['complete_native_capacity'])
    check('819 to 820 recognition live boundary',
          arithmetic(2,157)['derived']['recognition_pool']['retained_blocks_upper']==1 and
          arithmetic(5,153)['derived']['recognition_pool']['retained_blocks_upper']==2)
    check('2730 to 2740 instruction-register live boundary',
          arithmetic(273,0)['derived']['instruction_register_pool']['retained_blocks_upper']==1 and
          arithmetic(274,0)['derived']['instruction_register_pool']['retained_blocks_upper']==2)
    cmax = (i32-297)//15
    nmax = (1+(2*i32+1)//3-29)//5
    for c, n, passing in [(cmax,0,True), (cmax+1,0,False),
                          (1,nmax,True), (1,nmax+1,False)]:
        a = arithmetic(c,n)
        check(f'inherited last-safe/first-failing C{c} N{n}', a['computed'] is passing)
        check(f'false premise leaves no derived claim C{c} N{n}',
              passing or a['derived'] is None)
    # Check each actual map operation at its unsigned tripling boundary.
    umax = api['U32']//3
    check('unsigned map tripling last-safe', 3*umax <= api['U32'])
    check('unsigned map tripling first-failing', 3*(umax+1) > api['U32'])
    for uid in [0,1,2,28,546,547,umax]:
        cap = max(3*uid//2,uid+1)
        check(f'map growth covers UID {uid}', cap > uid)
    for c,n in [(True,0),(0,0),(1,-1),(1,False),(1,0.0)]:
        rejects(f'count domain {c!r},{n!r}',lambda c=c,n=n: arithmetic(c,n))
    for q in [819,2730]:
        pool = Pool(q)
        slots = [pool.allocate() for _ in range(q+1)]
        check(f'q{q}: rounded retained slots include free tail', pool.blocks==2)
        for slot in slots:
            pool.remove(slot)
        before = pool.blocks
        for _ in range(3*q):
            slot = pool.allocate()
            pool.remove(slot)
        check(f'q{q}: repeated calls do not grow retained backing', pool.blocks==before)
        rejects(f'q{q}: duplicate return rejected',lambda: pool.remove(slot))
        pool.release()
        check(f'q{q}: release zeroes all counters', pool.blocks==0 and not pool.live)
    for c in [1,2]:
        state = Recognition(c)
        for uid in state.spec:
            state.get(uid)
            state.get(uid)
            state.rebuild(uid)
        check(f'C{c}: get-hit and setup preserve reference envelope', max(state.refs.values())==2)
        for _ in range(5):
            for uid in state.spec:
                state.rebuild(uid)
                state.recode(uid)
                state.rebuild(uid)
                state.invalidate_registers(uid)
                state.invalidate_registers(uid)
                state.rebuild(uid)
        check(f'C{c}: repeated recreation/rebuild within original blocks',
              state.rpool.blocks==1 and state.ipool.blocks==1)
        state.final_renumber()
        state.invalidate(2)
        check(f'C{c}: final renumber preserves stored-list identity', max(state.refs.values())<=2)
        state.drain()
        check(f'C{c}: teardown after freeing register metadata',
              state.rpool.blocks==state.ipool.blocks==0)
        rejects(f'C{c}: no get after draining',lambda: state.get(0))
    state = Recognition(1)
    for uid in state.spec:
        state.rebuild(uid)
    bad = copy.deepcopy(state)
    bad.rpool.allocate()
    rejects('unmapped duplicate record allocation rejected',bad.valid)
    bad = copy.deepcopy(state)
    bad.refs[100] += 1
    rejects('setup without invalidation rejected',bad.valid)
    bad = copy.deepcopy(state)
    bad.frequency[0] = 999
    rejects('changed removal frequency violates exact weighted invariant',lambda: bad.rebuild(0))
    bad = copy.deepcopy(state)
    bad.records[0]['regs'].append((100,bad.ipool.allocate()))
    rejects('incompatible duplicate-reference route excluded',bad.valid)
    manifest = api['read'](HERE/'inputs.json')
    for key in ['first_LF_line','text']:
        changed = copy.deepcopy(manifest)
        if key == 'text': changed['excerpts'][0][key] += ' altered'
        else: changed['excerpts'][0][key] += 1
        rejects('source '+key+' mutation rejected',lambda changed=changed: api['verify_inputs'](gcc,changed))
    result['input_verification'] = verification
    (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    record = dict(status='passed', check_count=len(checks), checks=checks,
                  input_verification=verification, elapsed_check_seconds=time.perf_counter()-started,
                  recorded_UTC=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                  platform=platform.platform(), python=platform.python_version(),
                  scope='Finite local invariant/implication evidence; handwritten source theorem not mechanized',
                  native_compiler_build_capture_prover_or_predecessor_runs=0)
    (HERE/'check-results.json').write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps({k:record[k] for k in ['status','check_count','elapsed_check_seconds','input_verification']}))


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--gcc-source',required=True)
    main(ap.parse_args().gcc_source)
