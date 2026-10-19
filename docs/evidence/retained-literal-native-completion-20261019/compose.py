#!/usr/bin/env python3
"""Compose the selected literal-output native capacity research rule.

Fresh actual-source evaluation; no compiler, binder, assembler or linker runs.
The source arguments and established external interfaces remain premises.
This is not production SPARK/Lean correspondence or proof-pipeline closure.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import runpy
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO/'docs/evidence'
NATIVE = E/'unbounded-programs/retained-native-expansion-20261017'
PACKETS = dict(register='retained-literal-register-completion-20261019',
    parent='retained-literal-native-materialization-20261019',
    driver='retained-literal-driver-completion-20261019',
    binder='retained-literal-binder-completion-20261019',
    assembler='retained-literal-binder-assembler-20261019',
    ada='retained-literal-ada-residual-completion-20261019')
STAGES = ('input_materialization_and_parent', 'GCC_drivers_and_collect2',
    'gnat1_common_shells_startup_and_exit', 'Main_Ada_frontend',
    'Main_gigi_GIMPLE_CFG_SSA_shared_storage', 'Main_RTL_IRA_LRA_GGC',
    'Main_emission_GAS_BFD', 'Main_ALI_writer', 'GNATBIND',
    'binder_compiler', 'binder_assembler', 'fixed_bundle_and_ld_BFD')


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def require(condition, message):
    if not condition:
        raise ValueError(message)


def api(name, filename='compose.py'):
    return runpy.run_path(str(E/PACKETS[name]/filename))


class Context:
    def __init__(self, gcc_root, ada_root, plugin_include, gas_root,
                 gcc_match=None, cxx_include=None):
        self.manifest = read(HERE/'inputs.json')
        for row in self.manifest['repository']:
            require(identity((REPO/row['path']).read_bytes()) ==
                    {k:row[k] for k in ('bytes','sha256')}, 'changed aggregate input: '+row['path'])
        plugin = Path(plugin_include)
        roots = dict(gcc=Path(gcc_root), ada=Path(ada_root), plugin=plugin,
            cxx=Path(cxx_include) if cxx_include else plugin.parents[5]/'include/c++/16.1.0')
        checked = set()
        for name in ('process-shell-inputs','startup-registry-inputs','static-lifecycle-inputs'):
            manifest = read(NATIVE/(name+'.json'))
            for row in manifest['files']:
                path = roots[row['root']]/row['path']
                require(identity(path.read_bytes()) == {k:row[k] for k in ('bytes','sha256')},
                        'changed compiler shell source: '+str(path))
                checked.add(str(path))
            for row in manifest['prior_results']:
                require(identity((NATIVE/row['path']).read_bytes()) ==
                        {k:row[k] for k in ('bytes','sha256')}, 'changed retained shell input: '+row['path'])
        require(identity((plugin/'options.h').read_bytes()) ==
                read(NATIVE/'process-shell-inputs.json')['options_header'], 'generated options header')
        self.shell_inputs = dict(lifecycle=read(NATIVE/'native-static-lifecycle.json'),
            registry=read(NATIVE/'native-startup-registry.json'),
            split=read(E/'retained-split-options-20261018/result.json'))
        self.shell_sources_checked = len(checked)
        self.register = api('register')
        self.register_context = self.register['Context'](gcc_root,ada_root,plugin_include,gcc_match)
        self.register_schema = read(E/PACKETS['register']/'result.json')['conditions'].keys()
        require(len(self.register_schema) == 408, 'complete corrected register408 schema')
        self.parent, self.driver, self.binder = api('parent'), api('driver'), api('binder')
        self.parent_context, self.driver_context = self.parent['Context'](), self.driver['Context']()
        self.binder_context = self.binder['Context'](ada_root=ada_root,gcc_root=gcc_root)
        self.assembler = api('assembler','derive.py')
        self.assembler_context = self.assembler['Context'](gcc_root,gas_root)
        self.ada = api('ada','completion.py')
        self.ada_context = self.ada['Context'](ada_root,REPO)
        self.shells = runpy.run_path(str(HERE/'shells.py'))


def attach(register, raw, context):
    """Internal join over a freshly derived record, also exposed for fault tests.

    Public evaluate never accepts a supplied predecessor. Mutation probes must
    not be represented as actual-source capacity runs.
    """
    require(register['source'] == identity(raw), 'same raw source across native stages')
    for field in ('conditions','conditional_conditions'):
        require(register[field].keys() == context.register_schema,
                'all corrected408 guard names must survive')
        require(all(v is None or type(v) is bool for v in register[field].values()),
                'typed guard values')
    reasons = [field+'.'+key+('=uncomputed' if value is None else '=false')
        for field in ('conditions','conditional_conditions')
        for key,value in register[field].items() if value is not True]
    for name in ('evaluated_predicates_pass','conditional_arithmetic_pass',
                 'selected_register_interfaces_capacity_established',
                 'selected_GGC_event_partition_closed',
                 'selected_collector_indexed_storage_capacity_established'):
        require(type(register[name]) is bool, 'typed register summary '+name)
        if not register[name]: reasons.append(name+'=false')
    parts = {}
    extra = {}
    coverage = {name:None for name in STAGES}
    if not reasons:
        prior = register['predecessor_result']
        core = prior['core_result']
        register_invocation = prior['selected_native_invocation']
        require(register_invocation['source_identity'] == identity(raw) and
                register_invocation['source_counts'] == register['source_counts'], 'same source-bound graph')
        require(register['complete_path_bound'] == 512 and register_invocation['path_bytes'] == 513 and
                register_invocation['host_page_bytes'] == 4096, 'character versus NUL-inclusive path bounds')
        runtime = dict(cwd=register_invocation['graph']['project_root'],
            binder_temporary_root=register_invocation['processes'][0]['environment']['TMPDIR'])
        invocation = context.parent_context.api['build'](raw,context.parent_context.invocation,
            runtime=runtime,path_bytes=512,host_page_bytes=4096)
        require(invocation == dict(register_invocation,path_bytes=512),
                'stronger path check changes only envelope scalar, no execution/interface field')
        parts['parent'] = context.parent['evaluate'](raw,context.parent_context,invocation=invocation,runtime=runtime)
        parts['driver'] = context.driver['evaluate'](raw,context.driver_context,invocation=invocation,runtime=runtime)
        parts['binder'] = context.binder['evaluate'](raw,context.binder_context,invocation=invocation,runtime=runtime)
        parts['path_envelope_join'] = dict(register_path_characters=512,
            register_path_bytes_including_NUL=513,independently_checked_child_path_bytes_including_NUL=512,
            only_differing_graph_field='path_bytes',all_execution_and_derived_interfaces_equal=True)
        parts['Ada'] = context.ada['apply'](prior,register['conditions'],context.ada_context)
        require(parts['Ada']['source'] == identity(raw) and
                parts['Ada']['source_counts'] == register['source_counts'], 'same completed Ada source')
        parts['compiler_shells'] = context.shells['compiler_shells'](
            invocation,parts['driver'],context.shell_inputs)
        parts['binder_compiler'] = context.shells['binder_compiler'](
            invocation,core['accepted_output_binder_checksum'])
        parts['binder_assembler'] = context.assembler_context.result
        gas = parts['binder_assembler']
        require(gas['checksum_domain'] == invocation['binder_object_family']['checksum_domain'] and
                gas['checksum_data_bytes'] == 4 and gas['fixed_success_transfers_zero_and_nonzero_requests'],
                'all uint32 binder checksums use the reviewed two GAS classes')
        require(invocation['binder_object_family']['interface'] == dict(
            section_count=16,symbol_count=243,relocation_count=134,maximum_section_alignment=32,
            eh_frame_bytes=224,text_bytes=1278,allocated_bytes=12493,file_bytes_upper=17952),
            'same checksum object family delivered to ld')
        require(parts['parent']['invocation_identity'] == parts['driver']['invocation_identity'] ==
                identity(json.dumps(invocation,sort_keys=True,separators=(',',':')).encode()),
                'parent and driver attach the exact graph')
        for name in ('parent','driver','binder'):
            require(parts[name]['source_identity'] == identity(raw) and
                    parts[name]['source_counts'] == register['source_counts'], 'same source '+name)
        require(core['literal_output_linker']['source_identity'] == identity(raw), 'source-bound refined linker')
        for name in ('parent','binder','Ada','compiler_shells','binder_compiler','binder_assembler'):
            guards = parts[name]['checks' if name == 'Ada' else 'conditions']
            require(guards and all(type(v) is bool for v in guards.values()), 'typed nonempty '+name+' guards')
            extra.update({'complete_native_'+name+'_'+k:v for k,v in guards.items()})
        extra['complete_native_driver_source_closure'] = parts['driver'][
            'driver_and_collect2_shell_capacity_closed_under_documented_source_projection']
        coverage.update(input_materialization_and_parent=parts['parent']['selected_parent_design_capacity_fits'],
            GCC_drivers_and_collect2=extra['complete_native_driver_source_closure'],
            gnat1_common_shells_startup_and_exit=parts['compiler_shells']['capacity_established'],
            Main_Ada_frontend=parts['Ada']['complete_selected_Ada_frontend_capacity'],
            Main_gigi_GIMPLE_CFG_SSA_shared_storage=True,
            Main_RTL_IRA_LRA_GGC=register['selected_register_interfaces_capacity_established'],
            Main_emission_GAS_BFD=invocation['selected_main_emission_to_GAS_object_route_bound'] and
                core['literal_output_linker']['assembler_storage_fits'],
            Main_ALI_writer=parts['binder']['conditions']['accepted_native_ALI_local_interfaces'],
            GNATBIND=parts['binder']['binder_source_coverage_complete'] and parts['binder']['binder_capacity_established'],
            binder_compiler=parts['binder_compiler']['capacity_established'],
            binder_assembler=gas['conditional_binder_assembler_capacity'],
            fixed_bundle_and_ld_BFD=invocation['selected_fixed_link_input_materialization_computable'] and
                core['literal_output_linker']['selected_literal_assembler_and_linker_representation_fits'])
        require(not parts['parent']['parent_design_residuals'] and
                not parts['driver']['remaining_driver_capacity_obligations'], 'parent/driver source coverage closed')
    extra.update({'complete_native_stage_'+k:v for k,v in coverage.items()})
    require(not extra.keys() & context.register_schema, 'no predecessor guard overwritten')
    maps = {name:{**register[name],**extra} for name in ('conditions','conditional_conditions')}
    passed = not reasons and all(v is True for m in maps.values() for v in m.values())
    return dict(scope='Complete selected literal-output native-build capacity research rule',
        source=identity(raw),source_counts=register['source_counts'],source_path=register['source_path'],
        **maps,coverage=coverage,complete_native_capacity=passed,
        complete_parent_design_storage_closed=coverage['input_materialization_and_parent'] is True,
        native_residuals=[] if passed else reasons+[k for k,v in extra.items() if v is not True],
        components=parts,register_result=register,
        historical_scope='Nested component false completion flags and open_joins retain their original partial scope; the corrected408 guards and current coverage map govern this native-only result.',
        complete_proof_pipeline_capacity=False,whole_current_grammar_capacity=False,
        production_launcher_adopted=False,production_SPARK_Lean_correspondence_complete=False,
        production_admission_changed=False,Oracle_changed=False,aggregate_RAM_gate=False,
        no_required_native_unknown_counted_as_success=True,native_tool_executions=0,
        validation=dict(compiler_shell_sources_checked=context.shell_sources_checked,
            repository_inputs_checked=len(context.manifest['repository']),fresh_actual_source=True,
            native_observations_reused=True,predecessor_suites_rerun=False),
        remaining_parent_119=['GNATprove producer/required Why3 consumers and fixed library proofs',
            'current grammar generalization and whole-rule sound composition/correspondence',
            'comparison with justified conservative envelope and independent final review'],
        premises=['Relevant installed behavior matches reviewed source/configuration.',
            'Selected coherent fixed source/object/ALI bundle, exact argv/environments and stable filesystem.',
            'Linux x86-64 LP64 and established allocator/stack/libc/OS interfaces; physical exhaustion is separate.',
            'The reviewed source projections, coverage arguments and stated semantic assumptions apply.'])


def evaluate(descriptor, context, source=None):
    register = context.register['evaluate'](descriptor,context.register_context,source)
    raw = Path(register['source_path']).read_bytes()
    return attach(register,raw,context)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(E/'retained-literal-pipeline-20261018/compose.py'))['arguments'](p)
    p.add_argument('--gas-root',type=Path,required=True)
    p.add_argument('--cxx-include',type=Path)
    p.add_argument('--descriptor',type=Path,default=E/'retained-literal-pipeline-20261018/selected-route.json')
    p.add_argument('--source',type=Path)
    p.add_argument('--output',type=Path,required=True)
    a = p.parse_args()
    start,timer = datetime.now(timezone.utc).isoformat(),time.perf_counter()
    ctx = Context(a.gcc_root,a.ada_root,a.plugin_include,a.gas_root,a.gcc_match,a.cxx_include)
    result = evaluate(a.descriptor,ctx,a.source)
    result['offline_run'] = dict(start_UTC=start,end_UTC=datetime.now(timezone.utc).isoformat(),
        elapsed_seconds=time.perf_counter()-timer)
    a.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(complete_native_capacity=result['complete_native_capacity'],
        predicates=len(result['conditions']),residuals=result['native_residuals'])))


if __name__ == '__main__':
    main()
