"""Identity census and lexical writer inventory; not a reachability proof."""
import hashlib
from pathlib import Path
import re

LOCATION = re.compile(r'\b(get_or_create_combined_loc|make_location|set_source_range|'
                      r'location_with_discriminator(?:_components)?|set_block|'
                      r'tree_set_block|TREE_SET_BLOCK|gimple_set_block|'
                      r'rebuild_location_adhoc_htab)\s*\(')
WARNING = re.compile(r'\b(gimple_set_location|gimple_seq_set_location|copy_warning|'
                     r'suppress_warning|put_warning_spec_at)\s*\(')
# These selected-route translation units include the general wrapper bodies.
# Unselected pass/frontend families are classified in the source argument.
WARNING_FILES = {
    'gcc/gimple.h', 'gcc/gimple.cc', 'gcc/gimplify.cc', 'gcc/gimple-low.cc',
    'gcc/tree-cfg.cc', 'gcc/tree-eh.cc', 'gcc/tree-ssa.cc', 'gcc/tree-into-ssa.cc',
    'gcc/tree-outof-ssa.cc', 'gcc/tree-ssa-live.cc', 'gcc/cfgexpand.cc',
    'gcc/gimple-iterator.cc', 'gcc/cgraphunit.cc', 'gcc/gimple-fold.cc',
    'gcc/gimple-expr.cc', 'gcc/gimple-isel.cc', 'gcc/config/i386/i386.cc',
    'gcc/tree-inline.cc', 'gcc/gcc-diagnostic-spec.cc', 'gcc/warning-control.cc',
    'gcc/ada/gcc-interface/trans.cc', 'gcc/ada/gcc-interface/utils.cc',
    'gcc/fold-const.cc',
}


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def scan(root):
    """Freeze the complete retained gcc/libcpp C/C++ source-name/content set."""
    root = Path(root)
    files = sorted(p for directory in ('gcc', 'libcpp')
                   for p in (root / directory).rglob('*')
                   if p.is_file() and p.suffix in ('.c', '.cc', '.h'))
    corpus = hashlib.sha256()
    locations, warnings, selected = {}, {}, []
    for path in files:
        name = path.relative_to(root).as_posix()
        raw = path.read_bytes()
        ident = identity(raw)
        corpus.update((name + '\0' + str(len(raw)) + '\0' + ident['sha256'] + '\n').encode())
        rows, wr = [], []
        for lineno, line in enumerate(raw.decode().split('\n'), 1):
            for match in LOCATION.finditer(line):
                rows.append(dict(line=lineno, callee=match[1], text=line.strip()))
            if name in WARNING_FILES:
                for match in WARNING.finditer(line):
                    wr.append(dict(line=lineno, callee=match[1], text=line.strip()))
        if rows:
            locations[name] = rows
        if wr:
            warnings[name] = wr
        if rows or name in WARNING_FILES:
            selected.append(dict(root='gcc', path=name, **ident))
    return dict(corpus_files=len(files), corpus_sha256=corpus.hexdigest(),
                scope='Complete retained gcc/libcpp .c/.cc/.h set; lexical matches include declarations and selftests.',
                location_writers=locations, selected_warning_writers=warnings), selected
