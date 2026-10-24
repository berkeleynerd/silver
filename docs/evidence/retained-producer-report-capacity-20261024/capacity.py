"""Source-shaped report algebra for #119/#193. Mathematical integers only.

This is not an admission test or an implementation of a native schema validator.
Its inputs are upper bounds with separately established source provenance.
No observation of an output report is a binding for an input.
"""
from dataclasses import asdict, dataclass

I = 2**31 - 1
U = 2**32 - 1
SIZE = 2**64 - 1
HASH = 1_610_612_741


def natural(*values):
    if any(type(x) is not int or x < 0 for x in values):
        raise ValueError("nonnegative mathematical integer required")


@dataclass(frozen=True)
class Shape:
    # pretty(indent) <= pretty + slope*indent; compact has no layout.
    pretty: int
    slope: int = 0
    compact: int = 0
    values: int = 1
    objects: int = 0
    arrays: int = 0
    fields: int = 0
    strings: int = 0
    depth: int = 0
    array_max: int = 0
    object_max: int = 0
    string_max: int = 0
    key_max: int = 0


def atom(encoded_bytes):
    natural(encoded_bytes)
    return Shape(pretty=encoded_bytes, compact=encoded_bytes)


def string(decoded_bytes):
    natural(decoded_bytes)
    return Shape(pretty=2 + 6 * decoded_bytes,
                 compact=2 + 6 * decoded_bytes, strings=1,
                 string_max=decoded_bytes)


def literal(text):
    # All source field names and fixed texts supplied here are printable ASCII.
    if any(ord(c) < 32 or ord(c) > 126 or c in '\\"' for c in text):
        raise ValueError("literal is not unescaped printable ASCII")
    return Shape(pretty=len(text) + 2, compact=len(text) + 2,
                 strings=1, string_max=len(text))


def container(groups, *, object_kind):
    """Groups are (multiplicity, encoded_key_bytes, decoded_key_bytes, Shape).

    Repetition counts occurrences. It does not manufacture JSON graph sharing.
    Empty groups have no contribution, including to maximum/depth dimensions.
    """
    for count, key, decoded_key, _ in groups:
        natural(count, key, decoded_key)
    groups = [g for g in groups if g[0]]
    n = sum(g[0] for g in groups)
    comma = max(0, n - 1)
    pretty = 3 + comma
    compact = 2 + comma
    slope = 2 * (n + 1)
    totals = dict(values=1, objects=int(object_kind), arrays=int(not object_kind),
                  fields=n if object_kind else 0, strings=0)
    maxima = dict(depth=1, array_max=n if not object_kind else 0,
                  object_max=n if object_kind else 0, string_max=0, key_max=0)
    for count, key, decoded_key, child in groups:
        pretty += count * (child.pretty + child.slope + 3
                           + (key + 2 if object_kind else 0))
        compact += count * (child.compact + (key + 1 if object_kind else 0))
        slope += count * child.slope
        for name in totals:
            totals[name] += count * getattr(child, name)
        maxima['depth'] = max(maxima['depth'], 1 + child.depth)
        for name in ('array_max', 'object_max', 'string_max', 'key_max'):
            maxima[name] = max(maxima[name], getattr(child, name))
        maxima['key_max'] = max(maxima['key_max'], decoded_key)
    return Shape(pretty=pretty, slope=slope, compact=compact, **totals, **maxima)


def array(count, child):
    return container([(count, 0, 0, child)], object_kind=False)


def object_fields(fields):
    return container([(1, literal(key).pretty, len(key), value)
                      for key, value in fields], object_kind=True)


def object_map(count, key_bytes, child):
    return container([(count, 2 + 6 * key_bytes, key_bytes, child)], object_kind=True)


