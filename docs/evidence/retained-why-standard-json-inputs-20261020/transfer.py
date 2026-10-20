"""Prospective JSON inputs, not joined service or whole-process bounds."""


def schema(r, g, a, s, k, w, la, lt, lw):
    """The imported response schema; absent optional containers overcount."""
    c = 4 + 6*r + s + 3*g + a
    return dict(C=c, V=c + 9*r + 3*s + 3*a + k + w + 1,
                F=4 + 14*r + 4*s + 2*g + 4*a + k,
                Ns=2*r + a + w, Ni=3*r + 2*s + a + 1,
                Nf=s + a + k, Nb=4*r,
                L=28 + 139*r + 29*s + 29*g + 22*a + la + lt + lw)


def single_line(c):
    # M is the conservative comma allowance V-1, not an equality.
    C, M, F = c['C'], c['V']-1, c['F']
    strings = F + c['Ns']
    syntax = 2*C + M + F
    b = syntax + 2*strings + 6*c['L'] + 20*c['Ni'] + 317*c['Nf'] + 5*c['Nb']
    e = syntax + 2*strings + 2*c['L'] + c['Ni'] + c['Nf'] + c['Nb']
    h = 2*C + F + M + c['Nf'] + c['Nb']
    z = 2*C + 3*F + M + c['Nf'] + c['Nb']
    return dict(B=b, E=e, strings=strings,
                Q_strings=256*c['L'] + 72*strings,
                non_string_format_invocations=h, non_string_accumulator_nodes=z,
                Q_non_string_format_and_scalar=128*h + 192*z + 16*syntax + 32*c['Ni'] + 464*c['Nf'],
                JSON_graph_block_bytes=40*c['V'] + 24*F + 16*c['Nf'],
                serializer_sorts=0, opens=0, closes=0, breaks=0, flushes=0)


def normal(r, g, a, n, o, wo, lo, debug_entries=0, debug_bytes=0):
    """O bounds both answer-occurrence and parser-invocation weighted bytes."""
    assert min(r, g, a, n, o, wo, lo, debug_entries, debug_bytes) >= 0
    w = o + n + wo + debug_entries
    la = 4*o + 64*a
    lw = 514*o + 512*n + lo + debug_bytes
    return single_line(schema(r, g, a, 5*r, 26, w, la, 1051, lw))


def abort(x):
    assert x >= 0
    return dict(B=42 + 6*x, E=53 + 2*x, Q_strings=608 + 256*x,
                containers=2, fields=3, strings=4, fixed_key_bytes=20,
                commas=2, opens=5, closes=5, breaks=5, flushes=0,
                record_sorts=1, sorted_fields=3,
                non_string_format_invocations=8,
                non_string_main_accumulator_nodes=33,
                annotation_nodes=5,
                Q_non_string_format=128*8 + 192*38 + 16*9,
                private_annotation_streams=5,
                private_annotation_B_each=6, private_annotation_E_each=2,
                JSON_graph_block_bytes=40*4 + 24*3)


def joined_json(r, g, a, n, o, wo, lo, error_bytes_sum,
                debug_entries=1, debug_bytes=26619):
    """Conditional normal<=1/abort<=2 interface, all attempted prefixes."""
    q = normal(r, g, a, n, o, wo, lo, debug_entries, debug_bytes)
    return dict(B=q['B'] + 84 + 6*error_bytes_sum,
                E=q['E'] + 106 + 2*error_bytes_sum,
                Q_strings=q['Q_strings'] + 1216 + 256*error_bytes_sum)
