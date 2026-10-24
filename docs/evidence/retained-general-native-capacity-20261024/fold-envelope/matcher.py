"""Review inventory; lexical pattern extraction is not GCC semantics."""
import re

class Form:
    def __init__(self, start):
        self.start = start
        self.end = None
        self.items = []


def forms(raw):
    """Preserve offsets; skip comments, strings, directives and C brace blocks.

    Both #if branches remain, making the simplify inventory a superset of
    GENERIC. Macro directives here define only builtin lists / C expressions.
    Parentheses inside if-conditions remain harmless nested forms.
    """
    clean = list(raw)
    pattern = re.compile(r'/\*.*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|'
                         r"'(?:\\.|[^'\\])*'", re.S)
    for match in pattern.finditer(raw):
        for pos in range(match.start(), match.end()):
            if clean[pos] != "\n":
                clean[pos] = " "
    # A directive's backslash continuation is part of the same directive.
    offset, continuation = 0, False
    for line in "".join(clean).splitlines(keepends=True):
        directive = continuation or line.lstrip().startswith("#")
        continuation = directive and line.rstrip("\n").endswith("\\")
        if directive:
            for pos in range(offset, offset+len(line)):
                if clean[pos] != "\n":
                    clean[pos] = " "
        offset += len(line)
    depth = 0
    for pos, char in enumerate(clean):
        if char == "{":
            depth += 1
        if depth and char != "\n":
            clean[pos] = " "
        if char == "}":
            depth -= 1
            assert depth >= 0
    assert depth == 0
    result, stack = [], []
    for tok in re.finditer(r'\(|\)|[^\s()]+', "".join(clean)):
        value = tok.group()
        if value == "(":
            form = Form(tok.start())
            (stack[-1].items if stack else result).append(form)
            stack.append(form)
        elif value == ")":
            assert stack, f"unmatched close at {tok.start()}"
            stack.pop().end = tok.end()
        elif stack:
            stack[-1].items.append(value)
    assert not stack
    return result


def operator(token):
    name = re.split(r'[:@?]', token)[0]
    # genmatch::parse_operation strips a trailing group digit for opN?.
    return name[:-1] if "?" in token and name[-1:].isdigit() else name


def matcher_inventory(raw, wanted):
    trees = forms(raw)
    definitions = {}
    predicates = set()
    all_forms = []

    def collect(form):
        all_forms.append(form)
        items = form.items
        if items and items[0] == "define_operator_list":
            definitions[items[1]] = items[2:]
        if items and items[0] == "match":
            name = items[1].items[0] if isinstance(items[1], Form) else items[1]
            predicates.add(operator(name))
        for item in items:
            if isinstance(item, Form):
                collect(item)

    for tree in trees:
        collect(tree)

    def resolve(name, env, seen=()):
        name = operator(name)
        assert name not in seen, (name, seen)
        if name in env:
            result = set()
            for value in env[name]:
                assert isinstance(value, str)
                result |= resolve(value, env, seen+(name,))
            return result
        return {name}

    def roots(pattern, env):
        assert isinstance(pattern, Form), "nonexpression simplify root"
        token = pattern.items[0]
        possible = resolve(token, env)
        # Optional outer expressions can expose their operand as a root.
        if "?" in token:
            assert len(pattern.items) == 2
            possible |= roots(pattern.items[1], env)
        return possible

    result = []
    count = 0

    def visit(form, env):
        nonlocal count
        items = form.items
        if not items:
            return
        if items[0] == "for":
            env = dict(env)
            pos = 1
            while (pos+1 < len(items) and isinstance(items[pos], str)
                   and isinstance(items[pos+1], Form)):
                # Resolve a list against the enclosing environment before
                # shadowing a same-named iterator.
                values = set()
                for value in items[pos+1].items:
                    assert isinstance(value, str)
                    values |= resolve(value, env)
                env[items[pos]] = sorted(values)
                pos += 2
        if items[0] == "simplify":
            count += 1
            pattern = items[1]
            possible = roots(pattern, env)
            assert not (possible & predicates), (form.start, possible & predicates)
            assert not any(p.startswith("@") for p in possible)
            if possible & wanted:
                result.append(dict(
                    line=raw.count("\n", 0, form.start)+1,
                    pattern=raw[pattern.start:pattern.end],
                    resolved_possible_root_operators=sorted(possible),
                    enclosing_conversion_aliases={k: v for k, v in env.items()
                        if "convert" in v},
                    source=raw[form.start:form.end]))
        for item in items:
            if isinstance(item, Form):
                visit(item, env)

    for tree in trees:
        visit(tree, definitions)
    return dict(simplify_forms_in_both_preprocessor_branches=count,
                root_forms=len(result),
                root_patterns=result)