def unknown_tree(byte_bound):
    """A #186 arbitrary parsed subtree, NOT the canonical check-tree schema.

    A byte bounds each count and total decoded key/value bytes. These coarse
    totals overlap deliberately; pretty layout is quadratic, not depth seven.
    """
    natural(byte_bound)
    if byte_bound == 0:
        raise ValueError("a parsed value consumes at least one byte")
    b = byte_bound
    # 3C + (2h+2)(V-1) + 2hC + 4F + 6K + 2S + 6L + 32V.
    pretty = 3*b + (2*b+2)*b + 2*b*b + 4*b + 6*b + 2*b + 6*b + 32*b
    return Shape(pretty=pretty, slope=4*b, compact=56*b,
                 values=b, objects=b, arrays=b, fields=b, strings=b,
                 depth=b, array_max=b, object_max=b, string_max=b, key_max=b)


def add_json_message(*, path_bytes, text_bytes, argument_count=0,
                     argument_bytes=0, rule_bytes, check_tree,
                     stats_count=0, stats_key_bytes=0, aux_bytes=0,
                     ce=None, ce_values=None):
    """Maximal Add_Json_Msg constructor; optional fields are charged, not lost.

    text_bytes is the bound BEFORE To_SARIF_Msg_Text, whose '&' placeholder
    expands to at most twelve bytes. Details/Fix/Continuations are terminal
    owners; this function does not claim Add_Json_Msg serializes those fields.
    """
    natural(path_bytes, text_bytes, argument_count, argument_bytes,
            rule_bytes, stats_count, stats_key_bytes, aux_bytes)
    msg = object_fields([('text', string(12 * text_bytes)),
                         ('arguments', array(argument_count, string(argument_bytes)))])
    region = object_fields([('startLine', atom(10)), ('startColumn', atom(10))])
    location = object_fields([('physicalLocation', object_fields([
        ('uri', string(path_bytes)), ('region', region)])), ('id', atom(1))])
    unproved = object_fields([('status', literal('unknown')), ('time', atom(20)),
                             ('steps', atom(20)), ('memory', atom(20))])
    stat = object_fields([('count', atom(10)), ('max_steps', atom(10)),
                         ('max_time', atom(32))])
    fields = [('file', string(path_bytes)), ('line', atom(10)), ('col', atom(10)),
              ('message', msg), ('relatedLocations', array(1, location)),
              ('suppressed', string(aux_bytes)), ('annot_kind', string(aux_bytes)),
              ('justif_msg', string(aux_bytes)), ('rule', string(rule_bytes)),
              ('severity', literal('warning')), ('entity', atom(10)),
              ('check_tree', check_tree), ('unproved_status', unproved),
              ('check_file', string(path_bytes)), ('check_line', atom(10)),
              ('check_col', atom(10)), ('tracefile', string(aux_bytes)),
              ('vc_file', string(aux_bytes)), ('editor_cmd', string(aux_bytes)),
              ('msg_id', atom(10)), ('how_proved', string(7)),
              ('stats', object_map(stats_count, stats_key_bytes, stat))]
    if ce is not None:
        fields.append(('cntexmp', ce))
    if ce_values is not None:
        fields.append(('cntexmp_value', ce_values))
    return object_fields(fields)


def graft_children(base, *, count, child, indent, parent_is_object=False,
                   key_bytes=0, parent_cardinality=None):
    """Add child occurrences to already charged empty containers.

    One comma per child is a safe surplus, even when a parent is empty. The
    absolute indent is relative to base's root. Counts never multiply a
    global G/A total by R. This operation requires disjoint source positions.
    """
    natural(count, indent, key_bytes)
    if count == 0:
        return base
    key = 2 + 6*key_bytes if parent_is_object else 0
    p = child.pretty + child.slope*indent + 2*indent + 2
    c = child.compact + 1
    if parent_is_object:
        p += key + 2
        c += key + 1
    attrs = asdict(base)
    attrs['pretty'] += count*p
    attrs['compact'] += count*c
    attrs['slope'] += count*(child.slope + 2)
    for name in ('values', 'objects', 'arrays', 'fields', 'strings'):
        attrs[name] += count*getattr(child, name)
    attrs['fields'] += count if parent_is_object else 0
    attrs['depth'] = max(attrs['depth'], indent + child.depth)
    attrs['key_max'] = max(attrs['key_max'], key_bytes, child.key_max)
    for name in ('array_max', 'object_max', 'string_max'):
        attrs[name] = max(attrs[name], getattr(child, name))
    cardinality = count if parent_cardinality is None else parent_cardinality
    natural(cardinality)
    key = 'object_max' if parent_is_object else 'array_max'
    attrs[key] = max(attrs[key], cardinality)
    return Shape(**attrs)


