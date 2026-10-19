"""Loaded by the already guarded probe; definitions only until first inline stop."""
import importlib.util as _session_import

_session_spec = _session_import.spec_from_file_location('silver_session_observer', ROOT / 'session_observer.py')
_session_module = _session_import.module_from_spec(_session_spec)
_session_spec.loader.exec_module(_session_module)
_session_capture = None
_session_reads = None
_session_metadata = {'code_checks': [], 'symbols': {}, 'complete': False, 'pid': INF.pid,
                     'limits': PLAN['session_observer']['limits']}


def capture_session_roots():
    global _session_capture, _session_reads
    try:
        _session_reads = (OUT / 'session-memory-reads.jsonl').open('w')

        def session_read(location, size):
            raw = data(location, size)  # Original durable all-read log first.
            _session_reads.write(json.dumps({'address': location, 'bytes': size,
                                            'hex': raw.hex()}, separators=(',', ':')) + '\n')
            _session_reads.flush()
            return raw

        symbols = PLAN['session_observer']['symbols']
        for name, spec in symbols.items():
            runtime = address(name)
            _session_metadata['symbols'][name] = runtime
            # Module/BSS symbols have no static value prediction.
            if 'code_hex' in spec:
                expected = bytes.fromhex(spec['code_hex'])
                raw = session_read(runtime, len(expected))
                _session_metadata['code_checks'].append({'symbol': name, 'address': runtime,
                                                        'bytes': len(raw), 'hex': raw.hex()})
                (OUT / 'session-observer.json').write_text(json.dumps(_session_metadata, indent=2) + '\n')
                assert raw == expected, ('session root code mismatch', name)
        bias = address('camlWhy3__Ident') - PLAN['session_observer']['ident_elf_value']
        assert all(_session_metadata['symbols'][name] == bias + spec['elf_value']
                   for name, spec in symbols.items()), 'session symbol/load-bias mismatch'
        _session_metadata['load_bias'] = bias
        _session_capture = _session_module.SessionCapture(
            session_read, lambda name: _session_metadata['symbols'][name], OUT,
            PLAN['session_observer']['limits'])
        roots = _session_capture.capture_roots()
        SUMMARY['session_roots'] = {'complete': roots['complete'],
                                    'identity': identity(OUT / 'session-root.json')}
    except Exception as error:
        _session_metadata['failure'] = repr(error)
        SUMMARY['session_roots'] = {'complete': False, 'failure': repr(error)}
    finally:
        (OUT / 'session-observer.json').write_text(json.dumps(_session_metadata, indent=2) + '\n')
        save()


def capture_session_projection():
    try:
        _session_metadata['core_join'] = {
            name: identity(OUT / name) for name in ['process.json', 'identifier-state.json',
                                                   'inline-entry-graph.json', 'hsdecl-table.json']}
        _session_metadata['driver_input_task'] = SUMMARY['driver_preparation'][0]['input_task']
        _session_metadata['inline_entry_task'] = SUMMARY['inline_entry']['task']
        assert _session_capture is not None, 'session root setup failed'
        session = _session_capture.capture_session()
        SUMMARY['session_projection'] = {
            'complete': session['complete'], 'identity': identity(OUT / 'session-result.json')}
        if not session['complete']:
            SUMMARY['failures'].append('session projection incomplete: ' + repr(session['failures']))
        helpers = _session_capture.capture_helpers()
        SUMMARY['session_helpers'] = {
            'complete': helpers['complete'], 'complete_R': False,
            'identity': identity(OUT / 'exit-hook-roots.json')}
        _session_metadata['complete'] = session['complete']
        _session_metadata['helper_roots_complete'] = helpers['complete']
    except Exception as error:
        _session_metadata['failure'] = repr(error)
        SUMMARY['failures'].append('session observer: ' + repr(error))
    finally:
        if _session_capture is not None:
            _session_capture.close()
        if _session_reads is not None:
            _session_reads.close()
        (OUT / 'session-observer.json').write_text(json.dumps(_session_metadata, indent=2) + '\n')
        save()
