"""Typed missing-metadata projection; read-only, no inferior execution.

Uses the frozen R28 RawStore. Only selected fields of theories/drivers/meta
records are followed: descriptions, environments and printer closures are not
metadata arguments. Every followed block is logged before interpretation.
"""
import json


class Projection:
    def __init__(self, session):
        self.session = session
        self.store = session.store
        self.out = session.out
        self.metas = {}
        self.theories = {}
        self.tdecls = {}
        self.graph_roots = set()

    def block(self, pointer, words, tag=0):
        return self.store.block(pointer, tag=tag, words=words)

    def string(self, pointer):
        r = self.store.raw(pointer)
        assert r['tag'] == 252
        b = bytes.fromhex(r['payload_hex'])
        assert b[len(b) - b[-1] - 1] == 0
        return b[:len(b) - b[-1] - 1].decode('utf-8')

    def seq(self, pointer):
        return list(self.store.values(pointer))

    def mapping(self, pointer, active=frozenset()):
        if pointer == 1:
            return []
        assert pointer not in active, ('map cycle', pointer)
        l, k, v, r, height = self.block(pointer, 5)
        assert height & 1 and height > 1
        active = active | {pointer}
        return self.mapping(l, active) + [(k, v)] + self.mapping(r, active)

    def tdecl_set(self, pointer, active=frozenset()):
        """Task.HStdecl = Hcpt.MakeSet; source fold order is left/right."""
        if pointer == 1:
            return []
        assert pointer not in active, ('Patricia cycle', pointer)
        r = self.store.raw(pointer)
        if r['tag'] == 0:
            uid, key, unit = self.block(pointer, 3)
            assert uid & 1 and unit == 1
            self.tdecl(key)
            return [key]
        assert r['tag'] == 1
        uid, prefix, mask, l, r = self.block(pointer, 5, tag=1)
        assert all(x & 1 for x in (uid, prefix, mask))
        active = active | {pointer}
        return self.tdecl_set(l, active) + self.tdecl_set(r, active)

    def driver_tdecl_set(self, pointer):
        """Theory.Stdecl AVL: Task.mli hides Task.ml's internal Stdecl alias."""
        rows = self.mapping(pointer)
        assert all(value == 1 for _, value in rows)
        for key, _ in rows:
            self.tdecl(key)
        return [key for key, _ in rows]

    def meta(self, pointer):
        if pointer not in self.metas:
            name, types, exclusive, desc, tag = self.block(pointer, 5)
            assert exclusive in (1, 3) and tag & 1
            kinds = self.seq(types)
            assert all(x in range(1, 14, 2) for x in kinds)
            self.graph_roots.update((name, types))
            self.metas[pointer] = dict(name=self.string(name),
                argument_types=[x >> 1 for x in kinds], exclusive=exclusive == 3,
                tag=tag >> 1, description_pointer_not_followed=desc)
        return self.metas[pointer]

    def theory(self, pointer):
        if pointer not in self.theories:
            fields = self.block(pointer, 11)
            name, path, local = fields[0], fields[1], fields[9]
            name_string, _, _, tag = self.block(name, 4)
            assert tag & 1
            local_entries = self.mapping(local)
            assert all(v == 1 for _, v in local_entries)
            self.graph_roots.update((name, path, local))
            self.theories[pointer] = dict(name_identifier=name,
                name=self.string(name_string), path=[self.string(x) for x in self.seq(path)],
                local_identifiers=[k for k, _ in local_entries])
        return self.theories[pointer]

    def tdecl(self, pointer):
        if pointer in self.tdecls:
            return self.tdecls[pointer]
        node, tag = self.block(pointer, 2)
        assert tag & 1
        n = self.store.raw(node)
        row = dict(node=node, tag=tag >> 1, kind=n['tag'])
        if n['tag'] == 0:
            d, = self.block(node, 1)
            row['declaration'] = d
        elif n['tag'] == 1:
            th, = self.block(node, 1, tag=1)
            self.theory(th)
            row['theory'] = th
        elif n['tag'] == 2:
            th, sm = self.block(node, 2, tag=2)
            self.theory(th)
            maps = self.block(sm, 4)
            self.graph_roots.add(sm)
            row.update(theory=th, symbol_map=sm,
                symbol_maps=[self.mapping(p) for p in maps])
        else:
            assert n['tag'] == 3
            meta, args = self.block(node, 2, tag=3)
            spec = self.meta(meta)
            arguments = []
            for value in self.seq(args):
                r = self.store.raw(value)
                assert 0 <= r['tag'] <= 6 and r['words'] == 1
                arg, = self.block(value, 1, tag=r['tag'])
                arguments.append(dict(kind=r['tag'], value=arg))
            assert [r['kind'] for r in arguments] == spec['argument_types']
            self.graph_roots.add(args)
            row.update(meta=meta, argument_list=args, arguments=arguments)
        self.tdecls[pointer] = row
        return row

    def histories(self, task):
        head, = self.block(task, 1)
        hd = self.block(head, 6)
        clone_rows, meta_rows = [], []
        for identifier, s in self.mapping(hd[3]):
            self.graph_roots.add(identifier)
            clone_rows.append(dict(identifier=identifier, set=s, tdecls=self.tdecl_set(s)))
        for meta, s in self.mapping(hd[4]):
            self.meta(meta)
            meta_rows.append(dict(meta=meta, set=s, tdecls=self.tdecl_set(s)))
        return dict(clone_map=hd[3], meta_map=hd[4], clone_rows=clone_rows, meta_rows=meta_rows)

    def collect(self):
        chains = json.loads((self.out / 'session-task-chains.json').read_bytes())
        histories = {}
        for task, chain in chains.items():
            histories[task] = self.histories(int(task))
            for row in chain:
                self.tdecl(row['tdecl'])
        controller = self.block(self.session.roots['controller'], 6)
        table, _ = self.store.table(controller[3], int_keys=False)
        drivers = []
        for entry in table['entries']:
            key = self.block(entry['key'], 3)
            labels = [self.string(x) for x in key]
            config, driver = self.block(entry['value'], 2)
            fields = self.block(driver, 11)
            transforms = [self.string(x) for x in self.seq(fields[3])]
            row = dict(key=entry['key'], prover=labels, driver=driver,
                       transformations=transforms)
            if labels[0].lower() == 'z3' and 'counterexamples_dependent_intros' not in transforms:
                assert fields[6] == 1, 'Selected Z3 drv_thuse is nonempty'
                metadata = []
                for identifier, pair in self.mapping(fields[8]):
                    theory, declarations = self.block(pair, 2)
                    self.theory(theory)
                    assert self.theories[theory]['name_identifier'] == identifier
                    metadata.append(dict(identifier=identifier, theory=theory,
                        set=declarations, tdecls=self.driver_tdecl_set(declarations)))
                self.graph_roots.update((entry['key'], fields[3]))
                row.update(selected=True, drv_thuse=fields[6], drv_meta=fields[8],
                           metadata=metadata, driver_tag=fields[10] >> 1)
            drivers.append(row)
        assert sum(bool(r.get('selected')) for r in drivers) == 1
        graph = self.store.ordinary_graph(sorted(self.graph_roots), 'metadata-payload')
        result = dict(complete=True, metas=self.metas, theories=self.theories,
            tdecls=self.tdecls, raw_task_histories=histories, drivers=drivers,
            payload_graph=graph, initial_introduction_table_captured=False,
            full_Hsdecl_captured=False)
        self.session.save('metadata.json', result)
        return result
