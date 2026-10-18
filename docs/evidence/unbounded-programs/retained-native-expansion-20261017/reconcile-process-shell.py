#!/usr/bin/env python3
"""Reconcile selected native process-shell buffers and explicit cleanup offline.

Source pins/anchors guard reviewed inputs; they do not automate reachability.
The report supplies the selected branches, record-layout and teardown argument.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--gcc-root', type=Path, required=True)
p.add_argument('--ada-root', type=Path, required=True)
p.add_argument('--options-header', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'process-shell-inputs.json').read_bytes())
sha = lambda b: hashlib.sha256(b).hexdigest()
sources = {}
for row in identity['files']:
    base = a.gcc_root if row['root'] == 'gcc' else a.ada_root
    raw = (base / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
records = {}
for row in identity['prior_results']:
    raw = (root / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
    records[row['path']] = json.loads(raw)
raw = a.options_header.read_bytes()
assert len(raw) == identity['options_header']['bytes']
assert sha(raw) == identity['options_header']['sha256']
options = raw.decode()
assert 'OPT_z = 2555,' in options and '  N_OPTS,\n' in options
n_opts = 2556
option_spellings = re.findall(r'/\* (-[^*]*) \*/', options)
assert max(map(len, option_spellings)) == 63

anchors = {
    'gcc/main.cc': ['if (flag_checking && !seen_error ())', 'toplev.finalize ();'],
    'gcc/toplev.cc': ['unique_argv original_argv (dupargv (argv));',
        'diagnostic_finish (global_dc);', 'finalize_plugins ();',
        'if (warningcount || errorcount || werrorcount)',
        'g->get_passes ()->finish_optimization_passes ();', 'lra_finish_once ();',
        'if (g_timer && m_use_TV_TOTAL)', 'char *p = xstrndup (name, nlen - len);'],
    'gcc/diagnostics/context.cc': ['m_file_cache = new file_cache ();',
        'm_sinks.safe_push (new text_sink (*this, nullptr, true));',
        'm_diagnostic_buffer = nullptr;', 'm_logger = nullptr;',
        'for (auto iter : m_sinks)\n    iter->finalize_extensions ();',
        'while (!m_sinks.is_empty ())\n    delete m_sinks.pop ();',
        'freeargv (m_original_argv);', 'm_diagrams.m_theme = new text_art::ascii_theme ();'],
    'gcc/diagnostics/buffering.cc': ['if (buffer_ == m_diagnostic_buffer)\n    return;'],
    'gcc/diagnostics/file-cache.cc': [
        ': m_num_file_slots (16), m_file_slots (new file_cache_slot[m_num_file_slots])',
        'size_t file_cache_slot::recent_cached_lines_shift = 8;',
        'm_line_record.create (0);', 'm_line_recent.create (1U << recent_cached_lines_shift);',
        'm_line_record.release ();', 'm_line_recent.release ();'],
    'gcc/diagnostics/option-classifier.cc': [
        'm_classify_diagnostic = XNEWVEC (enum kind, n_opts);',
        'XDELETEVEC (m_classify_diagnostic);'],
    'gcc/diagnostics/text-sink.cc': ['if (m_context.diagnostic_count (kind::werror))'],
    'gcc/diagnostics/sink.h': ['virtual ~sink () {}',
        'std::vector<std::unique_ptr<extension>> m_extensions;'],
    'gcc/opts-diagnostic.cc': ['if (gcc_keys.m_cfgs)\n    sink.add_extension'],
    'gcc/diagnostics/sarif-sink.cc': [
        'const char * const env_var_name = "EXPERIMENTAL_SARIF_SOCKET";',
        'if (!socket_name)\n    return;'],
    'gcc/tree-diagnostic.cc': ['context->set_client_data_hooks (make_compiler_data_hooks ());'],
    'gcc/tree-diagnostic-client-data-hooks.cc': ['compiler_version_info m_version_info;',
        'tree_logical_location_manager m_logical_location_manager;'],
    'gcc/pretty-print.cc': ['obstack_init (&m_formatted_obstack);',
        'obstack_init (&m_chunk_obstack);', 'm_buffer->~output_buffer ();',
        'obstack_free (&m_chunk_obstack, NULL);', 'obstack_free (&m_formatted_obstack, NULL);'],
    'gcc/statistics.cc': ['if (!statistics_dump_file)\n    return;'],
    'gcc/cgraphunit.cc': ['if (debuginfo_dump_file)', 'if (debuginfo_early_dump_file)'],
    'gcc/passes.cc': ['if (dfi->graph_dump_initialized)'],
    'gcc/lra.cc': ['free (insn_code_data[i]);', 'finish_insn_code_data_once ();'],
    'gcc/plugin.cc': ['if (!plugin_name_args_tab)\n    return;'],
    'gcc/langhooks-def.h': ['#define LANG_HOOKS_FINISH\t\tlhd_do_nothing'],
    'gcc/params.opt': ['UInteger Var(param_file_cache_files) Init(16)',
        'UInteger Var(param_file_cache_lines) Init(0)'],
    'gcc/opts-common.cc': ['opt_array = XNEWVEC (struct cl_decoded_option, opt_array_len);',
        'XNEWVEC (struct cl_decoded_option, old_decoded_options_count);',
        'char *t = XOBNEWVEC (&opts_obstack, char, option->opt_len + 5);',
        '= p = XOBNEWVEC (&opts_obstack, char, total_len);'],
    'libiberty/argv.c': ['copy = (char **) xmalloc ((argc + 1) * sizeof (char *));'],
    'libiberty/obstack.c': ['size = 4096 - extra;',
        'size_t new_size = sum2 + (obj_size >> 3) + 100;'],
    'gcc-interface/misc.cc': ['save_argv = XNEWVEC (const char *, 2 * decoded_options_count + 1);'],
    'expander.adb': ['Expander_Flags.Increment_Last;', 'Expander_Flags.Decrement_Last;'],
    'errout.adb': ['Get_First_Main_File_Name & ".gnat.sarif";',
        'if not Warnsw.Warn_On_Warnings_Off then'],
    'libgnat/g-lists.ads': ['type Doubly_Linked_List is access all Doubly_Linked_List_Attributes;'],
    'treepr.adb': ['if Debug_Flag_Y then', 'if Debug_Flag_T then'],
}
for name, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[name], (name, snippet)
assert '#define LANG_HOOKS_FINISH' not in sources['gcc-interface/misc.cc']
assert 'adafinal' not in sources['gcc-interface/misc.cc']

actual = records['fixed-gcc-prefix-witness/frontend-exec.json']
assert set(actual['environment']) == {
    'PATH', 'LC_ALL', 'LANG', 'TERM', 'TMPDIR', 'ADA_INCLUDE_PATH',
    'ADA_OBJECTS_PATH', 'GCC_EXEC_PREFIX', 'COLLECT_GCC', 'COLLECT_GCC_OPTIONS'}
assert actual['environment']['LC_ALL'] == actual['environment']['LANG'] == 'C'
assert actual['environment']['TERM'] == 'dumb'
assert '-quiet' in actual['argv']
indexed = records['native-indexed-invocation.json']
assert indexed['gnat1_argc_bound'] == indexed['decoded_option_count_bound'] == 22
extra = records['native-no-xref-proposal.json']['combined_with_native_warning_option']['added_switches']
assert extra == ['-gnatx', '-Wno-free-nonheap-object']
argc = indexed['gnat1_argc_bound'] + len(extra)
assert argc == 24
# This length includes '='. Older P+7 prose/arithmetic omitted that byte.
assert len('-gnatec=') == len('-gnatem=') == 8

fixed_requests = {
    'original_argv_pointers': 8 * (argc + 1),
    'decoded_option_array_each': 96 * argc,
    'save_optimization_vector_backing_upper': 8 + 96 * (2 * argc),
    'reconstructed_C_argv': 8 * (2 * argc + 1),
    'gnat_runtime_argv': 8,
    'single_input_filename_pointer': 8,
    'diagnostic_option_classifier': 4 * n_opts,
    'diagnostic_file_slot_array_upper_with_cookie': 16 * 256 + 8,
    'diagnostic_recent_lines_vector_each': 8 + 256 * 24,
    'selected_diagnostic_control_object_upper_each': 512,
    'initial_obstack_chunk_upper_each': 4096,
    'diagnostic_sink_vector_upper': 8 + 4 * 8,
    'diagnostic_urlifier_vector_upper': 8 + 4 * 16,
}
assert max(fixed_requests.values()) == 10224

def path_requests(pathname_chars):
    # P already bounds every path, raw and resolved, including argv[0].
    arg = max(24, pathname_chars + 8)
    # Up to four canonical elements, fixed option spelling<=63, no- adds3,
    # four separators/NUL and signed HOST_WIDE_INT decimal spelling<=21.
    # This deliberately also pays ordinary generated default-option spelling.
    option_object = 4 * (arg + 67)
    chunk = max(4096, option_object + 116)
    objects = {
        'copied_argv_String_including_NUL': arg + 1,
        'option_spelling_object_upper': option_object,
        'option_obstack_chunk_upper': chunk,
        'auxiliary_basename_including_NUL': pathname_chars + 1,
        'Ada_SARIF_filename_with_descriptor': pathname_chars + 11 + 16,
    }
    return {'pathname_chars': pathname_chars, 'largest_selected_argument_chars': arg,
            'individual_requests': objects,
            'signed_int_path_and_option_arithmetic_fits': option_object + 116 <= 2**31 - 1,
            'individual_pointer_differences_fit': max(objects.values()) <= 2**63 - 1}

result = {
    'scope': 'Selected indexed null process-shell buffers and explicit successful cleanup only',
    'verified_source_files': len(sources),
    'verified_prior_records': len(records),
    'proposed_indexed_native_gnat1_argc_upper': argc,
    'corrected_config_map_argument_prefix_characters': 8,
    'N_OPTS': n_opts,
    'maximum_generated_option_spelling_chars': 63,
    'fixed_individual_ordinary_requests_upper': fixed_requests,
    'path_condition': 'P bounds every raw/normalized/resolved path; 4*(max(24,P+8)+67)+116 <= INT_MAX',
    'path_arithmetic_examples_not_admission_results': [path_requests(200), path_requests(737)],
    'diagnostic_source_cache_reads_with_zero_messages': 0,
    'explicit_GCC_tail_new_GGC_events': 0,
    'explicit_GCC_tail_ordinary_allocation_requests': 0,
    'Ada_tail_already_priced_interfaces': [
        'Namet unlock release via core table backing',
        'one temporary Expander_Flags save via existing stack peak',
        'unconditional returned filename and P+11 SARIF concatenation',
        'null SARIF access fields and 24-byte printer control',
        'complete ALI serialization and selected open/close interfaces'],
    'optional_toplev_finalize_called': False,
    'known_GGC_subtotal_unchanged': 40098,
    'fixed_startup_managers_and_target_requests_all_closed': False,
    'C_Cpp_static_finalization_and_host_library_buffers_closed': False,
    'whole_process_capacity_or_whole_invocation_GGC_count_established': False,
    'aggregate_RAM_or_address_space_admission_gate': False,
    'native_tool_executions': 0,
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ['verified_source_files', 'N_OPTS',
    'proposed_indexed_native_gnat1_argc_upper', 'explicit_GCC_tail_new_GGC_events',
    'whole_process_capacity_or_whole_invocation_GGC_count_established']}))
