#!/usr/bin/env python3
"""Conditional recognition arithmetic/source evidence; not a source adapter."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
I32, U32, SIZE = 2**31-1, 2**32-1, 2**64-1
UPSTREAM = '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
ATTACHMENT = 'docs/evidence/retained-literal-ira-lra-helper-attachment-20261019/result.json'
OWNER_PATH = 'core_result.selected_native_backing.LRA_register_and_recognition_backing'
API_PATTERN = (r'\b(lra_(set_insn_recog_data|update_insn_recog_data|invalidate_insn_data|'
               r'invalidate_insn_regno_info|update_insn_regno_info|set_insn_deleted|'
               r'push_insn_and_update_insn_regno_info))\s*\(')
WRITE_PATTERN = (r'lra_insn_recog_data\[.*\]\s*=|insn_code_data\[.*\]\s*=|'
                 r'lra_reg_info\[.*\]\.(nrefs|freq)\s*(\+\+|--|\+=|-=|=)|'
                 r'\b(setup_insn_reg_info|new_insn_reg|free_insn_regs)\s*\(|'
                 r'\blra_insn_reg_pool\.(allocate|remove|release)\s*\(')


def require(value, message):
    if not value:
        raise ValueError(message)


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def inventory(gcc, pattern):
    result = subprocess.run(['rg', '-n', '--glob', '*.cc', '--glob', '*.h',
                             pattern, 'gcc'], cwd=gcc, capture_output=True,
                            text=True, check=False)
    require(result.returncode in (0, 1), 'source inventory search failed')
    return sorted(result.stdout.rstrip('\n').split('\n')) if result.stdout else []


def verify_inputs(gcc, manifest=None):
    manifest = read(HERE/'inputs.json') if manifest is None else manifest
    require(manifest['gcc_revision'] == UPSTREAM, 'GCC revision')
    roots = dict(gcc=Path(gcc), repository=REPO)
    for row in manifest['files']:
        raw = (roots[row['root']]/row['path']).read_bytes()
        expected = {k: row[k] for k in ('bytes', 'sha256')}
        require(identity(raw) == expected, 'input bytes: '+row['path'])
        if 'revision' in row:
            old = subprocess.check_output(['git', 'show', row['revision']+':'+row['path']], cwd=REPO)
            require(identity(old) == expected, 'accepted Git bytes: '+row['path'])
    for row in manifest['excerpts']:
        # splitlines() would incorrectly count GCC form feeds as source lines.
        lines = (roots[row['root']]/row['path']).read_text().split('\n')
        actual = '\n'.join(lines[row['first_LF_line']-1:row['last_LF_line']])
        require(actual == row['text'] and identity(actual.encode()) == row['identity'],
                'literal LF excerpt: '+row['name'])
        require(all(x in actual for x in row['operative_fragments']),
                'operative fragments: '+row['name'])
    for key, pattern in [('mutation_API_inventory', API_PATTERN),
                         ('owner_writer_inventory', WRITE_PATTERN)]:
        require(inventory(gcc, pattern) == manifest[key], key)
    for archive in manifest['retained_headers']:
        with tarfile.open(REPO/archive['path']) as handle:
            for member in archive['members']:
                raw = handle.extractfile(member['path']).read()
                require(identity(raw) == member['identity'], 'retained header identity')
                require(all(x.encode() in raw for x in member['operative_fragments']),
                        'retained header constants')
    return dict(GCC_files=sum(r['root']=='gcc' for r in manifest['files']),
                repository_files=sum(r['root']=='repository' for r in manifest['files']),
                literal_LF_excerpts=len(manifest['excerpts']),
                mutation_API_occurrences=len(manifest['mutation_API_inventory']),
                owner_writer_occurrences=len(manifest['owner_writer_inventory']),
                retained_headers=sum(len(a['members']) for a in manifest['retained_headers']))


def arithmetic(c, n):
    require(type(c) is int and c >= 1 and type(n) is int and n >= 0, 'C/N domain')
    k, m, u = 99+5*c, 7*c+5*n+20, 7*c+5*n+22
    h = max(3*(u-1)//2, u)
    premises = dict(LRA_register_tripling_signed_intermediate=3*k <= I32,
                    LRA_instruction_UID_signed=u <= I32,
                    LRA_recognition_tripling_unsigned_intermediate=3*(u-1) <= U32,
                    LRA_recognition_stored_capacity_signed=h <= I32,
                    LRA_recognition_array_byte_product=8*h <= SIZE)
    # These are consumed existing conditions, not newly exported guards.
    derived = None
    if all(premises.values()):
        rq, iq = 819, 2730
        rb, ib = (m+rq-1)//rq, (10*c+iq-1)//iq
        rs, ins = rq*rb, iq*ib
        require(rs <= m+818 <= I32+816, 'recognition implication')
        require(ins <= 10*c+2729 < 2**32, 'instruction pool implication')
        require(max(rs, ins, rb, ib) <= SIZE, 'retained size_t counters')
        derived = dict(recognition_pool=dict(live_upper=m, slots_per_block=rq,
                            retained_blocks_upper=rb, retained_slots_upper=rs),
                       instruction_register_pool=dict(live_upper=10*c, slots_per_block=iq,
                            retained_blocks_upper=ib, retained_slots_upper=ins),
                       per_pseudo_nrefs_upper=2, per_pseudo_frequency_upper=2000,
                       per_instruction_frequency_upper=1000,
                       argument_stack_entries_used=3, argument_stack_entries_available=92,
                       operands_upper=2, operands_available=30, alternatives_upper=35,
                       alternative_mask_bits=64, maximum_shift=34,
                       alternative_entries_upper=70, constraint_pointer_scratch_bytes_upper=16,
                       signed_char_largest_nonnegative_count=35,
                       asm_reloads_num=0,
                       map_entries_upper=h, map_request_bytes_upper=8*h,
                       new_numeric_restrictions=0)
    return dict(C=c, N=n, K=k, M=m, U=u, inherited_arithmetic_premises=premises,
                computed=derived is not None, derived=derived,
                source_and_configuration_join_required=True,
                actual_source_adapter=False, independently_reviewed=False,
                new_GGC_events=0, new_finalizer_registrations=0,
                new_pool_or_bitmap_charge=0, all_LRA_capacity=False,
                complete_native_capacity=False, whole_pipeline_capacity=False,
                lifetime_ordinary_allocations=None, aggregate_RAM_gate=False)


def fixture():
    # Fixed retained evidence only. No evaluator, Context or prior script runs.
    old = read(REPO/ATTACHMENT)
    for key in ('conditions', 'conditional_conditions'):
        require(len(old[key]) == 367 and all(v is True for v in old[key].values()),
                'fixed accepted 367-map')
    require(old['source_counts']['output_calls'] == 1, 'fixed fixture C')
    require(old['source_counts']['null_statements'] == 0, 'fixed fixture N')
    owner = old['core_result']['selected_native_backing']['LRA_register_and_recognition_backing']
    value = arithmetic(1, 0)
    d = value['derived']
    require(owner['recognition_pointer_entries_upper'] == d['map_entries_upper'] and
            owner['recognition_pointer_request_bytes_upper'] == d['map_request_bytes_upper'] and
            owner['live_recognition_records_upper'] == d['recognition_pool']['live_upper'] and
            owner['recognition_pool_blocks_upper'] == d['recognition_pool']['retained_blocks_upper'] and
            owner['live_instruction_register_records_upper'] == d['instruction_register_pool']['live_upper'] and
            owner['instruction_register_pool_blocks_upper'] == d['instruction_register_pool']['retained_blocks_upper'] and
            owner['referenced_pseudo_nrefs_upper'] == d['per_pseudo_nrefs_upper'], 'accepted owner relation')
    return dict(scope='Conditional source theorem and fixed accepted-owner reconciliation; review pending',
                arithmetic=value, accepted_fixture=dict(path=ATTACHMENT, source=old['source'],
                    source_counts=old['source_counts'], owner_path=OWNER_PATH, complete_owner=owner,
                    guard_count=367, source_correspondence_reused=True),
                new_source_guards=0, new_allocation_owners=0,
                complete_dynamic_recognition_lifetime_conditional=True,
                remaining_scope=['actual-source successor', 'other outer IRA/imported helpers',
                    'other LRA arithmetic/automatic storage/elimination offsets',
                    'complete native/producer/proof/parent and production correspondence'])


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--gcc-source', required=True)
    ap.add_argument('--output', required=True)
    args = ap.parse_args()
    result = fixture()
    result['input_verification'] = verify_inputs(args.gcc_source)
    Path(args.output).write_text(json.dumps(result, indent=2)+'\n')
