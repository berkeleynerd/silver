"""New R53 raw-declaration/tag projection; does not replay a capture reader."""
import json
import re
import struct
import tarfile

CASES = ('put-line', 'put', 'first-or-default', 'is-message', 'input-is-valid')


def mask_census(root):
    """Lexical witness only; selected reachability uses the source owner argument."""
    result = {'ocaml_mask_call_sites': [], 'why_explicit_mask_clients': []}
    archive = root / 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
    with tarfile.open(archive) as stream:
        for member in stream:
            if not member.isfile() or not member.name.endswith(('.c', '.h')):
                continue
            if not any('/' + p + '/' in member.name for p in ('runtime', 'otherlibs/systhreads', 'otherlibs/unix')):
                continue
            for line, text in enumerate(stream.extractfile(member).read().decode().splitlines(), 1):
                if re.search(r'(sigmask_hook|sigprocmask|pthread_sigmask|sigsuspend)\s*\(', text):
                    result['ocaml_mask_call_sites'].append({'member': member.name, 'line': line, 'text': text.strip()})
    archive = root / 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
    with tarfile.open(archive) as stream:
        for member in stream:
            if not member.isfile() or not member.name.startswith('why3/src/') or not member.name.endswith('.ml'):
                continue
            for line, text in enumerate(stream.extractfile(member).read().decode().splitlines(), 1):
                if re.search(r'(?:Unix\.(?:sigprocmask|sigsuspend)|Thread\.sigmask)\b', text):
                    result['why_explicit_mask_clients'].append({'member': member.name, 'line': line, 'text': text.strip()})
    return result


def derive(root):
    result = {}
    for case in CASES:
        archive = root / 'docs/evidence/retained-why-parallel-residual-transfer-20261020' / (case + '-capture.tar.gz')
        prefix = case.replace('-', '_') + '/capture/'
        with tarfile.open(archive) as stream:
            meta = json.load(stream.extractfile(prefix + 'metadata.json'))
            chains = json.load(stream.extractfile(prefix + 'session-task-chains.json'))
            blocks = {row['address']: row for row in map(json.loads, stream.extractfile(prefix + 'session-blocks.jsonl'))}

        def fields(pointer):
            row = blocks[pointer]
            return struct.unpack('<' + 'Q' * row['words'], bytes.fromhex(row['payload_hex']))

        contexts = []
        goals = []
        records = {}
        for task, chain in chains.items():
            declarations = []
            for item in reversed(chain):
                td = meta['tdecls'][str(item['tdecl'])]
                if td['kind'] != 0:
                    continue
                dp = td['declaration']
                node, _, tag = fields(dp)
                assert tag & 1 and tag < 2**63
                kind = blocks[node]['tag']
                is_goal = kind == 5 and fields(fields(node)[0])[0] == 5
                records[dp] = {'declaration': dp, 'tag': tag >> 1, 'kind': kind, 'goal': is_goal}
                declarations.append(dp)
            assert records[declarations[-1]]['goal']
            assert not any(records[p]['goal'] for p in declarations[:-1])
            contexts.append(declarations[:-1])
            goals.append({'task': int(task), 'declaration': declarations[-1]})
        context = contexts[0]
        assert all(c == context for c in contexts)
        assert len(set(context)) == len(context)
        tags = [records[p]['tag'] for p in context]
        assert len(set(tags)) == len(tags)
        capacity = 16
        while capacity < 63:
            capacity *= 2
        assert capacity == 64
        threshold = 2 * capacity + 1
        assert len(context) >= threshold
        result[case] = {
            'raw_tasks': len(chains), 'non_goal_declarations': len(context),
            'distinct_context_d_tags': len(set(tags)),
            'context_rows': [records[p] for p in context], 'goals': goals,
            'first_wdecl_resize_insertion': threshold,
            'first_wdecl_resize_key': records[context[threshold - 1]],
            'claim_scope': 'First uninterrupted full CE walk from empty Wdecl memo, with valid tags, live raw keys and successful ordinary table operations. Earlier failures can prevent reaching this event.',
        }
    return result