def canonical_proof(*, records, goals, attempts, answer_bytes, row_parameters):
    """Current intact schema, relative to the proof array as root.

    answer_bytes bounds one decoded answer; normal #186 canonical-byte source
    gives at most 2*(4*76+64)=736. A is repeated binding occurrences, not 4G.
    Ordered-map Include can collapse equal prover names; keeping occurrences
    is conservative. This function does not validate a malformed merged file.
    """
    natural(records, goals, attempts, answer_bytes)
    if (records == 0 and (goals or attempts)) or (goals == 0 and attempts):
        raise ValueError("inconsistent canonical occurrence bounds")
    row = add_json_message(check_tree=array(0, atom(0)), **row_parameters)
    full = array(records, row)
    # No transformations in the accepted current canonical fresh-session shape.
    goal = object_fields([('proof_attempts', object_fields([])),
                          ('transformations', object_fields([]))])
    full = graft_children(full, count=goals, child=goal, indent=3,
                          parent_cardinality=goals)
    attempt = object_fields([('time', atom(32)), ('steps', atom(20)),
                             ('result', string(answer_bytes))])
    full = graft_children(full, count=attempts, child=attempt, indent=5,
                          parent_is_object=True, key_bytes=7,
                          parent_cardinality=attempts)
    # The actual Silver projection also compacts all whitespace. Its output
    # uses {} (two bytes), unlike the pretty writer's empty-array three bytes.
    projected_row = add_json_message(check_tree=object_fields([]), **row_parameters)
    projected = array(records, projected_row)
    return dict(full=full, projected=projected)


def metadata(*, entities, location_depth, name_bytes, path_bytes,
             spark_entities, skip_flow, skip_proof, pragma_assume,
             claims, edges_per_claim, timing_entities, timing_names,
             timing_key_bytes, progress_bytes, stop_bytes,
             claim_edges=None, timing_fields=None):
    natural(entities, location_depth, name_bytes, path_bytes, spark_entities,
            skip_flow, skip_proof, pragma_assume, claims, edges_per_claim,
            timing_entities, timing_names, timing_key_bytes, progress_bytes,
            stop_bytes)
    loc = object_fields([('file', string(path_bytes)), ('line', atom(10)),
                         ('column', atom(10))])
    entity = object_fields([('name', string(name_bytes)),
                            ('sloc', array(location_depth, loc))])
    token = object_fields([('predicate', string(13)), ('arg', atom(10))])
    rule = object_fields([('assumptions', array(0, token)),
                          ('claim', token)])
    claim_edges = claims*edges_per_claim if claim_edges is None else claim_edges
    timing_fields = (timing_entities*timing_names if timing_fields is None
                     else timing_fields)
    natural(claim_edges, timing_fields)
    if claim_edges > claims*edges_per_claim or timing_fields > timing_entities*timing_names:
        raise ValueError("aggregate exceeds its supplied per-container domain")
    assumptions = graft_children(array(claims, rule), count=claim_edges,
                                  child=token, indent=3,
                                  parent_cardinality=edges_per_claim)
    timings = graft_children(object_map(timing_entities, 11, object_fields([])),
                              count=timing_fields, child=atom(32), indent=2,
                              parent_is_object=True, key_bytes=timing_key_bytes,
                              parent_cardinality=timing_names)
    assume = object_fields([('file', string(path_bytes)), ('line', atom(10)),
                            ('col', atom(10)), ('entity', atom(10))])
    return dict(spark=object_map(spark_entities, 11, literal('spec')),
                skip_flow_proof=array(skip_flow, atom(10)),
                skip_proof=array(skip_proof, atom(10)),
                progress=string(progress_bytes), stop_reason=string(stop_bytes),
                pragma_assume=array(pragma_assume, assume),
                assumptions=assumptions, timings=timings,
                entities=object_map(entities, 11, entity))


