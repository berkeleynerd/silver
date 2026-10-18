"""Read-only GDB helper for the pinned x86-64 producer; does not run inferior.

Load using exec(open(path).read()) in GDB's Python block. Call raw_snapshot at
an already established stop. It reads memory, never calls inferior functions.
"""
import gdb
import re
from collections import Counter


def raw_field(type_name, field_name):
    fields = gdb.lookup_type(type_name).strip_typedefs().fields()
    field = next(f for f in fields if f.name == field_name)
    assert field.bitpos % 8 == 0, (type_name, field_name)
    return field.bitpos // 8, field.type.sizeof


def raw_layout():
    layout = {}
    for prefix in ("node_tables", "node_list_tables"):
        name = "why__atree__" + prefix
        layout[prefix] = {
            "elements": raw_field(name + "__vector", "elements"),
            "last": raw_field(name + "__vector", "last"),
            "array": raw_field(name + "__elements_type", "ea")[0],
            "first_index": 0 if prefix == "node_tables" else 2**30,
            "last_index": 2**30-1 if prefix == "node_tables" else 2**31-1,
        }
        assert layout[prefix]["elements"] == (8, 8)
        assert layout[prefix]["last"] == (16, 4)
        assert layout[prefix]["array"] == 8
    layout["list_content"] = raw_field("why__atree__list_info", "content")[0]
    layout["list_first"] = raw_field("why__atree__why_node_lists__list", "first")
    layout["list_last"] = raw_field("why__atree__why_node_lists__list", "last")
    layout["list_length"] = raw_field("why__atree__why_node_lists__list", "length")
    layout["link_element"] = raw_field("why__atree__why_node_lists__node_type", "element")
    layout["link_next"] = raw_field("why__atree__why_node_lists__node_type", "next")
    layout["link_prev"] = raw_field("why__atree__why_node_lists__node_type", "prev")
    layout["kind"] = raw_field("why__atree__why_node", "kind")
    assert layout["list_content"] == 8
    assert layout["list_first"] == (8, 8)
    assert layout["list_last"] == (16, 8)
    assert layout["list_length"] == (24, 4)
    assert layout["link_element"] == (0, 4)
    assert layout["link_next"] == (8, 8)
    assert layout["link_prev"] == (16, 8)
    assert layout["kind"] == (0, 1)
    node_type = gdb.lookup_type("why__atree__why_node")
    enum_type = next(f.type for f in node_type.fields() if f.name == "kind")
    layout["kinds"] = {f.enumval: f.name for f in enum_type.fields()}
    assert len(layout["kinds"]) == 64
    child_fields = {}
    for f in node_type.fields():
        match = re.fullmatch(r"k(\d+)_(.*)", f.name or "")
        field_type = str(f.type)
        if match is None or "__opaque_" not in field_type:
            continue
        assert f.type.sizeof == 4 and f.bitpos % 8 == 0
        kind = int(match.group(1))
        tag = "list" if field_type.endswith(("_list", "_olist")) else "node"
        assert tag == "list" or field_type.endswith(("_id", "_oid"))
        child_fields.setdefault(kind, []).append(
            (f.name, f.bitpos // 8, f.type.sizeof, tag, field_type.endswith("_oid")))
    layout["child_fields"] = child_fields
    return layout


def raw_snapshot(phase, graph=True):
    layout = raw_layout()
    inferior = gdb.selected_inferior()
    def read(address, size, signed=False):
        return int.from_bytes(bytes(inferior.read_memory(address, size)),
                              "little", signed=signed)
    def symbol(name):
        return int(gdb.parse_and_eval("&" + name))
    def member(address, field):
        offset, size = field
        return read(address + offset, size)
    def vector(symbol_name, key):
        spec = layout[key]
        base = symbol(symbol_name)
        last = member(base, spec["last"])
        elements = member(base, spec["elements"])
        first = spec["first_index"]
        assert first - 1 <= last <= spec["last_index"], (symbol_name, first, last)
        count = last - first + 1
        if count:
            assert elements != 0, (symbol_name, count, last)
        pointers = {}
        for i in range(first, last + 1):
            address = elements + spec["array"] + 8*(i-spec["first_index"])
            pointers[i] = read(address, 8)
            assert pointers[i] != 0, (symbol_name, i)
        return count, pointers
    node_count, node_ptrs = vector("why__atree__node_table", "node_tables")
    # The node-zero sentinel consumes one vector entry but is not an allocation.
    nodes = node_count - 1
    lists, list_ptrs = vector("why__atree__list_table", "node_list_tables")
    contents, total = {}, 0
    for i, address in list_ptrs.items():
        content = address + layout["list_content"]
        length = member(content, layout["list_length"])
        total += length
        if not graph:
            continue
        cursor = member(content, layout["list_first"])
        previous = 0
        members = []
        for _ in range(length):
            assert cursor != 0, (i, "short list")
            assert member(cursor, layout["link_prev"]) == previous
            element = member(cursor, layout["link_element"])
            assert 0 <= element <= nodes, (i, element, nodes)
            members.append(element)
            previous, cursor = cursor, member(cursor, layout["link_next"])
        assert cursor == 0, (i, "long list or cycle")
        assert previous == member(content, layout["list_last"])
        contents[i] = members
    result = dict(phase=phase, nodes=nodes, lists=lists, retained_elements=total,
                  temporary_names=read(symbol("why__gen__names__new_temp_identifier_counter"),4),
                  method="DWARF offsets and raw read_memory; no inferior calls")
    if not graph:
        return result
    rows, edges, kinds = {}, {}, Counter()
    for i, address in node_ptrs.items():
        kind = member(address, layout["kind"])
        assert kind in layout["kinds"], (i, kind)
        name = layout["kinds"][kind]
        kinds[name] += 1
        fields, children = {}, []
        for field, offset, size, tag, optional_node in layout["child_fields"].get(kind, []):
            value = read(address + offset, size)
            fields[field] = {"kind":tag,"value":value}
            if tag == "list":
                # Optional lists are ordinary allocated lists of length zero,
                # never node-zero sentinels (Why.Atree.To_Json / Is_Empty).
                assert value in contents, (i, field, value, lists)
                children.extend(contents[value])
            else:
                assert 0 <= value <= nodes, (i, field, value, nodes)
                if value or not optional_node:
                    children.append(value)
        rows[i] = {"kind":name,"fields":fields}
        edges[i] = children
    assert rows[0]["kind"].endswith("w_unused_at_start")
    cache, active = {0:1}, set()
    def occurrences(i):
        if i in cache:
            return cache[i]
        assert i not in active, ("node graph cycle", i)
        active.add(i)
        value = 1 + sum(occurrences(child) for child in edges[i])
        active.remove(i)
        cache[i] = value
        return value
    roots = [i for i,row in rows.items() if row["kind"].endswith("w_theory_declaration")]
    root_sizes = {i:occurrences(i) for i in roots}
    result.update(node_kind_counts=dict(kinds), theory_roots=roots,
                  theory_occurrences=root_sizes,
                  all_theory_occurrences=sum(root_sizes.values()),
                  graph={"nodes":rows,"lists":contents}, layout=layout)
    return result
