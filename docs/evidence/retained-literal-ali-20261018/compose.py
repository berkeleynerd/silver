#!/usr/bin/env python3
"""Offline source-to-Main-ALI interface; no compiler or binder execution."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import runpy
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
NATIVE = REPO/'docs/evidence/unbounded-programs/retained-native-expansion-20261017'
I32 = 2**31-1


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def require(condition, message):
    if not condition:
        raise ValueError(message)


class Context:
    def __init__(self, ada_root):
        pins = json.loads((HERE/'inputs.json').read_bytes())
        for row in pins:
            require(identity((REPO/row['path']).read_bytes()) ==
                    {k:row[k] for k in ('bytes','sha256')}, 'changed input: '+row['path'])
        self.pins = len(pins)
        helper = runpy.run_path(str(NATIVE/'compose-null-capacity.py'))
        self.model = helper['load_model'](Path(ada_root))
        self.physical = helper['physical_source_shape']
        self.literal = runpy.run_path(str(NATIVE/'derive-literal-output.py'))
        capture=json.loads((REPO/'docs/evidence/retained-native-fixed-capture-20261018/inputs.json').read_bytes())
        by_hash={row['sha256']:Path(path) for path,row in capture.items()}
        ali_inputs=json.loads((NATIVE/'native-ali-inputs.json').read_bytes())['inputs']
        for name,expected in ali_inputs.items():
            path=(Path(ada_root)/name.removeprefix('gcc/ada/')) if name.startswith('gcc/ada/') else by_hash[expected['sha256']]
            require(identity(path.read_bytes())==expected,'changed serializer/source premise: '+name)
        self.serializer_sources=len(ali_inputs)
        with tarfile.open(REPO/'docs/evidence/retained-linker-output-delta-20261018/artifacts.tar.gz') as archive:
            raw = archive.extractfile('options/literal-proposed/obj/main.ali').read()
        baseline = [m[1].decode() for m in re.finditer(rb'^A (.*)$',raw,re.M)]
        require(baseline == ['-Wno-free-nonheap-object','-gnatA','-gnat2022',
                            '-gnata','-gnato','-gnatx','-mtune=generic','-march=x86-64'],
                'retained native output switch projection')
        self.switches = baseline+['-gnateI1','-fsplit-wide-types']
        self.command = dict(ALI_A_record_max_characters=max(map(len,self.switches))+4,
                            ALI_A_total_bytes_including_LF=sum(len(s)+3 for s in self.switches))
        require(len(self.switches)==10 and sum(map(len,self.switches))==110,
                'indexed split-option ALI switch join')


def evaluate(raw, context, path_bytes=512):
    require(type(path_bytes) is int and path_bytes>=0, 'nonnegative path-byte bound')
    require(all(32<=b<=126 or b in (9,10,13) for b in raw), 'current ASCII alphabet')
    counts = context.literal['source_counts'](raw)
    physical = context.physical(raw)
    # Only the source-independent ALI frontier is used. Scenario/marker and
    # native-lifetime fields from this existing helper are deliberately omitted.
    generic = context.model['native_invocation_metadata'](0,0,0,0,0)
    invocation = {k:generic[k] for k in ('ALI_Invocation_Constructs',
        'ALI_Invocation_Relations','ALI_Invocation_Signatures',
        'max_serialized_signature_characters')}
    logical = dict(fixed=dict(pathname_length_input=path_bytes),
                   tables=dict(Xrefs_entries=0), invocation=invocation)
    writer = context.model['native_ali_backing'](logical,13,
                command_line=context.command, include_xrefs=False)
    reader = writer['serialized_file_byte_bound']+1
    conditions = dict(writer=writer['all_selected_checks_pass'],
        Main_ALI_reader_Integer_and_EOF=reader<=I32,
        source_byte_and_coordinate_representations=len(raw)+1<=I32 and
            physical['physical_line_entries_bound']<=I32 and
            physical['max_expanded_final_column']<=32766)
    return dict(source=identity(raw),source_counts=counts,path_spelling_bytes_upper=path_bytes,
        physical_source=physical,stored_native_switches=context.switches,
        ALI_A_records=len(context.switches),ALI_A_payload_characters=sum(map(len,context.switches)),
        Main_invocation_interface=invocation,Main_ALI_writer=writer,
        Main_ALI_reader_bytes_including_EOF_upper=reader,
        conditions=conditions,selected_Main_ALI_interface_fits=all(conditions.values()),
        fixed_inputs_checked=context.pins,serializer_source_inputs_checked=context.serializer_sources,
        native_tool_executions=0,
        whole_binder_or_parent_capacity_established=False,
        whole_literal_pipeline_capacity_established=False,
        remaining=['Complete output launch/options/search materialization.',
            'Join Main ALI and fixed ALIs to binder parser/graph/driver lifetimes.',
            'Join native GPR and other ALI readers with their actual selected row policies.'],
        premises=['Relevant installed behavior matches the reviewed source.',
            'Selected indexed native no-Xref/split-wide configuration and fixed output dependencies.',
            'Other source/frontend representations and physical resources are established separately.'])


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ada-root',type=Path,required=True)
    parser.add_argument('--source',type=Path,default=REPO/'samples/hello_world.adb')
    parser.add_argument('--path-bytes',type=int,default=512)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    result=evaluate(args.source.read_bytes(),Context(args.ada_root),args.path_bytes)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ('selected_Main_ALI_interface_fits',
        'Main_ALI_reader_bytes_including_EOF_upper','whole_literal_pipeline_capacity_established')}))
