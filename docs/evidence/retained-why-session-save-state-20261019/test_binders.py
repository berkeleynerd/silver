"""Focused semantic regressions: occurrence multiplicity and delayed opening."""
import unittest
from binders import Opened


class Graph:
    def __init__(self):
        self.blocks = {}

    def block(self, fields, tag=0):
        pointer = 8 * (1 + len(self.blocks))
        self.blocks[str(pointer)] = {'tag': tag, 'fields': list(fields)}
        return pointer

    def term(self, tag, fields):
        return self.block((self.block(fields, tag), 1, 1, 1))

    def seq(self, values):
        pointer = 1
        for value in reversed(values):
            pointer = self.block((value, pointer))
        return pointer

    def mapping(self, pairs):
        pointer = 1
        for key, value in reversed(pairs):
            pointer = self.block((1, key, value, pointer, 3))
        return pointer

    def variable(self):
        return self.block((1, 1))

    def var(self, variable):
        return self.term(0, (variable,))

    def eps(self, body=None):
        variable = self.variable()
        return self.term(6, (self.block((variable, self.block((1, 1)),
                                        self.var(variable) if body is None else body)),))

    def let(self, variable, body, pairs=()):
        binding = self.block((variable, self.block((1, self.mapping(pairs))), body))
        return self.term(4, (self.block((1, 1, 1, 1)), binding))


class BinderTests(unittest.TestCase):
    def count(self, graph, term):
        return Opened(graph.blocks).count(term)[1]

    def test_shared_child_has_two_occurrences(self):
        graph = Graph()
        child = graph.eps()
        self.assertEqual(self.count(graph, graph.term(8, (1, child, child))), 2)

    def test_quantifier_list_and_repeated_triggers(self):
        graph = Graph()
        child = graph.eps()
        variables = graph.seq((graph.variable(), graph.variable()))
        triggers = graph.seq((graph.seq((child, child)),))
        binding = graph.block((variables, graph.block((1, 1)), triggers, child))
        self.assertEqual(self.count(graph, graph.term(7, (1, binding))), 5)

    def test_delayed_value_multiplied_by_variable_occurrences(self):
        graph = Graph()
        x, y = graph.variable(), graph.variable()
        body = graph.term(8, (1, graph.var(x), graph.var(x)))
        self.assertEqual(self.count(graph, graph.let(y, body, ((x, graph.eps()),))), 3)

    def test_substitution_values_do_not_reenter_same_frame(self):
        graph = Graph()
        x, y, z = graph.variable(), graph.variable(), graph.variable()
        body = graph.term(8, (1, graph.var(x), graph.var(y)))
        term = graph.let(z, body, ((x, graph.var(y)), (y, graph.eps())))
        self.assertEqual(self.count(graph, term), 2)

    def test_substitution_values_see_outer_frame(self):
        graph = Graph()
        x, y, z, w = (graph.variable() for _ in range(4))
        inner = graph.let(z, graph.var(x), ((x, graph.var(y)),))
        self.assertEqual(self.count(graph, graph.let(w, inner, ((y, graph.eps()),))), 3)

    def test_renamed_binder_overrides_saved_substitution(self):
        graph = Graph()
        x = graph.variable()
        self.assertEqual(self.count(graph, graph.let(x, graph.var(x), ((x, graph.eps()),))), 1)

    def test_case_distinct_pattern_variable_map(self):
        graph = Graph()
        x, y = graph.variable(), graph.variable()
        pattern = graph.block((1, graph.mapping(((x, 1), (y, 1))), 1))
        branch = graph.block((pattern, graph.block((1, 1)), graph.var(x)))
        term = graph.term(5, (graph.var(y), graph.seq((branch, branch))))
        self.assertEqual(self.count(graph, term), 4)

    def test_cyclic_term_rejected(self):
        graph = Graph()
        term = graph.term(9, (1,))
        node = graph.blocks[str(term)]['fields'][0]
        graph.blocks[str(node)]['fields'][0] = term
        with self.assertRaisesRegex(AssertionError, 'cyclic opened state'):
            self.count(graph, term)


if __name__ == '__main__':
    unittest.main()