def report(metadata_fields, *, warnings, flow, proof):
    # Actual driver field order; Entity_Table is built after all To_Key/To_JSON.
    values = dict(metadata_fields, warn_error=warnings, flow=flow, proof=proof)
    names = ('spark', 'skip_flow_proof', 'skip_proof', 'progress', 'stop_reason',
             'warn_error', 'flow', 'pragma_assume', 'proof', 'assumptions',
             'timings', 'entities')
    return object_fields([(name, values[name]) for name in names])


def incoming_state(*, frontend_nodes, entities, list_headers, why_allocations,
                   name_bytes, magic_bytes, path_bytes, instantiation_edges,
                   earlier_trace_counter=0):
    """Compose the independently reviewed incoming source equations.

    At most E analyzed graphs, each overcharged by the complete process A/E/L
    domain. More precise separately source-bound per-graph sums can replace
    this uniform envelope. A is typed nodes, not serialized occurrences.
    """
    natural(frontend_nodes, entities, list_headers, why_allocations, name_bytes,
            magic_bytes, path_bytes, instantiation_edges, earlier_trace_counter)
    a, e, h = frontend_nodes, entities, instantiation_edges
    f = 2*(e+6)+1
    v = 34+4*e+28*a+list_headers
    graph_flow = 2*a*f+7*v*f+12*f+v*(4+a)+13*a+e+6
    flow = e*graph_flow+e*(2*f+1)+(4*a+2*e)*f
    warning = why_allocations+e*(a*a+13*a)
    traces = e*(v+2*v*f)
    flow_name = max(2*name_bytes+14, magic_bytes, 6)
    substituted_name = max(4*name_bytes+64, magic_bytes+2)
    location = min(66558, (h+1)*(path_bytes+64))
    text = 5288+3*substituted_name+5*location+h*(path_bytes+38)
    return dict(flow_ids=f, vertices_per_graph=v, graph_count=e,
                flow_records=flow, warning_records=warning, proof_records=0,
                third_pool_calls=2*e+flow, message_ids=flow,
                native_print_calls=3*flow+2*warning,
                trace_attempts=traces, trace_counter=earlier_trace_counter+traces,
                trace_lines_per_file=v, trace_line_bytes=path_bytes+12,
                flow_name_bytes=flow_name, message_bytes=text,
                warning_message_bytes=192, native_temporary_bytes=7*text+194,
                guards=dict(flow_set=flow <= HASH, flow_array=flow <= 2**30-1,
                            warning_array=warning <= 2**30-1,
                            trace_counter=earlier_trace_counter+traces <= I,
                            trace_lines=v+1 <= I,
                            trace_column=path_bytes+12 <= I,
                            source_span_lists=f <= HASH))


