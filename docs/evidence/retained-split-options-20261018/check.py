"""Replay the retained stock split-wide option deltas without native tools."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--gcc-root', type=Path,
                    help='Also recheck the complete pre-existing GCC corpus and negative inventory')
args = parser.parse_args()
root = Path(__file__).resolve().parent
sha = lambda b: hashlib.sha256(b).hexdigest()
inputs = {}
for row in json.loads((root/'inputs.json').read_bytes()):
    raw = (root/row['file']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
    inputs[row['file']] = json.loads(raw)
manifest = json.loads((root/'sources.json').read_bytes())
archive = manifest['archive']
raw = (root/archive['file']).read_bytes()
assert len(raw) == archive['bytes'] and sha(raw) == archive['sha256']
sources = {}
with tarfile.open(root/archive['file']) as t:
    assert sorted(t.getnames()) == sorted(r['path'] for r in manifest['files'])
    for row in manifest['files']:
        raw = t.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        sources[row['path']] = raw
corpus_raw = gzip.decompress((root/'gcc-corpus-manifest.json.gz').read_bytes())
assert sha(corpus_raw) == '6f0991bf5e0e98ab27d165696913f4db31a9bd9336afcc48937cdbdb0de12480'
corpus = json.loads(corpus_raw)
assert corpus['commit'] == manifest['gcc_commit'] == '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
assert len(corpus['files']) == 4929
by_path = {r['path']:r for r in corpus['files']}
ada_raw = gzip.decompress((root/'ada-source-manifest.json.gz').read_bytes())
assert sha(ada_raw) == 'f0425c46cd96b9348767de5456e4e0fb1efd818ca811e244a150811b353e223c'
ada = json.loads(ada_raw)
assert ada['commit'] == corpus['commit']
ada_by_path = {'gcc/ada/'+r['path']:r for r in ada['files']}
for name, raw in sources.items():
    if name in by_path:
        row = by_path[name]
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
    if name in ada_by_path:
        row = ada_by_path[name]
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
mentions = json.loads((root/'flag-mentions.json').read_bytes())
assert len(mentions) == 14
for hit in mentions:
    assert sources[hit['path']].decode().split('\n')[hit['line']-1].strip() == hit['text']
regex = re.compile(rb'\b(?:flag_split_wide_types(?:_early)?|OPT_fsplit_wide_types(?:_early)?)\b|fsplit-wide-types')
if args.gcc_root:
    assert (args.gcc_root/'manifest.json').read_bytes() == corpus_raw
    rebuilt = []
    for row in corpus['files']:
        raw = (args.gcc_root/row['path']).read_bytes()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        for n, line in enumerate(raw.split(b'\n'),1):
            if regex.search(line):
                rebuilt.append({'path':row['path'],'line':n,'text':line.decode().strip()})
    assert rebuilt == mentions

# These are identity landmarks. The report supplies their selected-path meaning.
anchors = {
    'gcc/common.opt':['fsplit-wide-types\nCommon Var(flag_split_wide_types) Optimization'],
    'gcc/ada/gcc-interface/lang-specs.h':['%{g*&m*&f*}'],
    'gcc/opts-common.cc':['if (flag_var)\n    set_option', '*(int *) flag_var = value;'],
    'gcc/toplev.cc':['save_opt_decoded_options->safe_push (save_decoded_options[i]);',
                      'if (flag_record_gcc_switches)', 'if (flag_verbose_asm)'],
    'gcc/tree.cc':['cl_option_hash_table->find_slot (cl_optimization_node, INSERT)'],
    'gcc/ada/gcc-interface/misc.cc':['2 * decoded_options_count + 1'],
    'gcc/ada/back_end.adb':['Store_Compilation_Switch (Switch_Chars);'],
    'gcc/ada/lib.adb':['Compilation_Switches.Increment_Last;', "new String'(Switch);"],
    'gcc/ada/lib-writ.adb':["Write_Info_Initiate ('A');"],
    'gcc/vec.cc':['alloc = (alloc * 3 / 2);'],
    'gprbuild/src/gprbind.adb':['Read_Lines    => "A"',
                                'Compiler_Options.Append (Arg.all);'],
}
for name, snippets in anchors.items():
    txt = sources[name].decode()
    for snippet in snippets:
        assert snippet in txt, (name,snippet)

old = inputs['driver-before.json']
assert (old['initial_argv_positions'], old['frontend_argv_positions'],old['retained_switches']) == (13,19,11)
assert old['argbuf_capacity'] == 20 and old['argbuf_object_bytes'] == 168
old_shell = inputs['process-shell-before.json']
assert old_shell['proposed_indexed_native_gnat1_argc_upper'] == 24
flag = '-fsplit-wide-types'
assert len(flag) == 18
ali = 'A '+flag+'\n'
assert len(ali) == 21
argc = old['initial_argv_positions']+1
frontend = old['frontend_argv_positions']+1
switches = old['retained_switches']+1
capacity = 10
while capacity < frontend+1:
    capacity = capacity*2 if capacity < 16 else capacity*3//2
assert capacity == 30 and switches+1 <=16
indexed = old_shell['proposed_indexed_native_gnat1_argc_upper']+1
assert indexed == 25
# Growth from empty for <=25 explicit optimization options remains below48.
opt_capacity = 0
for demand in range(1,indexed+1):
    if opt_capacity < demand:
        opt_capacity = 4 if not opt_capacity else opt_capacity*2 if opt_capacity<16 else opt_capacity*3//2
        opt_capacity = max(opt_capacity,demand)
assert opt_capacity <=48
result = {
    'scope':'Stock -fsplit-wide-types native option source/container deltas',
    'source_files_verified':len(sources),
    'retained_GCC_corpus_file_count':len(corpus['files']),
    'exact_flag_mentions':len(mentions),
    'negative_inventory_requires_full_corpus_replay':True,
    'semantic_claim_requires_companion_source_argument':True,
    'option_characters':len(flag),
    'exact_standalone_driver':{
        'input_argv_positions':argc,'decoded_option_array_bytes':argc*96,
        'retained_switches':switches,'frontend_argv_positions':frontend,
        'argbuf_transient_positions':frontend+1,'argbuf_capacity':capacity,
        'argbuf_backing_bytes':8+capacity*8,
        'multilib_retained_match_array_bytes':(1+switches)*24,
        'COLLECT_GCC_OPTIONS_added_bytes':len(flag)+3,
        'assembler_argv_positions':5,'successful_execution_counter_increments':2,
        'explicit_optimization_vector_one_element_backing_bytes':8+4*96,
    },
    'indexed_frontend_envelope':{
        'argv_positions_upper':indexed,
        'original_argv_pointer_bytes':(indexed+1)*8,
        'decoded_option_array_bytes_each':indexed*96,
        'reconstructed_GNAT_C_argv_bytes':(2*indexed+1)*8,
        'Ada_argument_pointer_entries_upper':2*indexed-1,
        'Ada_argument_pointer_bytes_upper':(2*indexed-1)*16,
        'optimization_vector_backing_bytes_upper':8+48*96,
        'maximum_argument_formula_unchanged':'max(24,P+8)',
    },
    'ALI_delta':{'new_A_records':1,'added_raw_bytes':len(ali),
        'new_option_String_payload_bytes':len(flag),
        'unindexed_combined_A_records':9,'unindexed_combined_A_bytes':129,
        'indexed_combined_A_records':10,'null_complete_ALI_bound':378+len(ali),
        'null_ALI_reader_bytes_with_EOF':379+len(ali),
        'null_gprbind_argument_String_payload_sum':92+len(flag),
        'Compilation_Switches_initial_slots':30,'GPR_Args_initial_slots':1000},
    'same_selected_frontend_GIMPLE_and_pass_expand_shape':True,
    'old_execution_reclassified_as_split_option_execution':False,
    'binder_source_read_projection_preserved':True,
    'option_forwarded_to_binder_compiler':True,
    'binder_object_under_added_option_reconciled':False,
    'new_assembly_option_header_selected':False,
    'native_tool_executions':0,'producer_options_changed':False,
    'production_options_changed':False,'complete_capacity_established':False,
}
args.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'sources':len(sources),'corpus_replayed':bool(args.gcc_root),
                  'flag_mentions':len(mentions),'output':str(args.output)}))
