#!/usr/bin/env python3
"""Focused static Start-owner identities, arithmetic, and abstract prefix check.

Never runs gnatwhy3, Re, a compiler, or a predecessor evidence checker.
The finite model checks the publication invariant; it is not an engine test.
"""
import hashlib
import itertools
import json
import pathlib
import struct
import sys
import time
from dataclasses import dataclass, replace

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(ROOT / "docs/evidence/retained-why-library-probe-paths-20261023"))
from elf_reader import Elf, identity


@dataclass(frozen=True)
class Owner:
    lazy: str = "unforced"
    keys: int = 0
    size: int = 0
    initial: bool = False
    transition: bool = False
    final: bool = False
    adds: int = 0
    events: int = 0


def successors(incoming, empty):
    """Overapproximate interruption at each persistent publication boundary.

    A cached poison can rethrow without a new event. Each new external event
    can stop the current invocation; no call locally resumes an interrupted
    add, delta, or cache-construction continuation.
    """
    state = incoming
    prefixes = [state]
    if state.lazy == "poison":
        return {state}
    if state.lazy == "unforced":
        if state.events < 2:
            prefixes.append(replace(state, lazy="poison"))
        state = replace(state, lazy="ready")
        prefixes.append(state)

    def publish(**updates):
        nonlocal state
        state = replace(state, **updates)
        prefixes.append(state)

    def add(key):
        if not state.keys & key:
            publish(adds=state.adds + 1)
            publish(keys=state.keys | key)
            publish(size=state.size + 1)

    if not state.initial:
        add(1)
        publish(initial=True)
    if empty:
        if not state.final:
            publish(final=True)
    elif not state.transition:
        add(2)
        publish(transition=True)
    out = {state}
    if incoming.events < 2:
        out.update(replace(s, events=incoming.events + 1) for s in prefixes)
    return out


def check_prefixes():
    seen = {Owner()}
    pending = list(seen)
    while pending:
        s = pending.pop()
        assert 0 <= s.size <= s.keys.bit_count() <= 2
        assert s.adds <= 2 + s.events <= 4
        assert not s.initial or s.keys & 1
        assert not s.transition or (s.initial and s.keys == 3)
        assert not s.final or s.initial
        assert s.lazy != "poison" or s.keys == 0
        for empty in (False, True):
            for t in successors(s, empty):
                if t not in seen:
                    seen.add(t)
                    pending.append(t)
    # With one global allowance, even both interruptions in the same triplet
    # cannot affect all three distinct owners. No per-triplet budget is renewed.
    assignments = 0
    for count in range(3):
        for affected in itertools.product(range(9), repeat=count):
            bad = set(affected)
            assert all(any(i not in bad for i in range(j, j + 3))
                       for j in (0, 3, 6))
            assignments += 1
    return len(seen), assignments


def check_shape():
    # Symbolic selected tree, not execution of an installed/reference engine.
    tree = ("seq", ("mark", 0),
            ("seq", ("after", 32), ("mark", 1)))
    def derive(node, marks, category):
        tag = node[0]
        if tag == "seq":
            first = derive(node[1], marks, category)
            assert first is not None
            return derive(node[2], first, category)
        if tag == "after":
            return marks if category & node[1] else None
        assert tag == "mark"
        return [(node[1], -1)] + [(m, i) for m, i in marks if m != node[1]]
    for next_category in range(64):
        # next_category is irrelevant to After: both empty and nonempty cases.
        before = derive(tree, [], 33)
        assert before == [(1, -1), (0, -1)]
        used = {i for _, i in before if i >= 0}
        assert not used
        idx = next(i for i in range(1) if i not in used)
        assert [(m, idx) for m, _ in before] == [(1, 0), (0, 0)]
    assert -8 - (-8 - 1) == 1
    assert -9 < -5 < -3


def main():
    started = time.monotonic()
    inputs = json.loads((HERE / "inputs.json").read_text())
    for name, expected in inputs["files"].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    old_dir = ROOT / "docs/evidence/retained-re-native-correspondence-20261023"
    old = json.loads((old_dir / "native.json").read_text())
    new = json.loads((HERE / "native-supplement.json").read_text())
    binary = pathlib.Path(new["target"]).read_bytes()
    assert identity(binary) == new["target_identity"] == old["target_identity"]
    elf = Elf(binary)
    native_count = 0
    for packet, directory, names in (
        (old, old_dir, inputs["reused_functions"]),
        (new, HERE, sorted(new["functions"])),
    ):
        for name in names:
            record = packet["functions"][name]
            code = elf.function(name)
            assert code.hex() == record["hex"], name
            assert identity(code) == record["identity"], name
            assert identity((directory / record["disassembly"]).read_bytes()) == record["disassembly_identity"], name
            native_count += 1
    for packet, label, slot, target in (
        (new, "colorize_immediate_dispatch", 8, 0x91e17c),
        (new, "colorize_block_dispatch", 4, 0x91e188),
        (old, "translate_immediate_dispatch", 8, 0x9229ac),
        (old, "translate_block_dispatch", 4, 0x922d18),
    ):
        d = packet["data"][label]
        b = elf.at(d["address"], d["bytes"])
        assert b.hex() == d["hex"]
        assert d["address"] + struct.unpack_from("<i", b, 4 * slot)[0] == target
    for w in inputs["instruction_witnesses"]:
        assert elf.at(w["address"], len(bytes.fromhex(w["hex"]))).hex() == w["hex"]
        assert w["line"] in (ROOT / w["file"]).read_text()

    check_shape()
    states, assignments = check_prefixes()
    parse = 52 + 3 + 3 + 15
    compile_words = 3 + 3 + (34 + 7 + 34 + 34 + 2 + 3) + 17 + 35 + 13 + 134 + 12
    delta = 4 + 21 + 15 + 4 + 6 + 3 + 21 + 25 + 6
    call = 31 + 128 + 23 + 20
    assert parse == 73 <= 128
    assert compile_words == 331 and compile_words + 4 <= 512
    assert delta == 105 <= 128
    assert call == 202 <= 256
    result = {
        "candidate_hex": "5c3d", "rejected_candidate_hex": "5c60",
        "native_bodies_checked": native_count,
        "instruction_witnesses": len(inputs["instruction_witnesses"]),
        "fixed_files": len(inputs["files"]), "publication_model_states": states,
        "global_event_owner_assignments": assignments,
        "ordinary_colors": 1, "expression_allocations_per_compile": 5,
        "state_table_keys_per_owner": 2, "state_table_buckets": 128,
        "working_bits": 1, "working_hint": 0, "positions_length": 1,
        "marks_length": 2, "packed_scratch_allocations": 0,
        "parse_credit_words": 128, "first_force_credit_words": 512,
        "per_search_credit_words": 256, "nine_owner_fixed_credit_words": 5760,
        "max_single_owned_allocation_words": 129,
        "target_executions": 0, "engine_executions": 0,
        "elapsed_seconds": time.monotonic() - started,
        "proof_scope": "Static identities, selected operand witnesses, small arithmetic and abstract publication closure; semantic justification is the research note."
    }
    (HERE / "result.json").write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    main()