def selected_report(*, frontend_nodes, entities, list_headers, why_allocations,
                    name_bytes, full_name_bytes, magic_bytes, path_bytes,
                    instantiation_edges, records, goals, attempts, launches,
                    expression_bytes):
    """Source-bound current invocation composition, using the uniform E-graph
    envelope. The accepted response provider supplies global R/G/A and J;
    this function neither observes a report nor invents a canonicality gate.
    """
    natural(full_name_bytes, records, goals, attempts, launches, expression_bytes)
    inc = incoming_state(frontend_nodes=frontend_nodes, entities=entities,
                         list_headers=list_headers, why_allocations=why_allocations,
                         name_bytes=name_bytes, magic_bytes=magic_bytes,
                         path_bytes=path_bytes, instantiation_edges=instantiation_edges)
    # Not_Proved <=110 max-return literals +109 all local String constants;
    # Proved <=101+25+6. CP adds a prefix and escaped bound prefix, then CWE.
    proof_text = 219+15+2*(16+expression_bytes)+11
    proof_text += instantiation_edges*(path_bytes+38)
    row = dict(path_bytes=path_bytes, text_bytes=proof_text, rule_bytes=64,
               stats_count=3, stats_key_bytes=7, aux_bytes=path_bytes+24)
    proofs = canonical_proof(records=records, goals=goals, attempts=attempts,
                             answer_bytes=736, row_parameters=row)
    flow_row = add_json_message(path_bytes=path_bytes, text_bytes=inc['message_bytes'],
                               rule_bytes=64, check_tree=object_fields([]),
                               aux_bytes=path_bytes+24)
    warning_row = add_json_message(path_bytes=path_bytes, text_bytes=192,
                                  argument_count=1, argument_bytes=name_bytes,
                                  rule_bytes=64, check_tree=object_fields([]))
    flow = array(inc['flow_records'], flow_row)
    warnings = array(inc['warning_records'], warning_row)
    claims = claim_domain(entities, entities*entities)
    timing_fields = 7+2*entities+26*launches
    meta = metadata(entities=entities, location_depth=instantiation_edges+1,
                    name_bytes=full_name_bytes, path_bytes=path_bytes,
                    spark_entities=entities, skip_flow=0, skip_proof=0, pragma_assume=0,
                    claims=claims['claims'], claim_edges=claims['edges'],
                    edges_per_claim=5*entities, timing_entities=entities+1,
                    timing_names=timing_fields, timing_fields=timing_fields,
                    timing_key_bytes=59, progress_bytes=64, stop_bytes=64)
    lifetime = assumption_lifetime(spark=2*entities, skip_flow=0, skip_proof=0,
                                   vc_timings=2*entities, response_timings=26*launches,
                                   entity_messages=inc['flow_records']+records,
                                   pragma_assume=0, claims=claims['claims'],
                                   claim_edges=claims['edges'],
                                   location_depth=instantiation_edges+1)
    return dict(incoming=inc, proof_message_bytes=proof_text,
                full=report(meta, warnings=warnings, flow=flow, proof=proofs['full']),
                projected=report(meta, warnings=warnings, flow=flow,
                                 proof=proofs['projected']),
                third_pool=lifetime, claim_domain=claims)


def assumption_lifetime(*, spark, skip_flow, skip_proof, vc_timings,
                        response_timings, entity_messages, pragma_assume,
                        claims, claim_edges, location_depth, initial_finds=0):
    values = (spark, skip_flow, skip_proof, vc_timings, response_timings,
              entity_messages, pragma_assume, claims, claim_edges)
    natural(*values, location_depth, initial_finds)
    calls = sum(values)
    finds = initial_finds + (location_depth + 1) * calls
    return dict(entity_requests=calls, find_calls=finds, guard=finds <= I)


def claim_domain(entities, call_pairs):
    natural(entities, call_pairs)
    return dict(claims=5*entities,
                edges=min(25*entities*entities, 7*call_pairs))


def failed_fix_calls(frontend_nodes, unproved_rows):
    natural(frontend_nodes, unproved_rows)
    a = frontend_nodes
    return unproved_rows * (2*a + 1 + 2*a*(a + 1))


def third_pool_domains(*, entities, filenames, location_depth, find_calls,
                       name_bytes, path_bytes):
    natural(entities, filenames, location_depth, find_calls, name_bytes, path_bytes)
    distinct = entities + filenames
    maximum = max(name_bytes, path_bytes)
    return dict(distinct_strings=distinct, subprogram_records=entities,
                location_list=location_depth,
                guards=dict(lifetime_calls=find_calls <= I,
                            symbols_hash=distinct <= HASH,
                            subprogram_hash=entities <= HASH,
                            subprogram_vector=entities <= 2**30-1,
                            location_list=location_depth <= I-1,
                            copied_string=maximum+1 <= I))


def report_phase_aliases(registrations):
    """Selected no-interleaving post-translation lifetime, not arbitrary callers.

    Each fresh nonempty continuation backing occurs at most once per VC row;
    one global-stack stale holder survives Delete_Last. Sixteen additional
    explicit local/return/assignment holders cover conversion and printing.
    JSON and XString holders have independent source slot censuses.
    """
    natural(registrations)
    native_strings = registrations + 1 + 16
    return dict(json_references=32, xstring_references=16,
                unbounded_references=native_strings,
                prefix_continuation_length=2, result_continuation_length=3,
                guards=dict(json=32 < U, xstring=16 < U,
                            unbounded=native_strings < U))


