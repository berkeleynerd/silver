#!/usr/bin/env python3
"""Offline identity, route-landmark, interface and boundary checks only."""
import argparse
from datetime import datetime, timezone
import gzip
import hashlib
import json
from pathlib import Path
import platform
import re
import runpy
import subprocess
import time

from derive import evaluate, evaluate_source, identity, I32, PREFIX_EVENTS

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
NATIVE = 'docs/evidence/unbounded-programs/retained-native-expansion-20261017/'


def region(source, start, end):
    first = source.index(start)
    return source[first:source.index(end, first+len(start))]


def main():
    started = datetime.now(timezone.utc)
    timer = time.perf_counter()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root', type=Path,
                        default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--ada-root', type=Path,
                        default=Path('/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada'))
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    manifest = json.loads((HERE/'source-manifest.json').read_bytes())
    checked = []

    def check(name, value):
        if not value:
            raise AssertionError(name)
        checked.append(name)

    history = {}
    for row in manifest['historical_silver_inputs']:
        raw = subprocess.check_output(['git', 'show',
            manifest['reviewed_silver_revision']+':'+row['path']], cwd=REPO)
        check('historical_input:'+row['path'],
              identity(raw) == {key: row[key] for key in ('bytes', 'sha256')})
        history[row['path']] = raw

    sources = {}
    for row in manifest['files']:
        path = (args.ada_root/row['path'].removeprefix('gcc/ada/')
                if row['root'] == 'ada' else args.gcc_root/row['path'])
        raw = path.read_bytes()
        check('complete_source:'+row['path'],
              identity(raw) == {key: row[key] for key in ('bytes', 'sha256')}
              and hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()
              == row['git_blob_sha1'])
        origin = row['retained_identity_origin']
        if origin:
            original = json.loads(history[origin])
            matches = [r for r in original['files'] if
                       (r['path'] if r['path'].startswith('gcc/') else 'gcc/'+r['path'])
                       == row['path']]
            check('existing_source_origin:'+row['path'],
                  any({key:r[key] for key in ('bytes','sha256')} == identity(raw)
                      for r in matches))
        else:
            check('retained_supplemental_source:'+row['path'],
                  gzip.decompress((HERE/row['retained_copy']).read_bytes()) == raw
                  and row['upstream_origin']['manifest_entry'] ==
                  dict(path=row['path'], **identity(raw))
                  and manifest['gcc_revision'] in row['upstream_origin']['url'])
        sources[row['path']] = raw.decode()

    emit, varasm, final = [sources['gcc/'+name] for name in
                          ('emit-rtl.cc', 'varasm.cc', 'final.cc')]
    check('ordinary_counter_initial_increment_and_loader_assignment',
          'static GTY(()) int label_num = 1;' in emit
          and len(re.findall(r'\blabel_num\+\+', emit)) == 1
          and len(re.findall(r'\blabel_num\s*=(?!=)', emit)) == 2
          and 'NULL, label_num++, NULL)' in emit
          and 'label_num = CODE_LABEL_NUMBER (x) + 1;' in emit)
    check('RTL_loader_is_explicit_alternate_counter_writer',
          'maybe_set_max_label_num (label);' in sources['gcc/read-rtl-function.cc'])
    check('generated_RTL_constructor_allocates',
          'rt = rtx_alloc (code PASS_MEM_STAT);' in sources['gcc/gengenrtl.cc']
          and 'ggc_alloc_rtx_def_stat (RTX_CODE_SIZE (code) + extra' in sources['gcc/rtl.cc'])
    check('function_label_snapshot_not_global_reset',
          'first_label_num = label_num;' in emit
          and 'max_labelno - min_labelno + 1' in final)
    check('constant_counter_four_increment_sites',
          'static GTY(()) int const_labelno;' in varasm
          and len(re.findall(r'\bconst_labelno\+\+|\+\+const_labelno\b', varasm)) == 4
          and 'const_labelno = 0;' in region(varasm, '\nvarasm_cc_finalize ()', '#include "gt-varasm.h"'))
    check('tree_and_RTL_descriptors_allocate_before_increment',
          region(varasm, '\nbuild_constant_desc (', '\n/*').index('ggc_alloc<constant_descriptor_tree>')
          < region(varasm, '\nbuild_constant_desc (', '\n/*').index('const_labelno++')
          and region(varasm, '\nforce_const_mem (', '\n/*').index('ggc_alloc<constant_descriptor_rtx>')
          < region(varasm, '\nforce_const_mem (', '\n/*').index('++const_labelno'))
    function = sources['gcc/function.cc']
    check('return_label_and_static_return_space_belong_to_expansion',
          'return_label = gen_label_rtx ();' in region(function, '\nexpand_function_start (', '\n/*')
          and 'if (aggregate_value_p (res, subr))' in function
          and function.count('assemble_static_space (size);') == 1)
    check('partition_counter_guard',
          'if (crtl->has_bb_partition)' in region(varasm, '\nassemble_start_function (', '\n/*'))
    cfi = sources['gcc/dwarf2cfi.cc']
    check('CFI_actual_unsigned_to_signed_and_buffer_consumers',
          'unsigned long dwarf2out_cfi_label_num;' in cfi
          and 'int num = dwarf2out_cfi_label_num++;' in cfi and 'char label[20];' in cfi)
    check('final_scan_single_global_increment',
          'static int insn_counter = 0;' in final and final.count('insn_counter++;') == 1)

    check('external_reference_reaches_pending_set',
          'assemble_external (t);' in final
          and 'if (! pending_assemble_externals_set->add (decl))' in varasm)
    external = region(varasm, '\ndefault_elf_asm_output_external (', '\n/*')
    visibility = region(varasm, '\nmaybe_assemble_visibility (', '\n/*')
    check('ELF_external_writer_only_visibility',
          external.count('maybe_assemble_visibility (decl);') == 1
          and not re.search(r'\b(?:fprintf|fputs|assemble_name)\s*\(', external)
          and 'if (vis != VISIBILITY_DEFAULT)' in visibility
          and 'else\n    return false;' in visibility)
    check('declaration_default_visibility_zero',
          re.search(r'enum symbol_visibility\s*\{\s*VISIBILITY_DEFAULT,', sources['gcc/coretypes.h'])
          and 't = ggc_alloc_cleared_tree_node_stat (length PASS_MEM_STAT);' in sources['gcc/tree.cc'])
    for name in manifest['selected_target_headers']:
        check('selected_header_external_writer:'+name,
              name == 'gcc/config/elfos.h' or
              not re.search(r'^\s*#\s*define\s+ASM_OUTPUT_EXTERNAL\b', sources[name], re.M))
    check('selected_ELF_external_hook',
          'default_elf_asm_output_external (FILE, DECL, NAME)' in sources['gcc/config/elfos.h'])
    check('dummy_and_already_written_pool_skip_variable_output',
          'if (DECL_HARD_REGISTER (decl))\n    return false;' in sources['gcc/varpool.cc']
          and 'if (DECL_IN_CONSTANT_POOL (decl) && TREE_ASM_WRITTEN (decl))' in sources['gcc/varpool.cc'])
    check('unit_tail_writer_inventory', all(name in sources['gcc/toplev.cc'] for name in
          ('output_shared_constant_pool ();', 'output_object_blocks ();', 'finish_tm_clone_pairs ();',
           'weak_finish ();', 'targetm.asm_out.code_end ();', 'dwarf2out_frame_finish ();',
           'dw2_output_indirect_constants ();', 'process_pending_assemble_externals ();',
           'targetm.asm_out.file_end ();')))
    check('GAS_CFI_finish_cutpoint', 'if (dwarf2out_do_cfi_asm ())' in sources['gcc/dwarf2out.cc'])
    check('Main_only_gigi_constant_materialization_site',
          sources['gcc/ada/gcc-interface/trans.cc'].count('tree_output_constant_def (op)') == 1)

    prefix = json.loads(history[NATIVE+'native-gcc-prefix-witness.json'])
    check('retained_fixed_prefix_not_new_capture',
          prefix['counters']['ggc_bytes']['positive_events'] == PREFIX_EVENTS
          and not prefix['counter_wrap_or_reset'] and not prefix['collection_or_new_thread_observed'])
    counter = json.loads(history['docs/evidence/retained-literal-counter-emission-20261018/interface.json'])
    check('accepted_exact_emission_frontier',
          counter['emitted_functions'] == 1 and counter['ordinary_lowered_functions'] == 1
          and counter['main_function_boundary_labels'] == ['.LFB1','.LFE1']
          and counter['next_function_definition_number'] == 4)
    assembler_path = 'docs/evidence/retained-literal-assembler-20261018/compose.py'
    check('current_assembler_interface_matches_frozen_input',
          (REPO/assembler_path).read_bytes() == history[assembler_path])
    assembler = runpy.run_path(str(REPO/assembler_path))['interface']
    for c in (1,2,3,17,5000):
        for n in (0,1,2,19,5001):
            for length in (0,1,13,256,5000):
                w = c*length
                result, previous = evaluate(c,n,w,length), assembler(c,n,w,length)
                check(f'complete_assembler_join:{c}:{n}:{length}',
                      result['assembly'] == previous['assembly']
                      and result['text_bytes_upper'] == previous['text_bytes_upper']
                      and result['final_chain'] == previous['final_chain']
                      and result['emission']['rodata_bytes_upper'] == previous['GAS']['rodata_bytes_upper']
                      and result['emission']['symbol_name_bytes_including_NUL_upper']
                      == previous['GAS']['symbol_name_bytes_including_NUL_upper']
                      and not result['production_invocation_and_materialization_established']
                      and not result['whole_literal_pipeline_capacity_established'])

    # Independent last-fitting arithmetic for two distinct global consumers.
    nlast = (I32-1-PREFIX_EVENTS-45-7)//7
    check('ordinary_last_passing_first_failing_endpoint',
          evaluate(1,nlast,0,0)['counter_and_emission_guards']['ordinary_label_next_signed_int']
          and not evaluate(1,nlast+1,0,0)['counter_and_emission_guards']['ordinary_label_next_signed_int'])
    clast = (I32-PREFIX_EVENTS)//2
    check('constant_last_passing_first_failing_endpoint',
          evaluate(clast,0,0,0)['counter_and_emission_guards']['constant_label_next_signed_int']
          and not evaluate(clast+1,0,0,0)['counter_and_emission_guards']['constant_label_next_signed_int'])
    huge = evaluate(10**100,10**100,0,0)
    check('large_mathematical_counts_return_failed_guards_without_wrap',
          not huge['counter_and_emission_guards_fit']
          and huge['counter_bounds']['ordinary_label_next_at_exit_upper'] > 10**100)
    check('actual_name_and_CFI_temporary_widths',
          len('.L'+str(I32-1)) <= 25 and len('.LC'+str(I32-1)) <= 25
          and len('*.LCFI4')+1 <= 20)

    shell = b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin '
    tail = b' end Main;'
    cases = [
        (b'Silver_IO.Put ("");', (1,0,0,0)),
        (b'Silver_IO.Put ("a""b"); null; Silver_IO.Put_Line ("\\");', (2,1,4,3)),
        (b'null; -- not a call: Silver_IO.Put ("fake");\r\nSiLvEr_Io.PuT_Line ("x");', (1,1,1,1)),
        (b'Silver_IO.Put ("x");'*5000, (5000,0,5000,1)),
    ]
    for index,(body, expected) in enumerate(cases):
        selected = evaluate_source(shell+body+tail)
        check('complete_source_case:'+str(index),
              selected['counts'] == dict(zip(('calls','nulls','decoded_bytes','maximum_literal_length'),expected)))
    invalid = [b'', shell+b'null;'+tail, shell+b'Silver_IO.Put ("x");'+tail+b' garbage',
               shell+b'Put ("x");'+tail, shell+b'Silver_IO.Put ("x");\v'+tail,
               shell+b'Silver_IO.Put ("x");\f'+tail,
               shell+b'Silver_IO.Put ("\x80");'+tail]
    for index,raw in enumerate(invalid):
        try:
            evaluate_source(raw)
        except ValueError:
            check('invalid_source:'+str(index), True)
        else:
            raise AssertionError('accepted invalid source:'+str(index))
    for index,args4 in enumerate([(True,0,0,0),(1,False,0,0),(0,0,0,0),
                                  (1,-1,0,0),(1,0,2,1),(2,0,1,2),(1,0,0.0,0)]):
        try:
            evaluate(*args4)
        except ValueError:
            check('invalid_counts:'+str(index), True)
        else:
            raise AssertionError('accepted invalid counts:'+str(index))

    completed = datetime.now(timezone.utc)
    result = dict(checks_passed=len(checked), checks=checked,
                  complete_sources_verified=len(sources), historical_inputs_verified=len(history),
                  native_tool_executions=0, whole_literal_pipeline_capacity_established=False,
                  selected_model='GPT-6 Astra', selected_effort='Extra High',
                  runtime_model_effort_confirmation=None, token_cost_measurements=None,
                  actual_host=platform.platform(), checker_started_utc=started.isoformat(),
                  checker_completed_utc=completed.isoformat(), checker_elapsed_seconds=time.perf_counter()-timer,
                  round_started_utc='2026-10-18T22:13:53+00:00',
                  round_elapsed_seconds=(completed-datetime(2026,10,18,22,13,53,tzinfo=timezone.utc)).total_seconds())
    if args.output:
        args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({key:result[key] for key in ('checks_passed','complete_sources_verified',
                     'historical_inputs_verified','checker_elapsed_seconds','native_tool_executions')}))


if __name__ == '__main__':
    main()
