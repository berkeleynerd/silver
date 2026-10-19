#!/usr/bin/env python3
"""Bound the proposed parent for the exact selected native literal graph.

Research arithmetic/state model only: no filesystem materialization, fork,
compiler, binder or linker execution. The production SPARK implementation and
its Bronze/Silver verification plus Lean correspondence remain required.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
PREDECESSOR = REPO/'docs/evidence/retained-literal-invocation-join-20261018'
I32 = 2**31-1
I64 = 2**63-1
CHUNK = 4096
PATH_BYTES = 512
PATH_SLOTS = 32
ARG_BYTES = 2048
ENV_BYTES = 1024
ARG_SLOTS = 17
ENV_SLOTS = 7
PAYLOAD_BYTES = 18998
JOB_ROLES = ['Main_compile', 'binder_generate', 'binder_compile', 'link']


def require(condition, message):
    if not condition:
        raise ValueError(message)


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


class Context:
    def __init__(self):
        for row in json.loads((HERE/'inputs.json').read_bytes()):
            require(identity((REPO/row['path']).read_bytes()) ==
                    {key:row[key] for key in ('bytes', 'sha256')}, row['path'])
        self.api = runpy.run_path(str(PREDECESSOR/'compose.py'))
        self.invocation = self.api['Context']()


def c_vector(strings, slots, capacity):
    """Witness a bounded, zero-terminated arena and offset vector.

    Production append tests len <= capacity - used - 1 BEFORE addition;
    the Python witness follows that order, including the final NUL slot.
    """
    require(len(strings) <= slots, 'pointer-vector capacity')
    arena = bytearray()
    offsets = []
    for text in strings:
        require(type(text) is str and '\0' not in text, 'C string without embedded NUL')
        raw = text.encode('ascii')
        available = capacity-len(arena)
        require(available >= 1 and len(raw) <= available-1, 'C arena capacity')
        offsets.append(len(arena))
        arena.extend(raw)
        arena.append(0)
    require(len(offsets)+1 <= slots+1, 'terminating null pointer slot')
    return dict(count=len(strings), bytes_including_NUL=len(arena), offsets=offsets,
                maximum_string_bytes_including_NUL=max((len(x.encode('ascii'))+1 for x in strings), default=0),
                identity=identity(arena))


def copy_invariant(state, chunk=CHUNK):
    require(type(chunk) is int and 1 <= chunk <= CHUNK, 'positive bounded chunk')
    length, remaining, pending, cursor, loaded = (
        state[x] for x in ('length', 'remaining', 'pending', 'cursor', 'loaded'))
    require(all(type(x) is int for x in (length,remaining,pending,cursor,loaded)), 'integer copy fields')
    require(0 <= remaining <= length <= I64, 'nonnegative off_t length/remainder')
    require(0 <= cursor <= loaded <= chunk <= CHUNK, 'bounded chunk indexes')
    require(pending == loaded-cursor and pending <= remaining, 'pending/write prefix invariant')
    require(state['phase'] in ('read','write','probe','done','failed'), 'copy phase')
    if state['phase'] == 'read':
        require(remaining > 0 and pending == loaded == cursor == 0, 'read state')
    elif state['phase'] == 'write':
        require(pending > 0, 'write state')
    elif state['phase'] in ('probe','done'):
        require(remaining == pending == loaded == cursor == 0, 'finished extent')
    # Mathematical correspondence, not additional production counters:
    require(0 <= length-remaining <= length-remaining+pending <= length, 'read/write prefixes')
    return True


def start_copy(length, chunk=CHUNK):
    require(type(length) is int and 0 <= length <= I64, 'copy length fits signed off_t')
    state = dict(length=length, remaining=length, pending=0, cursor=0, loaded=0,
                 phase='read' if length else 'probe', failure=None)
    copy_invariant(state, chunk)
    return state


def copy_request(state, chunk=CHUNK):
    copy_invariant(state, chunk)
    if state['phase'] == 'read': return min(chunk, state['remaining'])
    if state['phase'] == 'write': return state['pending']
    if state['phase'] == 'probe': return 1
    return 0


def copy_step(state, event, value=None, chunk=CHUNK):
    """One read/write return, EINTR, or external error; bytes are ghost state.

    read/probe copy through the actual one buffer; write always passes exactly
    its pending suffix. Thus prefix equality is inductive for all returned bytes,
    independently of the values used in the focused byte replay.
    """
    copy_invariant(state, chunk)
    require(state['phase'] not in ('done','failed'), 'no I/O after terminal state')
    out = dict(state)
    if event == 'eintr': return out
    if event == 'error':
        out.update(phase='failed', failure='external_io_error')
    else:
        require(event == state['phase'], 'I/O operation matches current phase')
        require(type(value) is int and 0 <= value <= copy_request(state,chunk),
                'check signed syscall result before narrowing')
        if event == 'probe':
            out.update(phase='done' if value == 0 else 'failed',
                       failure=None if value == 0 else 'unexpected_extra_source_byte')
        elif value == 0:
            out.update(phase='failed', failure='premature_EOF' if event == 'read' else 'zero_write')
        elif event == 'read':
            out.update(pending=value, loaded=value, cursor=0, phase='write')
        else:
            out['remaining'] -= value
            out['pending'] -= value
            out['cursor'] += value
            if out['pending'] == 0:
                out.update(cursor=0, loaded=0, phase='read' if out['remaining'] else 'probe')
    copy_invariant(out, chunk)
    return out


def start_route():
    return dict(next_job=0, outstanding_pid=0, phase='ready', failure=None)


def route_invariant(state):
    require(type(state['next_job']) is int and 0 <= state['next_job'] <= 4, 'job index')
    require(type(state['outstanding_pid']) is int and 0 <= state['outstanding_pid'] <= I32, 'stored pid_t')
    require(state['phase'] in ('ready','waiting','done','failed'), 'parent phase')
    if state['phase'] == 'done':
        require(state['next_job'] == 4 and state['outstanding_pid'] == 0, 'complete parent state')
    else:
        require(state['next_job'] < 4, 'incomplete parent state')
    if state['phase'] == 'ready':
        require(state['outstanding_pid'] == 0, 'ready without outstanding child')
    elif state['phase'] == 'waiting':
        require(state['outstanding_pid'] > 0, 'waiting for one child')
    return True


def route_step(state, event, pid=None, status=None):
    """Parent branch only. Child branch performs chdir/execve/_exit.

    No diagnostic capture, process queue, job retry or lifetime counter.
    """
    route_invariant(state)
    require(state['phase'] in ('ready','waiting'), 'nonterminal parent route')
    out = dict(state)
    if event == 'error':
        # A wait error may leave the one child outstanding. Failure is terminal;
        # no subsequent job launches and success is never reported.
        out.update(phase='failed', failure='external_process_error')
    elif state['phase'] == 'ready':
        require(state['next_job'] < 4 and state['outstanding_pid'] == 0, 'one outstanding child')
        require(event == 'fork' and type(pid) is int and 1 <= pid <= I32,
                'parent fork result is positive pid_t')
        out.update(outstanding_pid=pid, phase='waiting')
    else:
        require(1 <= state['outstanding_pid'] <= I32, 'stored child pid_t')
        if event == 'eintr': return out
        require(event == 'wait' and type(pid) is int and pid == state['outstanding_pid'], 'waitpid exact child')
        require(type(status) is int and 0 <= status <= I32, 'nonnegative Linux wait status')
        out['outstanding_pid'] = 0
        if status != 0:
            out.update(phase='failed', failure='child_nonzero_or_signal')
        else:
            out['next_job'] += 1
            out['phase'] = 'done' if out['next_job'] == 4 else 'ready'
    route_invariant(out)
    return out


def evaluate(raw, context, invocation=None, runtime=None, path_bytes=512, host_page_bytes=4096):
    require(type(raw) is bytes, 'actual source byte string')
    require(path_bytes == PATH_BYTES, 'selected complete path capacity is 512 including NUL')
    expected = context.api['build'](raw, context.invocation, runtime=runtime,
                                  path_bytes=path_bytes, host_page_bytes=host_page_bytes)
    if invocation is not None:
        require(invocation == expected, 'exact actual-source accepted invocation join')
    result = expected
    files, jobs, graph = result['materialization'], result['processes'], result['graph']
    require(len(files) == 12 and [x['role'] for x in jobs] == JOB_ROLES, 'closed selected graph')
    require(not result['regenerate_fixed_children_selected'] and result['GPR_or_Gprbind_jobs'] == 0,
            'no fallback or hidden GPR parent')
    root = graph['project_root']
    temp = jobs[0]['environment']['TMPDIR']
    require(not root.startswith(temp+'/') and not temp.startswith(root+'/') and root != temp,
            'separate fresh owned roots')
    by_role = {row['role']:row for row in files}
    directories = [root,temp,root+'/obj',root+'/bin',
                   str(Path(by_role['naming']['path']).parent),
                   str(Path(by_role['binder_mapping']['path']).parent)]
    require(len(set(directories)) == 6, 'six directory roles')
    require(len(set(row['path'] for row in files)) == 12, 'distinct initial files')
    outputs = [path for job in jobs for path in job['outputs']]
    require(len(outputs) == len(set(outputs)) == 8, 'eight generated outputs')
    require(not set(outputs) & {row['path'] for row in files}, 'no initial generated artifact substitutions')
    parent_paths = list(dict.fromkeys([*directories,*(row['path'] for row in files),
                                     *outputs,*(job['argv'][0] for job in jobs)]))
    require(len(parent_paths) <= PATH_SLOTS and
            all(len(path.encode('ascii'))+1 <= PATH_BYTES for path in parent_paths), 'bounded parent paths')
    payload_offset = 0
    initial = []
    for row in files:
        if row['kind'] == 'supplied_source':
            require(row['role'] == 'Main', 'only Main is variable streamed input')
            content, offset = raw, None
        elif row['kind'] == 'generated_text':
            content, offset = row['text'].encode('ascii'), payload_offset
        else:
            content, offset = context.invocation.artifacts[row['member']], payload_offset
        require(identity(content) == row['identity'], 'exact input bytes '+row['role'])
        require(len(content) <= I64, 'each input extent fits signed off_t')
        if offset is not None:
            require(len(content) <= PAYLOAD_BYTES-payload_offset, 'bounded fixed payload arena')
            payload_offset += len(content)
        stamp = None
        if row['kind'] == 'fixed_source_copy':
            require(row['timestamp'] == '20261018061955', 'coherent fixed-source mtime')
            stamp = int(datetime.strptime(row['timestamp'],'%Y%m%d%H%M%S').replace(tzinfo=timezone.utc).timestamp())
            require(0 <= stamp <= I64, 'time_t seconds')
        initial.append(dict(role=row['role'],path_index=parent_paths.index(row['path']),
                            identity=row['identity'],payload_offset=offset,mtime_seconds=stamp))
    require(payload_offset == PAYLOAD_BYTES, 'eleven fixed-width payloads total 18998 bytes')
    vectors = []
    for job in jobs:
        argv = c_vector(job['argv'], ARG_SLOTS, ARG_BYTES)
        environment = c_vector([key+'='+value for key,value in job['environment'].items()],ENV_SLOTS,ENV_BYTES)
        vectors.append(dict(role=job['role'],cwd_index=parent_paths.index(job['cwd']),
                            argv=argv,environment=environment,outputs=job['outputs']))
    # Fixed, disjoint representation fields; not a measured process/RSS limit.
    storage = dict(path_bytes=PATH_SLOTS*PATH_BYTES,initial_payload_bytes=PAYLOAD_BYTES,
                   job_argv_env_bytes=4*(ARG_BYTES+ENV_BYTES),copy_buffer_bytes=CHUNK,
                   argv_env_pointer_bytes=(ARG_SLOTS+1+ENV_SLOTS+1)*8,
                   path_and_vector_U16_offset_bytes=(PATH_SLOTS+4*(ARG_SLOTS+ENV_SLOTS))*2,
                   initial_file_descriptors=12*32,job_descriptors=4*16,
                   directory_path_indexes=6,copy_and_route_scalar_record=128,
                   OS_stat_and_two_timespec_records=256+32)
    max_argv = max(row['argv']['bytes_including_NUL'] for row in vectors)
    max_env = max(row['environment']['bytes_including_NUL'] for row in vectors)
    conditions = dict(actual_source_and_selected_graph_bound=True,
                      all_file_extents_fit_signed_off_t=all(row['identity']['bytes'] <= I64 for row in initial),
                      fixed_payload_and_path_arenas_fit=True,
                      exact_parent_vectors_fit=True,
                      direct_sequential_route_has_four_jobs=True,
                      record_payload_and_internal_alignment_fit_64KiB=sum(storage.values())+2048 <= 65536,
                      chunk_request_fits_ssize_t_size_t=CHUNK <= I64,
                      exec_string_pointer_and_executable_bytes_below_4096=
                          ARG_BYTES+ENV_BYTES+(ARG_SLOTS+1+ENV_SLOTS+1)*8+PATH_BYTES <= 4096,
                      parent_path_components_fit_NAME_MAX_255=
                          all(len(part.encode('ascii')) <= 255 for path in parent_paths for part in Path(path).parts),
                      PID_and_file_descriptor_interfaces_use_signed_C_int=True,
                      fixed_timestamp_fits_signed_time_t=True)
    return dict(scope='selected native literal input materialization and four-job parent design',
                source_identity=identity(raw),source_counts=result['source_counts'],
                invocation_identity=identity(json.dumps(result,sort_keys=True,separators=(',',':')).encode()),
                selected_process_roles=JOB_ROLES,initial_files=initial,parent_paths=parent_paths,
                directories=directories,generated_outputs=outputs,vectors=vectors,
                limits=dict(path_bytes=PATH_BYTES,path_slots=PATH_SLOTS,initial_files=12,jobs=4,
                            directory_count=6,chunk_bytes=CHUNK,argv_slots=ARG_SLOTS,env_slots=ENV_SLOTS,
                            argv_bytes=ARG_BYTES,env_bytes=ENV_BYTES,maximum_file_bytes=I64,
                            maximum_positive_pid=I32,maximum_outstanding_parent_children=1,
                            parent_open_file_descriptors_in_addition_to_standard=2),
                observed_graph_extents=dict(fixed_input_bytes=payload_offset,parent_path_count=len(parent_paths),
                            maximum_argv_bytes_including_NUL=max_argv,maximum_env_bytes_including_NUL=max_env),
                representation_payload_bytes=storage,representation_payload_sum=sum(storage.values()),
                representation_internal_alignment_allowance=2048,
                conditions=conditions,selected_parent_design_capacity_fits=all(conditions.values()),
                parent_design_residuals=[],production_launcher_adopted=False,
                production_SPARK_GNATprove_Lean_correspondence_complete=False,
                whole_literal_pipeline_capacity_established=False,native_tool_executions=0,
                composition_obligations=[
                    'Use the same raw bytes and exact accepted invocation in every native component.',
                    'Conjoin all child capacity/semantic guards; this record does not discharge them.',
                    'Selected coherent filesystem, stable source/configuration and Linux ABI/services apply.',
                    'Implement every Silver-owned parent operation in SPARK and verify Bronze/Silver plus Lean correspondence in #89.'])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source',type=Path,default=REPO/'samples/hello_world.adb')
    parser.add_argument('--output',type=Path,required=True)
    args = parser.parse_args()
    args.output.write_text(json.dumps(evaluate(args.source.read_bytes(),Context()),indent=2)+'\n')