def producer_source_open_bound(runtime_names=1575, silver_names=6,
                               main_names=1, extra_request_names=0):
    """Under the controlled source/map/search and no-preprocessing profile.

    Unit loader deduplicates imported Fnames; +1 startup System and +1 possible
    Check_Bad_Body read are separate from that cache, also with indexed Main.
    This counts successful opens, not an observed File_Name_Chars length.
    """
    natural(runtime_names, silver_names, main_names, extra_request_names)
    return runtime_names + silver_names + main_names + extra_request_names + 2


def terminal_warnings(*, count, decoded_sum, decoded_max,
                      initial_line, initial_column):
    natural(count, decoded_sum, decoded_max, initial_line, initial_column)
    return dict(offered_text_bytes=2*decoded_sum+count,
                guards=dict(line=initial_line+count <= I,
                            column=initial_column+decoded_max+1 <= I))


def failed_fix_strings(*, entities, flow_ids, expression_image,
                       name_image, flow_name, path_bytes):
    """Current no-record diagnostic helpers; expression_image needs its lemma.

    1326 is the checked sum of string literals in Get_Fix, not a fitted
    bytes/row coefficient. The variable/callee loops are charged separately.
    The worst range precondition duplicates five operand images and two
    bound images; Escape can double them. The outer search returns at its
    first explanation and does not concatenate explanations across nodes.
    """
    natural(entities, flow_ids, expression_image, name_image, flow_name, path_bytes)
    image = max(expression_image, 1024, name_image+6)
    location = path_bytes + 14  # "at " + filename + ":" + ten decimal digits
    alternatives = {
        'range_precondition': 14*image+location,
        'variables': flow_ids*(2*flow_name+33)+location,
        'output_variables': flow_ids*(3*flow_name+30)+location,
        'calls': entities*(name_image+14),
    }
    fix = 1326 + max(alternatives.values())
    # Exception_Sets.Print: a pretty name and <=6 separator bytes per entity,
    # with finite "any exception but"/empty alternatives.
    explanation = 705 + 17 + entities*(name_image+6)
    return dict(fix=fix, explanation=explanation, alternatives=alternatives,
                selected_expression_frontier_required=True)


def expression_image(*, decoded_name, string_characters, attribute_name,
                     source_span, uint_image_bytes=1024, generated=True):
    """Selected scalar/rank-one Character rewrite frontier, reset depth <=2.

    This is not a theorem for arbitrary GNAT ASTs. String_To_Name copies one
    Character per existing Stringt character. Supply the source-derived UInt
    image bound. Printed CP resets reach source copies or fixed leaf templates;
    private Get_Fix may require the larger two-reset envelope.
    Source copies return <=510 but allocate the entire source span first.
    """
    natural(decoded_name, string_characters, attribute_name, source_span, uint_image_bytes)
    w = max(510, decoded_name, uint_image_bytes, string_characters+2, attribute_name, 64)
    levels = [24*w+2381]
    for _ in range(2):
        levels.append(24*max(w, levels[-1])+2381)
    result = max(510, levels[-1]) if generated else 510
    return dict(bytes=result, primitive=w, reset_levels=levels,
                printed_cp_bytes=24*w+2381,
                guards=dict(source_span=source_span+1 <= I,
                            image_string=result+1 <= I,
                            native_name_buffer=string_characters+1 <= I))


