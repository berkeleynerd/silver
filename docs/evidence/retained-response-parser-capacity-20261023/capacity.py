"""Mathematical representation transfer; never execute a compiler or inspect a response.

Provider bounds are source/configuration functions. A false guard is an
unproved sufficient condition, not a counterexample or an admission decision.
"""
I = 2**31 - 1
U = 2**32 - 1
LL = 2**63 - 1
SZ = 2**64 - 1


def power2(n):
    return 1 << (max(1, n) - 1).bit_length()


def round_x(n):
    return (n // 4096 + 1) * 4096 if n > 4096 else n + n % 2


def normal(R, G, A, N, W_o, L_o, *, other_warning_max, debug_bytes):
    """Current canonical per-call <=76 bytes; no A<=4G assumption."""
    S, K, L_T = 5 * R, 26, 1051
    O = 76 * max(A, N)
    W = O + N + W_o + 1
    L_A = 4 * O + 64 * A
    L_W = 514 * O + 512 * N + L_o + debug_bytes
    C = 4 + 6*R + S + 3*G + A
    V = C + 9*R + 3*S + 3*A + K + W + 1
    F = 4 + 14*R + 4*S + 2*G + 4*A + K
    B = (212 + 987*R + 549*S + 189*G + 489*A + 321*K + 3*W
         + 6*(L_A + L_T + L_W))
    # Each canonical invocation has at most 76 bytes and 77 answer segments;
    # max one warning <= 2*76 + 512*77. Other warnings <=422, debug <=26619.
    m = max(35, 4*76+64, 2*76+512*77, other_warning_max, debug_bytes)
    return dict(B=B, token=min(B,max(6*m+2, 317)), key=min(B,61), decoded=min(B,2*m),
                depth=7, array=max(R,G,W), object=max(8,K,5,A),
                containers=C, values=V, fields=F, warning_count=W,
                string_source_max=m)


def terminal(x):
    """One isolated complete boxed error record; 5 opens, 5 breaks."""
    # Include one initial system token, two possible reset tokens/flushes.
    return dict(B=42+6*x+69*13+2, token=max(6*x+2,10), key=10,
                decoded=max(2*x,8), depth=2, array=0, object=3,
                containers=2, values=4, fields=3, string_source_max=max(x,8))


def stdout_offer(text_bytes, abort_attempts):
    # Shared global two exit flushes, not two per abort. Normal report has
    # neither boxes nor breaks. Dirty system-begin tokens are paid for.
    return text_bytes + 69*(10*abort_attempts+3)+2


def merged_offer(text_bytes, abort_attempts, diagnostics, direct_stderr):
    """Both redirected cores: diagnostics each have one @. flush/reset.

    text_bytes already includes stdout JSON and 64 bytes per stderr diagnostic.
    The two exit flushes are shared globally. Direct writes add no Format event.
    """
    return (text_bytes + 69*(10*abort_attempts+diagnostics+4)
            + diagnostics+2 + direct_stderr)


def arbitrary_stream(b):
    """Any at-most-b byte file, including malformed/spliced report prefixes."""
    return dict(B=b, token=b, key=b, decoded=b, depth=b,
                array=b, object=b, containers=b, values=b, fields=b)


def guard(p, path_bytes, max_path, page_size):
    """No physical-memory sum. Each mathematical operand precedes its guard."""
    assert all(type(p[k]) is int and p[k]>=0 for k in
               ('B','token','key','decoded','depth','array','object'))
    assert path_bytes >= 0 and max_path >= 1 and page_size >= 1
    # Covers the path-normalization scratch before the Stat call; p_abs
    # dominates any returned path when Resolve_Links=False on selected Unix.
    p_abs = path_bytes + max_path + 1
    q = max(32, power2(p['depth']+1))
    kb = max(64, power2(p['key']+1))
    pb = max(64, power2(p_abs+1))
    d = p['decoded']
    # Only a growth call has Current < needed <=d. An already oversized
    # final backing is not multiplied again in the read-only return suffix.
    current = max(0, d-1)
    x_raw = max(3*current//2, d)
    xb = max(24, round_x(x_raw))
    vc = power2(max(1,p['array']))
    refs = 3*q + 32
    operands = dict(parser_state_backing=q, key_builder_backing=kb,
                    normalized_path_majorant=p_abs, path_builder_backing=pb,
                    xstring_growth_current=current, xstring_product=3*current,
                    xstring_round_input=x_raw, xstring_backing=xb,
                    vector_backing=vc, json_counter=refs,
                    xstring_counter=16,
                    per_object_bytes=max(256*(q+1),256*(vc+1),xb+8,
                                         kb+64,pb+64,p['B']+page_size,
                                         path_bytes+2*max_path+4))
    checks = dict(
        file_and_scanner_spare=p['B']+256<=I,
        token_endpoint=p['token']<=p['B'] and p['token']+256<=I,
        parser_stack=q<=I,
        key_builder=kb<=I,
        path_scratch=path_bytes+2*max_path+4<=I and max_path+2<=I,
        path_builder=pb<=I and path_bytes+64<=I,
        xstring_product=3*current<=U,
        xstring_round=xb<=I and xb//2<=2**31-1,
        numeric_scale=p['token']+I//10+2<=I,
        vector_length=p['array']<=2**30-1 and vc<=2**30,
        map_length=p['object']<=I-1,
        json_references=refs<U,
        xstring_references=16<U,
        mapping_round=page_size<=I and p['B']+page_size-1<=LL,
        object_request=operands['per_object_bytes']<SZ)
    return dict(operands=operands, guards=checks, all_guards=all(checks.values()))


def precut(P,U_label):
    S=max(467,U_label+256,4*P+2048)
    C=8*(723+12*S)+65536
    R4=31*C
    X=4*(R4+P+1024)
    # Provider's B_std also includes stderr text; safe for stdout.
    return dict(P=P,S=S,C=C,R4=R4,X=X,text=6*X+576,
                stdout_component=stdout_offer(6*X+576,4),
                direct_stderr=2*R4+253,
                merged_file=merged_offer(6*X+576,4,1,2*R4+253))
