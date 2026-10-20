#!/usr/bin/env python3
"""Recheck input identities, finite inventories, and unknown preservation."""
import json
from pathlib import Path
import time
import extract

HERE = Path(__file__).resolve().parent


def main():
    start = time.perf_counter()
    outputs = extract.build()
    for name, data in outputs.items():
        assert (HERE / name).read_bytes() == (json.dumps(data, indent=2) + '\n').encode(), name
    # Regression checks for the source constructs present in the selected files
    # and for the distinction between an unknown list and a known empty list.
    masked, comments, strings = extract.mask_comments_strings('(*) (* (*) (* nested *) hidden *) "not_a_name" live')
    assert masked.startswith('(*) ') and masked.endswith(' live')
    assert len(comments) == 1 and len(strings) == 1
    assert 'hidden' not in masked and 'not_a_name' not in masked
    assert extract.encode_operator('(-_)') == 'prefix -'
    assert extract.encode_operator('( *.)') == 'infix *.'
    blocks = extract.Blocks(b'')
    assert blocks.path(1)['joined_dot_bytes'] == 0
    assert extract.known(lambda: blocks.path(16)) == (None, 16)
    library = outputs['library-inventory.json']
    assert library['total_source_bytes'] == 38678
    assert (library['module_count'], library['dependency_declaration_count']) == (69, 102)
    assert library['source_dependency_graph_acyclic']
    assert all(v == 0 for v in library['typed_source_excluded_keyword_counts'].values())
    assert library['semantic_new_third_component_bytes_max'] is None
    capture = outputs['capture-inventory.json']
    assert [r['current_entry_count'] for r in capture['cases']] == [6941, 6941, 6901, 6783, 6819]
    assert [r['serialized_tags_without_current_cached_hash_match'] for r in capture['cases']] == [64, 53, 32, 3, 4]
    for row in capture['cases']:
        assert row['cached_hash_max_multiplicity'] == 1
        assert row['serialized_tags_with_one_current_cached_hash_match'] == 2
        assert row['current_third_component_joined_bytes_max'] is None
        assert row['old_bucket_array_roots'] is None
        assert row['active_resize_frame_roots'] is None
        assert row['whole_interval_identifier_bytes_upper'] is None
        assert not row['complete_initial_selectable_payload_set_established']
    elapsed = time.perf_counter() - start
    record = {'passed': True, 'elapsed_seconds': elapsed,
        'checks': ['actual selected archive and member identities',
                   'current table fields and chains compared directly with retained raw blocks',
                   'cached hash uniqueness and every current serialized-tag candidate',
                   'complete-file candidate census and dependency topological certificate',
                   'lexical exclusions, nested comments and multiplication operator handling',
                   'unknown current-global, old-array, active-frame and continuation bounds stay null',
                   'retained output bytes reproduce exactly'],
        'checker_identity': extract.identity(Path(__file__).read_bytes()),
        'extractor_identity': extract.identity((HERE / 'extract.py').read_bytes()),
        'native_runs': 0, 'observer_replays': 0, 'new_captures': 0,
        'solver_requests': 0, 'source_fetches': 0}
    (HERE / 'verification.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(record, indent=2))


if __name__ == '__main__':
    main()