def uint_image_storage(*, radix_digits, prefix_entries, prefix_digits,
                       table_index_room):
    """Present Uint inputs only; no exponent abbreviation branch is needed.

    Existing frontend magnitudes use base32768 digits, not bits. Image_Out
    restores its mark; its small power cache uses direct values before any
    image temporaries, so these are peak suffix additions, not lifetime/row
    products. Generic native table offsets remain in table_index_room.
    """
    natural(radix_digits, prefix_entries, prefix_digits, table_index_room)
    bits = max(1, 15*radix_digits)
    divides = 5*bits+6
    entries = 2*divides+3
    local_digits = (bits+14)//15+1
    digits = entries*local_digits
    length = 2*bits+10
    u_capacity = 2*max(5000, prefix_entries+entries)+10
    d_capacity = 2*max(10000, prefix_digits+digits)+10
    return dict(magnitude_bits=bits, image_bytes=length,
                temporary_entries=entries, temporary_digits=digits,
                local_vector_digits=local_digits,
                guards=dict(no_abbreviation=length <= 1018,
                            uint_table=u_capacity < table_index_room,
                            digit_table=d_capacity < I,
                            uint_allocation=8*u_capacity <= SIZE,
                            digit_allocation=4*d_capacity <= SIZE),
                present_input_required=True)


def native_diagnostic_counts(*, initial_entries, initial_noninstance,
                             incoming_print_calls, proof_rows, location_depth,
                             regular_flow_rows, initial_message_id=0):
    """Prospective brief/all mode. GCC incoming prefix is a distinct owner.

    Each proof print has one message, <=3 original continuations, and <=1
    explain-code continuation. Each Errout call records <=1 non-instance
    message and <=h Errors/Locations entries, h counting location records.
    Table.Increment=200 means factor three, checked before Int conversion.
    """
    natural(initial_entries, initial_noninstance, incoming_print_calls,
            proof_rows, location_depth, regular_flow_rows, initial_message_id)
    calls = incoming_print_calls + 5*proof_rows
    entries = initial_entries + location_depth*calls
    noninstance = initial_noninstance + calls
    messages = initial_message_id + regular_flow_rows + proof_rows
    return dict(print_calls=calls, errors=entries, locations=entries,
                noninstance=noninstance, next_message_id=messages,
                guards=dict(message_id=messages < I,
                            errors_table=3*max(200, entries)+10 < I,
                            noninstance_table=2*max(100, noninstance)+10 < I,
                            total_error_warning_sum=entries < I),
                initial_counts_from_frontend_diagnostics_required=True)


def frontend_diagnostics(*, process, main_loops=0, main_withs=0,
                         fixed_name_bytes, path_bytes):
    """Reviewed fixed proof-mode counts, plus Main's source-derived additions.

    12/7 are whole-prefix supersets for earlier GCC counts, not actual warning
    counts. Source/configuration noninterference and the fixed phase reduction
    are prerequisites. Broad raw fixed recipes are never printed line bounds.
    """
    natural(main_loops, main_withs, fixed_name_bytes, path_bytes)
    fixed = {'Main': 0, 'Silver_IO': 12, 'Silver_Arguments': 7,
             'Silver_Output_Libc': 0, 'Silver_Runtime': 0}[process]
    if process != 'Main' and (main_loops or main_withs):
        raise ValueError('Main terms do not belong to a fixed process')
    main = 2*main_loops+main_withs
    entries = fixed+main
    raw_fixed = 2*27301966+2*fixed_name_bytes+2*path_bytes+128
    return dict(entries=entries, noninstance=entries, edits=0, fixes=0,
                raw_history_characters=fixed*raw_fixed+64*main,
                formatted_lifetime_characters=(2*66558+2)*entries,
                heap_string_requests=2*entries,
                raw_fixed_template=raw_fixed, displayed_fixed_lines=0,
                displayed_main_lines=main,
                guards=dict(raw_string=raw_fixed+1 <= I,
                            raw_lifetime=fixed*raw_fixed+64*main <= SIZE))


def diagnostic_name_suffix(*, string_descriptors, maximum_string_length):
    """Native Namet suffix, separate from GNATCOLL symbols.

    String_Image calls String_To_Name; duplicates share a spelling. One
    Compiler_Abort Name_Enter for gnat_bug.box adds twelve characters plus
    the native table's terminating character even when the file is absent.
    """
    natural(string_descriptors, maximum_string_length)
    return dict(names=string_descriptors+1,
                characters=string_descriptors*(maximum_string_length+1)+13)


