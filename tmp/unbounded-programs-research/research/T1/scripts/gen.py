#!/usr/bin/env python3
"""Generate admitted-shape Silver probe programs of a requested size/shape."""
import itertools, string, sys

HEAD = "with Silver_IO;\nprocedure Main is\npragma SPARK_Mode (On);\n"
ARG_HEAD = ("with Silver_IO;with Silver_Arguments;\nprocedure Main is\npragma SPARK_Mode (On);\n"
            "D:constant String:=Silver_Arguments.First_Or_Default(\"\");\n")
TAIL = "end Main;\n"

def names():
    letters = string.ascii_uppercase
    for n in itertools.count(1):
        for combo in itertools.product(letters, repeat=n):
            s = ''.join(combo)
            if s.lower() in RESERVED: continue
            yield s
RESERVED = set("""abort abs abstract accept access aliased all and array at begin body case constant declare delay delta digits do else elsif end entry exception exit for function generic goto if in interface is limited loop mod new not null of or others out overriding package parallel pragma private procedure protected raise range record rem renames requeue return reverse select separate some subtype synchronized tagged task terminate then type until use when while with xor string integer main""".split())

def nested_loops(depth):
    body = "".join("for I in 1..1 loop\n" for _ in range(depth)) + "null;\n" + "end loop;\n" * depth
    return HEAD + "begin\n" + body + TAIL

def string_decls(n, body_refs=0):
    g = names(); ns = [next(g) for _ in range(n)]
    decls = "".join(f'{x}:String:="";\n' for x in ns)
    last = ns[-1]
    body = "".join(f"{last}:={last};\n" for _ in range(body_refs)) or "null;\n"
    return HEAD + decls + "begin\n" + body + TAIL

def scalar_decls(n, body_refs=0):
    g = names(); ns = [next(g) for _ in range(n)]
    decls = "".join(f'{x}:Integer:=0;\n' for x in ns)
    first = ns[0]
    body = "".join(f"{first}:={first};\n" for _ in range(body_refs)) or "null;\n"
    return HEAD + decls + "begin\n" + body + TAIL

def cond_parens(depth):
    return HEAD + "begin\nif " + "(" * depth + "1=1" + ")" * depth + " then null; end if;\n" + TAIL

def scalar_parens(depth):
    return HEAD + "A:Integer:=" + "(" * depth + "1" + ")" * depth + ";\nbegin\nnull;\n" + TAIL

def string_parens(depth):
    return HEAD + "begin\nSilver_IO.Put_Line(" + "(" * depth + '""' + ")" * depth + ");\n" + TAIL

def nested_ifs(depth):
    return HEAD + "begin\n" + "if 1=1 then\n" * depth + "null;\n" + "end if;\n" * depth + TAIL

def pad(text, size):
    # pad with a trailing comment to exactly size bytes (if possible)
    if len(text) > size: raise SystemExit(f"too long: {len(text)} > {size}")
    if len(text) == size: return text
    extra = size - len(text)
    if extra < 3: return text + " " * extra
    return text + "--" + "x" * (extra - 3) + "\n"

if __name__ == '__main__':
    kind, arg = sys.argv[1], int(sys.argv[2])
    extra = int(sys.argv[3]) if len(sys.argv) > 3 else 0
    f = globals()[kind]
    text = f(arg, extra) if kind in ('string_decls', 'scalar_decls') else f(arg)
    sys.stdout.write(text)
