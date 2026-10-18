"""Reconcile the symbolic selected-script virtual placement transfer."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent
repo = root.parents[2]
manifest = json.loads((root / 'sources.json').read_text())
sha = lambda b: hashlib.sha256(b).hexdigest()
assert sha((root / 'sources.tar.gz').read_bytes()) == manifest['archive_sha256']
sources = {}
with tarfile.open(root / 'sources.tar.gz') as archive:
    for row in manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        sources[row['path']] = raw.decode()
inputs = json.loads((root / 'inputs.json').read_text())
for row in inputs:
    raw = (repo / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
script = (repo / inputs[1]['path']).read_text()
script = re.sub(r'/\*.*?\*/', '', script, flags=re.S)
# Literal LF splitting preserves the line-number convention.
ordinary = [l.strip() for l in script.split('\n') if re.search(r'\.\s*=\s*ALIGN\(', l)]
large = [l.strip() for l in script.split('\n')
         if re.search(r'^\s*\.l(?:rodata|data)\s+ALIGN\(', l)]
assert len(ordinary) == 5 and len(large) == 2
assert 'SEGMENT_START("text-segment", 0) + SIZEOF_HEADERS' in script
assert 'SEGMENT_START("ldata-segment", .)' in script
assert not re.search(r'\b(?:AT|SUBALIGN|BLOCK|MEMORY|OVERLAY|PHDRS)\b', script)
assert script.count('DATA_SEGMENT_ALIGN (') == 1
assert script.count('DATA_SEGMENT_RELRO_END (') == 1
assert script.count('DATA_SEGMENT_END (') == 1
anchors = {
    'ld/ldlang.c': [
        'if (!link_info.non_contiguous_regions)\n\treturn true;',
        'new_region->origin = 0;',
        'alignment_needed = align_power (dot, i->alignment_power) - dot;',
        'newdot = align_power (newdot, section_alignment);',
        'dot += TO_ADDR (i->size);',
        'os->block_value = 1;',
        's->padding_statement.size = 0;',
        'relro_end = (seg->relro_end + seg->relropagesize - 1) & -seg->relropagesize;',
        'desired_end = relro_end - seg->relro_offset;',
        'start &= ~(((bfd_vma) 1 << sec->alignment_power) - 1);',
        'seg->base = desired_end;',
        'if (expld.dataseg.relro_end > data_relro_end)',
        'expld.dataseg.base = data_initial_base;',
        'lang_reset_memory_regions ();',
        'lma = os->bfd_section->vma + last->lma - last->vma;',
    ],
    'ld/ldexp.c': ['expld.result.value = align_n (expld.dot, maxpage);',
                   'expld.result.value += expld.dot & (maxpage - 1);',
                   'expld.result.value = seg->relro_end - expld.result.value;'],
    'bfd/section.c': ['sec->vma = sec->lma = val;'],
}
for name, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[name], (name, snippet)
page = 4096
assert re.search(r'#define\s+ELF_MAXPAGESIZE\s+0x1000', sources['bfd/elf64-x86-64.c'])
# Page expressions depend only on the residue; inspect all 4096 residues.
for residue in range(page):
    rounded = (residue + page - 1) & -page
    assert 0 <= rounded - residue <= page - 1
    assert 0 <= rounded + residue - residue < 2 * page
result = {
    'scope': 'Conditional selected-script retained and trial virtual/load address placement',
    'source_files_verified': len(sources),
    'prior_input_identities_verified': len(inputs),
    'ordinary_script_alignments': ordinary,
    'large_data_script_expressions': large,
    'page_size': page,
    'charged_page_adjustment_bytes': 8 * page,
    'formula': 'V = (64 + 56*T) + B + (I + S + 5)*(A - 1) + 32768',
    'retained_endpoint_bound': 'V',
    'temporary_endpoint_bound': 'Vtrial = 2*V',
    'arithmetic_sufficient_condition': '2*V + A <= INT64_MAX',
    'incoming_B': 'Sum of per-input-section and script-item upper bounds valid over every layout pass, not maximum aggregate single-pass total; includes NOBITS/nonallocated; excludes charged ldlang padding',
    'incoming_A': 'Power-of-two byte alignment >=4096 bounding every effective input/output section alignment over every layout pass',
    'LMA_equals_VMA': True,
    'retained_RELRO_end_uses_checked_recomputation': True,
    'concrete_generated_payload_alignment_projection_complete': False,
    'final_file_size_or_relocation_reach_established': False,
    'mapping_iteration_convergence_established': False,
    'complete_retained_tool_capacity': False,
    'native_execution': False,
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ['source_files_verified',
    'charged_page_adjustment_bytes', 'complete_retained_tool_capacity', 'native_execution']}))