def compiler_abort(*, error_bytes, path_bytes, version_bytes, target_bytes,
                   source_opens=1584, bug_box_absent=True, error_tail_bytes=None):
    """Internal=True, Empty node, From_GCC=True, selected debug options off.

    Bounds segments at explicit Write_Eol calls. Write_Char prechecks and
    handles internal LF safely; only the final X segment needs an End_Line
    spare. Total X still owns allocation and X'Length+Column. The fixed
    FSF/GNATprove recipe has two SPARK tracker lines. The intentionally loose
    thirty fixed lines cover headers, separators, note lines and empty lines.
    """
    natural(error_bytes, path_bytes, version_bytes, target_bytes, source_opens)
    if error_tail_bytes is None:
        error_tail_bytes = error_bytes
    natural(error_tail_bytes)
    line = max(77, 2+version_bytes+2+target_bytes+2+10+1,
               5+error_tail_bytes+1, 12+path_bytes+1, path_bytes)
    offered = 30*78 + error_bytes + version_bytes + target_bytes + path_bytes
    offered += source_opens*(path_bytes+1)
    return dict(maximum_explicit_eol_segment=line, offered_bytes=offered,
                error_final_segment=error_tail_bytes,
                file_name_chars=source_opens*(path_bytes+1),
                guards=dict(controlled_bugbox_absence=bool(bug_box_absent),
                            output_explicit_eol=line+1 <= 32767,
                            message_column_sum=error_bytes+32768 <= I,
                            filename_table=source_opens*(path_bytes+1)+1 <= I),
                previous_serious_error_flush_is_separate=True)


def brief_output(*, message_bytes, path_bytes, substitution_bytes=0,
                 output_calls, initial_column=1):
    """Plain uncolored Errout output, with default Error_Msg_Line_Length=0.

    Caller supplies the source-bound expansion of any native name/location
    insertions; this is not a measured rendered message length. 64 covers the
    finite severity/switch prefixes, 24 the file:line:column punctuation and
    numeric fields. This guard avoids relying on a fortunate buffer residue.
    """
    natural(message_bytes, path_bytes, substitution_bytes, output_calls, initial_column)
    line = path_bytes + 24 + message_bytes + substitution_bytes + 64
    return dict(maximum_line=line, offered_bytes=output_calls*(line+1),
                guards=dict(explicit_eol=initial_column+line <= 32767,
                            string_loop_spare=2*message_bytes+3 <= I,
                            msg_buffer=line <= 1024+2*32767))


def representation(shape, *, filename_bytes, max_alignment=64, header_bytes=64):
    """Sufficient selected-Linux writer guards; no aggregate physical-RAM gate.

    Count/capacity/backing/path guards are separate. Successful source binding,
    caller aliases and numeric/clock premises must be supplied independently.
    """
    natural(filename_bytes, max_alignment, header_bytes)
    b = shape.pretty
    decoded = max(shape.string_max, shape.key_max)
    xback = max(24, decoded + (decoded % 2) if decoded <= 4096
                else (decoded // 4096 + 1) * 4096)
    backing = b + b//2 + 2*max_alignment + header_bytes
    guards = {
        'string_and_text_io_column': b + 1 <= I,
        'indent_add_and_double': 2 * (shape.depth + 1) <= I,
        'array_geometric_capacity': shape.array_max <= 2**30 - 1,
        'ordered_map_length': shape.object_max <= I - 1,
        'escape_lookahead': decoded + 3 <= I,
        'escape_string_length': 6*decoded + 2 <= I,
        'new_xstring_backing': xback <= I,
        'unbounded_alignment_intermediates': backing <= I,
        'individual_64bit_allocation': backing <= SIZE and xback + 8 <= SIZE,
        'filename_compose': filename_bytes + 7 <= I,
    }
    return dict(shape=asdict(shape), json_write_string=b,
                spark_file=b+1, unbounded_allocation=backing,
                guards=guards, sufficient=all(guards.values()),
                native_inputs_bound=False)
