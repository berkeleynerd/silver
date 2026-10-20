#!/usr/bin/env python3
"""New finite input-role join; no predecessor checker or target invocation."""
import hashlib
import json
import tarfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CASES = ['put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid']


def audit():
    result = {}
    for case in CASES:
        captures = []
        paths = ['docs/evidence/retained-why-save-state-capture-20261020/capture-' +
                 case.replace('_', '-') + '.tar.gz',
                 'docs/evidence/retained-why-parallel-residual-transfer-20261020/' +
                 case.replace('_', '-') + '-capture.tar.gz']
        for path in paths:
            with tarfile.open(ROOT / path) as arc:
                prefix, = [n[:-len('process.json')] for n in arc.getnames()
                           if n.endswith('/capture/process.json')]
                members = {n: arc.extractfile(prefix + n).read()
                           for n in ['process.json', 'summary.json']}
            process, summary = [json.loads(members[n]) for n in members]
            assert summary['completed'] and summary['protected']
            assert not summary['guard_hits'] and not summary['new_threads']
            assert not summary['failures']
            assert process['initial_threads'] == 1
            argv = process['argv']
            private = str(Path(argv[argv.index('--why3-conf') + 1]).parent.parent)

            def role(path):
                # Whole-prefix substitution, preserving each full suffix.
                if path.startswith(private + '/'):
                    return '$PRIVATE/' + path[len(private) + 1:]
                return path

            normalized_argv = [role(a) for a in argv]
            if '-j' in normalized_argv:
                at = normalized_argv.index('-j')
                assert normalized_argv[at + 1] == '12'
                normalized_argv[at:at + 2] = []
            env = {k: role(v) for k, v in process['environment'].items()}
            assert env == {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C',
                           'TMPDIR': '$PRIVATE/' + case + '/temp',
                           'OCAMLRUNPARAM': 's=256M,h=16M,M=1000'}
            opens = []
            for row in summary['file_opens']:
                assert row['fd'] >= 0 and row['flags'] == 0 and row['protected']
                opens.append({k: role(row[k]) for k in ['path', 'resolved_path']} |
                             {'identity': row['identity']})
            assert len(opens) == 81
            assert opens[-1]['path'] == argv[-1]
            assert [r['name'] for r in summary['dispatch']['transform']] == ['split_goal_wp_conj']
            baseline = summary['baseline']
            endpoint = summary['snapshots'][-1]
            assert baseline['caml_gc_phase'] == endpoint['caml_gc_phase'] == 0
            for key in ['stat_minor_words', 'stat_promoted_words', 'stat_major_words',
                        'stat_minor_collections', 'stat_major_collections', 'stat_compactions']:
                assert baseline['state'][key] == endpoint['state'][key]
            captures.append({'archive': path, 'pid': process['pid'],
                             'members_sha256': {prefix + n: hashlib.sha256(b).hexdigest()
                                                for n, b in members.items()},
                             'private_root': private, 'argv': argv,
                             'normalized_argv': normalized_argv,
                             'normalized_environment': env, 'ordered_opens': opens,
                             'mapped_files': summary['mapped_files'],
                             'retained_endpoint': endpoint['label'],
                             'minor_words_at_retained_endpoint': endpoint['minor_allocated_words']})
        old, new = captures
        for field in ['normalized_argv', 'normalized_environment', 'ordered_opens', 'mapped_files']:
            assert old[field] == new[field], (case, field)
        assert new['retained_endpoint'] == 'end_of_registration'
        assert old['retained_endpoint'] == ('inline_trivial_entry' if case == 'input_is_valid'
                                            else 'end_of_registration')
        result[case] = {'captures': captures,
                        'claim_cut': 'end_of_registration',
                        'old_table_at_claim_cut': case != 'input_is_valid',
                        'input_post_CE_table_equality_claimed': False}
    return result


if __name__ == '__main__':
    print(json.dumps(audit(), indent=2, sort_keys=True))
