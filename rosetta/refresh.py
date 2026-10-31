#!/usr/bin/env python3
"""Download Rosetta Code task solutions and rebuild rosetta/ and rosetta.md."""

from __future__ import annotations

import argparse
import bisect
import collections
from datetime import datetime, timezone
import gzip
import html
import json
import os
from pathlib import Path
import re
import shutil
import sys
import tempfile
import time
import unicodedata
import urllib.parse
import urllib.request

API = "https://rosettacode.org/w/api.php"
SITE = "https://rosettacode.org/wiki/"
HEADERS = {"User-Agent": "silver-rosetta-refresh/1.0 (Silver task index)",
           "Accept-Encoding": "gzip"}
TASKS, DRAFTS, OMIT = "Programming_Tasks", "Draft_Programming_Tasks", "Ada/Omit"
LANGUAGES = ("Ada", "SPARK", "FreeBASIC", "Phix")
BACKUPS = ("FreeBASIC", "Phix")
CATEGORIES = (TASKS, DRAFTS, OMIT, *LANGUAGES)
STEMS = {"Ada": "ada", "SPARK": "spark", "FreeBASIC": "freebasic", "Phix": "phix"}
EXTENSIONS = {"ada": ".ada", "spark": ".ada", "freebasic": ".bas", "qbasic": ".bas",
              "basic": ".bas", "vbnet": ".bas", "vb": ".bas", "phix": ".exw", "euphoria": ".ex",
              "c": ".c", "cpp": ".cpp", "c++": ".cpp", "bash": ".sh", "sh": ".sh",
              "shell": ".sh", "make": ".mk", "makefile": ".mk", "xml": ".xml", "html": ".html",
              "html5": ".html", "asm": ".asm", "nasm": ".asm", "gpr": ".gpr",
              "python": ".py", "pascal": ".pas", "fortran": ".f90", "algol68": ".a68"}
NOT_CODE = {"", "text", "txt", "output", "bash", "sh", "shell", "console", "html", "html5", "xml"}
BATCH_BYTES = 5_000_000
LABELS = {"runtime-error": "run-time error", "exception-handling": "exception handling",
          "annotations": "annotations", "outside-spark": "outside SPARK", "unsafe": "unsafe operations",
          "console-output": "console output", "arguments": "arguments", "exit-status": "exit status",
          "stdin": "standard input", "files": "files", "directories": "directories", "clock": "clock",
          "delay": "delay", "entropy": "system randomness", "environment": "environment",
          "processes": "processes", "terminal": "terminal control", "gui": "GUI", "graphics": "graphics",
          "sound": "sound", "network": "network", "hardware": "hardware", "os-services": "OS services",
          "other": "other"}
GENERATED = re.compile(r"(0-9|[a-z])")
ROOT = Path(__file__).resolve().parent.parent

MASK = re.compile(r"<(syntaxhighlight|source|lang|pre|nowiki)\b[^>]*>.*?</\1\s*>|<!--.*?-->",
                  re.S | re.I)
HEADING = re.compile(r"^(={1,6})(.+?)\1[ \t]*(?:<!--.*?-->[ \t]*)*$", re.M)
HEADER = re.compile(r"\{\{\s*header\s*\|\s*([^}|]+?)\s*(?:\|[^}]*)?\}\}", re.I)
BLOCK = re.compile(r"<(syntaxhighlight|source|lang)\b([^>]*)>(.*?)</\1\s*>", re.S | re.I)
LANG_ATTRIBUTE = re.compile(r"""\blang\s*=\s*["']?([^"'\s>]+)""", re.I)
LIBHEADER = re.compile(r"\{\{\s*libheader\s*\|\s*([^}|]+?)\s*(?:\|[^}]*)?\}\}", re.I)
WORKS_WITH = re.compile(r"\{\{\s*works with\s*\|\s*([^}]+?)\s*\}\}", re.I)
LINK = re.compile(r"\{\{:([^}|]+)(?:\|[^}]*)?\}\}|\[\[([^\]|#]+)(?:#[^\]|]*)?(?:\|[^\]]*)?\]\]")
ADA_START = re.compile(r"^\s*(with|procedure|package|function)\b", re.M | re.I)
ADA_END = re.compile(r"^\s*end\b[^;\n]*;", re.M | re.I)


def pause() -> None:
    time.sleep(0.5)


def api(params: dict[str, str]) -> dict:
    query = urllib.parse.urlencode({"format": "json", "formatversion": "2", **params})
    request = urllib.request.Request(f"{API}?{query}", headers=HEADERS)
    for attempt in range(5):
        try:
            with urllib.request.urlopen(request, timeout=180) as response:
                body = response.read()
                if response.headers.get("Content-Encoding") == "gzip":
                    body = gzip.decompress(body)
                return json.loads(body)
        except (OSError, ValueError) as error:
            if attempt == 4:
                raise
            print(f"retrying after: {error}", file=sys.stderr, flush=True)
            time.sleep(10 * (attempt + 1))
    raise AssertionError("unreachable")


def members(category: str) -> list[str]:
    titles: list[str] = []
    resume: dict[str, str] = {}
    while True:
        data = api({"action": "query", "list": "categorymembers", "cmtitle": f"Category:{category}",
                    "cmnamespace": "0", "cmlimit": "500", **resume})
        titles += [member["title"] for member in data["query"]["categorymembers"]]
        if "continue" not in data:
            return titles
        resume = data["continue"]
        pause()


def page_info(titles: list[str]) -> dict[str, dict]:
    result = {}
    for start in range(0, len(titles), 50):
        data = api({"action": "query", "prop": "info", "titles": "|".join(titles[start:start + 50])})
        for page in data["query"]["pages"]:
            if not page.get("missing"):
                result[page["title"]] = {"revision": page["lastrevid"], "length": page["length"]}
        pause()
    return result


def store(data: dict, pages: Path, index: dict[str, dict]) -> None:
    for page in data["query"].get("pages", []):
        for revision in page.get("revisions", []):
            content = revision.get("slots", {}).get("main", {}).get("content")
            if content is not None:
                (pages / f"{revision['revid']}.wiki").write_text(content, encoding="utf-8")
                index[str(revision["revid"])] = {"title": page["title"],
                                                 "timestamp": revision["timestamp"]}


def download(info: dict[str, dict], cache: Path, index: dict[str, dict]) -> None:
    pages = cache / "pages"
    todo = [value for _, value in sorted(info.items())
            if not (pages / f"{value['revision']}.wiki").is_file()
            or str(value["revision"]) not in index]
    batches: list[list[str]] = []
    size = 0
    for value in todo:
        if not batches or len(batches[-1]) == 50 or size + value["length"] > BATCH_BYTES:
            batches.append([])
            size = 0
        batches[-1].append(str(value["revision"]))
        size += value["length"]
    print(f"downloading {len(todo)} pages in {len(batches)} requests", flush=True)
    for number, revisions in enumerate(batches, 1):
        params = {"action": "query", "prop": "revisions", "revids": "|".join(revisions),
                  "rvprop": "ids|timestamp|content", "rvslots": "main"}
        while True:
            data = api(params)
            store(data, pages, index)
            if "continue" not in data:
                break
            params = {**params, **data["continue"]}
            pause()
        write_json(cache / "pages.json", index)
        print(f"  {number}/{len(batches)}", flush=True)
        pause()


def fetch_subpages(titles: list[str], cache: Path, index: dict[str, dict]) -> dict:
    result: dict = {"pages": {}, "aliases": {}}
    for start in range(0, len(titles), 50):
        data = api({"action": "query", "prop": "revisions", "titles": "|".join(titles[start:start + 50]),
                    "redirects": "1", "rvprop": "ids|timestamp|content", "rvslots": "main"})
        query = data["query"]
        for alias in query.get("normalized", []) + query.get("redirects", []):
            result["aliases"][alias["from"]] = alias["to"]
        store(data, cache / "pages", index)
        for page in query.get("pages", []):
            for revision in page.get("revisions", []):
                result["pages"][page["title"]] = {"revision": revision["revid"],
                                                  "timestamp": revision["timestamp"]}
        pause()
    return result


def write_json(path: Path, value: object) -> None:
    path.write_text(json.dumps(value, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def slug(part: str) -> str:
    out = []
    for character in unicodedata.normalize("NFKD", part):
        if character.isascii() and character.isalnum():
            out.append(character.lower())
        elif character in "'’" or unicodedata.category(character) == "Mn":
            continue
        elif character.isalpha() and " LETTER " in unicodedata.name(character, ""):
            out.append(" " + unicodedata.name(character).split(" LETTER ")[1].split()[0].lower() + " ")
        else:
            out.append({"+": " plus ", "*": " star ", "&": " and "}.get(character, " "))
    return re.sub(r"\s+", "-", "".join(out).strip())


def group(title: str) -> str:
    return "0-9" if title[0].isdigit() else title[0].lower()


def task_path(title: str) -> str:
    return "/".join([group(title)] + [slug(part) for part in title.split("/")])


def normal(name: str) -> str:
    return name[:1].upper() + name[1:]


def headings(text: str) -> list[tuple[int, int, str]]:
    masked = [(match.start(), match.end()) for match in MASK.finditer(text)]
    starts = [start for start, _ in masked]

    def hidden(position: int) -> bool:
        i = bisect.bisect_right(starts, position) - 1
        return i >= 0 and position < masked[i][1]

    return [(match.start(), len(match.group(1)), match.group(2))
            for match in HEADING.finditer(text) if not hidden(match.start())]


def rendered(heading: str) -> str:
    text = HEADER.sub(lambda match: match.group(1), heading)
    text = re.sub(r"\{\{[^{}]*\}\}", "", text)
    text = re.sub(r"\[\[(?:[^|\]]*\|)?([^\]]*)\]\]", r"\1", text)
    text = re.sub(r"<[^>]+>", "", text)
    return " ".join(re.sub(r"'{2,}", "", text).split())


def sections(text: str) -> tuple[dict[str, list[tuple[int, int, str, str]]], str]:
    """Map each language to its heading spans and anchors; also return the task description."""
    found = headings(text)
    result: dict[str, list[tuple[int, int, str, str]]] = {}
    seen: set[str] = set()
    for i, (start, level, heading) in enumerate(found):
        anchor = rendered(heading).replace(" ", "_")
        if anchor.lower() in seen:
            suffix = 2
            while f"{anchor}_{suffix}".lower() in seen:
                suffix += 1
            anchor = f"{anchor}_{suffix}"
        seen.add(anchor.lower())
        names = [normal(name) for name in HEADER.findall(heading)]
        end = next((s for s, l, _ in found[i + 1:] if l <= level), len(text))
        for name in names:
            result.setdefault(name, []).append((start, end, heading.strip(), anchor))
    first = min((s for spans in result.values() for s, _, _, _ in spans), default=len(text))
    return result, text[:first]


def subpage_titles(section: str, title: str, language: str, aliases: dict[str, str]) -> list[str]:
    out: list[str] = []
    for transcluded, linked in LINK.findall(section):
        target = (transcluded or linked).strip()
        if target.startswith("/"):
            target = title + target
        if "/" in target and target.rsplit("/", 1)[-1].strip().casefold() == language.casefold():
            while target in aliases:
                target = aliases[target]
            if target not in out:
                out.append(target)
    return out


def code_blocks(section: str, language_of_section: str) -> list[tuple[str, str, str]]:
    blocks = []
    for tag, attributes, body in BLOCK.findall(section):
        if tag.lower() == "lang":
            language = attributes.split()[0] if attributes.split() else ""
        else:
            match = LANG_ATTRIBUTE.search(attributes)
            language = match.group(1) if match else ""
        if "<span" in body and 'style="color' in body:
            # Phix entries are often stored as pre-coloured HTML inside commented-out tags.
            body = re.sub(r"^\s*(\([^)]*\))?\s*-->", "", body)
            body = re.sub(r"<!--\s*$", "", body)
            body = html.unescape(re.sub(r"<[^>]+>", "", body))
            body = "\n".join(line[1:] if line.startswith(" ") else line for line in body.split("\n"))
        body = body.strip("\n")
        tagged = language.lower()
        if (language_of_section in ("Ada", "SPARK") and tagged not in {"ada", "spark"} | NOT_CODE
                and ADA_START.search(body) and ADA_END.search(body)):
            language = "ada"
        if body.strip():
            blocks.append((language.lower(), tagged, body.rstrip() + "\n"))
    return blocks


def gather(cache: Path, online: bool) -> tuple[dict, dict, dict, dict]:
    (cache / "pages").mkdir(parents=True, exist_ok=True)
    index = read_json(cache / "pages.json") if (cache / "pages.json").is_file() else {}
    if online:
        retrieved = datetime.now(timezone.utc).date().isoformat()
        categories = {}
        for name in CATEGORIES:
            categories[name] = members(name)
            print(f"{name}: {len(categories[name])} pages", flush=True)
        write_json(cache / "categories.json", {"retrieved": retrieved, "categories": categories})
        titles = sorted(set(categories[TASKS]) | set(categories[DRAFTS]))
        info = page_info(titles)
        write_json(cache / "info.json", info)
        download(info, cache, index)
    stored = read_json(cache / "categories.json")
    info = read_json(cache / "info.json")
    if online:
        wanted: list[str] = []
        for title, value in info.items():
            text = (cache / "pages" / f"{value['revision']}.wiki").read_text(encoding="utf-8")
            found, _ = sections(text)
            for name in choose(found):
                section = "".join(text[s:e] for s, e, _, _ in found[name])
                wanted += [t for t in subpage_titles(section, title, name, {}) if t not in wanted]
        write_json(cache / "subpages.json", fetch_subpages(wanted, cache, index))
        write_json(cache / "pages.json", index)
    elif not (cache / "subpages.json").is_file():
        raise SystemExit("the cache has no subpages.json; run once without --offline")
    return stored, info, read_json(cache / "subpages.json"), index


def choose(found: dict) -> list[str]:
    chosen = [name for name in ("Ada", "SPARK") if name in found]
    if "Ada" not in found:
        chosen += next(([name] for name in BACKUPS if name in found), [])
    return chosen


SURFACE_LABELS = {"integer-for-loops": "Integer range for loops",
                  "immutable-integers": "immutable Integer arithmetic",
                  "bounded-mutable-integers": "bounded mutable Integer objects",
                  "interval-integer-division": "interval-checked Integer division",
                  "fixed-integer-arrays": "fixed-size Integer arrays",
                  "constant-integer-array-iteration": "constant Integer-array iteration",
                  "named-integer-subtypes": "named Integer subtypes and bounded components",
                  "scalar-boolean-objects": "scalar Boolean objects and expressions",
                  "integer-object-size-read": "Integer object Size attribute reads",
                  "integer-image": "Integer image", "booleans": "Boolean objects",
                  "multidim-arrays": "multidimensional arrays",
                  "scalar-image": "'Image of scalars", "float-image": "floating-point images",
                  "stdin-lines": "standard input", "put": "Put without a newline",
                  "more-arguments": "further arguments"}
OUTLOOKS = {"likely": 0, "plausible": 1}
# An input construct drives its stage only through a sample that really uses the input it serves.
INPUT_EFFECTS = {"text-parsing": {"stdin", "files", "arguments"}, "stdin-lines": {"stdin"},
                 "file-input": {"files"}, "file-output": {"files"}, "exit-status": {"exit-status"},
                 "more-arguments": {"arguments"}}
FAILURE_PATHS = {
    "text-parsing": "text that is not a number, a value outside the declared range, and empty text",
    "stdin-lines": "end of input before the expected data, a line longer than the buffer, and bytes outside "
                   "the accepted set",
    "file-input": "a missing or unreadable file, content larger than the buffer, and a read error part way",
    "file-output": "a file that cannot be created, and a failed or partial write",
    "exit-status": "every failure outcome reaching its specified status, and success reaching success",
    "more-arguments": "too few or too many arguments, and an empty or invalid argument",
}
USES = {"stdin": "standard input", "files": "files", "arguments": "arguments", "exit-status": "exit status"}
# The question each construct's admission must answer: the decidable rule under which every program
# using it proves automatically.
ADMISSION = {
    "fixed-string-replacement": "Which argument forms and source bounds guarantee valid Low/High positions, a bounded result and complete automatic discharge for the selected Replace_Slice operation, with corresponding library verification and compilation?",
    "unicode-identifiers": "Which Unicode identifier repertoire and source encoding are admitted, and how do lexer identity, Ada case folding, byte limits and frontend source correspondence agree?",
    "scalar-guard-refinement": "Which comparisons refine scalar intervals on each branch, and how do assignments, joins and loops preserve soundness and automatic discharge?",
    "assignment-target-name": "How is @ resolved and bounded as the current assignment target, restricted to assignment right-hand sides and composed with existing scalar-expression rules without changing evaluation order?",
    "integer-object-size-read": "Which Integer object Size attribute reads are admitted, what range and staticness do their results have, and how do pinned-target representation correspondence and composition with Integer expressions preserve automatic discharge?",
    "integer-object-size-clause": "Which object Size clauses are guaranteed supported by the pinned targets, and how are legality, freezing, initialization and representation correspondence established without unsafe operations?",
    "static-integer-types": "Which static signed integer type ranges and object initializer forms are admitted, and how are nominal type identity, base-range versus first-subtype meaning, range checks and automatic discharge established?",
    "bounded-mutable-integers": "Which initialized Integer objects and static object-local ranges "
                                "keep every assignment within its declared range without scalar guard "
                                "or update refinement, including through branches and counted loops?",
    "immutable-integers": "Which immutable Integer declarations and fully grouped signed arithmetic expressions "
                          "have signed 32-bit interval bounds that discharge every check?",
    "integer-for-loops": "Which ascending, reverse and nested Integer range loops preserve scoped immutable "
                         "indexes, interval-safe bounds and automatic discharge throughout the body?",
    "integer-image": "How do standard Integer image lengths, including leading spaces and signs, compose "
                     "with bounded String expressions and every length check?",
    "integers": "Which integer types, literals and operators are admitted, and which range or guard rule makes "
                "every +, - and * provably free of overflow?",
    "interval-integer-division": "Which fully grouped Integer /, mod and rem expressions exclude zero from each nonempty divisor interval before empty propagation, reject minimum/-1 quotient overflow while permitting mod/rem, and how do operator-specific Ada-sign interval bounds, exact singleton initialization, shared operator budgets and complete producer/source-correspondence arguments establish automatic discharge without scalar guard or update refinement?",
    "integer-division": "What must precede every /, mod and rem so that division by zero and the overflow of "
                        "the most negative value divided by -1 are provably excluded?",
    "exponentiation": "Which base and exponent bounds make every ** provably free of overflow?",
    "modular-types": "Which modular types, bitwise operations and shifts are admitted, and how do conversions "
                     "between modular and signed types stay in range?",
    "named-integer-subtypes": "How do static direct-Integer subtype bounds, ordered name visibility, scalar initialization and assignment, and declared array component intervals establish range safety and automatic discharge through guards, nested loops and constant-array iteration?",
    "ranged-subtypes": "Which type and subtype declarations and conversions are admitted, and how is every "
                       "range check at assignment and conversion discharged?",
    "booleans": "Which Boolean objects, operators and Boolean-valued functions are admitted beyond today's "
                "conditions?",
    "scalar-boolean-objects": "How do initialized Boolean values, assignment, predefined-name visibility, eager operand safety, short-circuit path facts and conservative stored flags compose with all current checked predicates, arrays and loops while preserving automatic discharge and exact-source correspondence?",
    "characters": "Which Character values and attributes are admitted, and how is every 'Val range check "
                  "discharged?",
    "enumerations": "Which enumeration types and attributes are admitted, and how are 'Succ and 'Pred guarded "
                    "at the ends of the range?",
    "floating-point": "Which floating-point types, operations and elementary functions are admitted, and which "
                      "bounds make each one provably free of overflow and invalid arguments?",
    "fixed-point": "Which fixed-point and decimal types are admitted, and how are their overflow and "
                   "conversion checks discharged?",
    "fixed-integer-arrays": "How do explicit initialization, static nonempty bounds, interval-checked subscripts and component-preserving updates establish automatic discharge and source correspondence across existing declarations, guards and loops?",
    "constant-integer-array-iteration": "How do constant-component preservation, captured iterable identity, ordered forward/reverse enumeration, immutable nonstatic element binding, scoped hiding and loop flow establish automatic discharge and original-source correspondence across all admitted body statements?",
    "arrays": "Which array types, aggregates and index forms are admitted so that every index check proves "
              "without loop invariants?",
    "multidim-arrays": "Which multidimensional arrays and index expressions are admitted under the same index "
                       "rule as one-dimensional arrays?",
    "unconstrained-arrays": "Which unconstrained array parameters and slices are admitted, and how are slice "
                            "bounds and the length check of every assignment discharged?",
    "records": "Which record types, aggregates and component updates are admitted, and how does flow analysis "
               "see every component initialized?",
    "variant-records": "Which discriminants and variant parts are admitted, and how is every discriminant check "
                       "discharged?",
    "string-indexing": "Which String indexing and slicing forms are admitted, and how are their bounds proved "
                       "against the String's own range?",
    "string-building": "How does a bounded buffer grow so that every append proves within capacity, and what "
                       "specified outcome follows when it is full?",
    "string-ordering": "Are the predefined String ordering operators admitted unchanged?",
    "scalar-image": "How are 'Image results bounded, including their leading space, so that every "
                    "concatenation with them proves within capacity?",
    "float-image": "Which floating-point formatting is admitted, and how is the length of its text bounded?",
    "text-parsing": "Which conversions from text to numbers are admitted, and how do non-numeric or "
                    "out-of-range texts reach a specified outcome instead of an exception?",
    "case-statements": "Which case statement forms are admitted, given that the compiler already checks that "
                       "the choices cover every value?",
    "conditional-expressions": "Are if and case expressions admitted wherever the equivalent statements are, "
                               "under the same rules?",
    "membership-tests": "Which membership tests against ranges and choice lists are admitted in conditions?",
    "for-loops": "Which for-loop forms are admitted, and which checks inside them must discharge from the loop "
                 "index and local guards alone, without invariants?",
    "while-loops": "Which while and exit-when loops are admitted, only in procedures, and how is every check on "
                   "a loop-carried value guarded where it is used?",
    "block-statements": "Are declare blocks admitted with the same declaration rules as Main?",
    "local-exceptions": "Which locally handled explicit raises preserve definite initialization and path facts, "
                        "while every language-mandated check still proves and no exception crosses a call?",
    "procedures": "Which procedures and parameter modes are admitted, and is each body proved for every value "
                  "of its parameter types, with its own guards, or in the context of each call?",
    "functions": "Which functions are admitted, given that every loop and call inside a function must provably "
                 "terminate without a variant?",
    "recursive-procedures": "Which recursive procedures are admitted, and how is their depth bounded so that the "
                            "fixed stack premise covers it?",
    "recursive-functions": "Can any recursive function be admitted when its termination cannot be proved "
                           "without a variant?",
    "generics": "Which generic units and instances are admitted, and is each instance proved on its own?",
    "packages": "Which user packages, private types and elaboration forms are admitted in a program?",
    "tagged-types": "Which tagged types, dispatching calls and class-wide objects are admitted, and how are "
                    "their checks proved without class-wide contracts?",
    "access-types": "Which ownership pointers and allocations are admitted, and how do allocation failure and "
                    "leaks reach specified outcomes without exceptions?",
    "tasking": "Can the required Ravenscar or Jorvik profile come from the toolchain rather than program "
               "source? That is an Oracle decision.",
    "big-numbers": "Is a verified big-number library admitted, or fixed-capacity digit arrays in programs, and "
                   "how is exhausted capacity reported?",
    "put": "Is Put admitted with the same failure semantics as Put_Line?",
    "standard-error": "Which standard-error operations are admitted, and with what failure semantics?",
    "more-arguments": "How are the argument count and each argument validated, with specified outcomes for "
                      "missing, extra or invalid arguments?",
    "exit-status": "Which exit statuses may a program set, and how do they combine with Reject and with output "
                   "failure?",
    "stdin-lines": "How is input read into a bounded buffer, and how are end of input, overlong lines and "
                   "invalid bytes reported?",
    "file-input": "How are files opened and read, and how are missing files, read errors and oversized content "
                  "reported?",
    "file-output": "How are files created and written, and how are creation and write failures reported?",
}


def construct(name: str) -> str:
    return SURFACE_LABELS.get(name, name.replace("-", " "))


def listed(names: list[str]) -> str:
    return names[0] if len(names) == 1 else ", ".join(names[:-1]) + " and " + names[-1]


def reasons(assessed: dict, policy: dict) -> list[str]:
    """Return why a task is excluded from Silver under the policy; an empty list means it is a candidate."""
    found = [conflict["kind"] for conflict in assessed["conflicts"]]
    found += [effect["effect"] for effect in assessed["effects"]
              if effect["effect"] not in policy["allowed_effects"]]
    excluded = set(policy.get("excluded_features", [])) | set(policy.get("excluded_constructs", []))
    found += [name for name in assessed.get("features", []) + assessed.get("surface", []) if name in excluded]
    return list(dict.fromkeys(LABELS.get(item, construct(item)) for item in found))


def verdict(assessed: dict, why: list[str]) -> str:
    if why:
        return "excluded"
    if assessed.get("assessment_status") == "design-pending":
        return "design-pending"
    if "outlook" not in assessed:
        return "included"
    return assessed["outlook"]


def exercised(assessed: dict) -> list[str]:
    """Return the input constructs a sample uses together with the input they serve."""
    effects = {effect["effect"] for effect in assessed["effects"]}
    return [name for name in assessed["surface"] if name in INPUT_EFFECTS and INPUT_EFFECTS[name] & effects]


def progression(candidates: list[dict], supported: list[str]) -> list[tuple[dict, list[str]]]:
    """Order candidates so that the constructs most samples need are added first.

    Each step takes the sample whose constructs not yet supported are, on average, needed by the most
    remaining samples, then the one needing the fewest new constructs, preferring a likely outlook,
    then the shortest program. A step that adds an input construct is taken only by a sample that
    uses that input, when one exists. Samples that need nothing new are taken as soon as they become
    possible, those using the stage's input first.
    """
    names = sorted({name for task in candidates for name in task["assessed"]["surface"]} | set(supported))
    bit = {name: 1 << i for i, name in enumerate(names)}
    mask = lambda task: sum(bit[name] for name in set(task["assessed"]["surface"]))
    remaining = [(mask(task), task) for task in candidates]
    rank = lambda task: (OUTLOOKS[task["assessed"]["outlook"]], task["assessed"]["size"], task["title"].casefold())
    inputs = {name: bit[name] for name in INPUT_EFFECTS if name in bit}
    drives = lambda item: all(name in exercised(item[1]["assessed"])
                              for name, flag in inputs.items() if item[0] & flag)
    covered, order, stage_inputs = sum(bit[name] for name in set(supported)), [], set()
    while remaining:
        missing = [(needed & ~covered, task) for needed, task in remaining]
        free = [task for needed, task in missing if not needed]
        if free:
            pick, new = min(free, key=lambda t: (not stage_inputs & set(exercised(t["assessed"])), rank(t))), 0
        else:
            demand = {name: sum(1 for needed, _ in missing if needed & bit[name]) for name in names}
            average = lambda needed: sum(demand[n] for n in names if needed & bit[n]) / needed.bit_count()
            eligible = [item for item in missing if drives(item)] or missing
            new, pick = min(eligible, key=lambda item: (-average(item[0]), item[0].bit_count(), rank(item[1])))
            stage_inputs = {name for name, flag in inputs.items() if new & flag}
        order.append((pick, [name for name in names if new & bit[name]]))
        covered |= mask(pick)
        remaining = [(needed, task) for needed, task in remaining if task is not pick]
    return order


def assessment(task: dict, assessed: dict, policy: dict) -> str:
    silver = task["silver"]
    kind, why = silver["verdict"], silver["reasons"]
    heading = {"likely": "Candidate: proofs likely to discharge automatically",
               "plausible": "Candidate: proofs plausibly discharge automatically",
               "unlikely": "Unlikely to prove automatically" + (
                   ": " + ", ".join(silver["risks"]) if silver["risks"] else ""),
               "included": "Included in Silver",
               "design-pending": "Design pending: a faithful program has not been established",
               "excluded": "Excluded from Silver: " + ", ".join(why)}[kind]
    lines = [f"# {escape(task['title'])}", "", f"**{heading}.** {assessed['summary']}", ""]
    if "rank" in silver:
        up = "../" * len(task["path"].split("/"))
        added = (f", which adds {listed([construct(n) for n in silver['introduces']])}"
                 if silver["introduces"] else "")
        lines += [f"Position {silver['rank']} in the [progression]({up}progression.md#stage-{silver['stage']}), "
                  f"in stage {silver['stage']}{added}.", ""]
    paths = exercised(assessed) if "surface" in assessed else []
    if paths and kind in OUTLOOKS:
        lines += ["## Failure paths to test", ""]
        lines += [f"- **{construct(name)}**: {FAILURE_PATHS[name]}." for name in paths] + [""]
    if assessed.get("approach"):
        size = assessed.get("size")
        estimate = f" About {size} line{'s' * (size != 1)}." if size is not None else ""
        lines += ["## Approach", "",
                  assessed['approach'] + estimate, ""]
    if assessed.get("risks"):
        lines += ["## Proof obligations to watch", ""]
        lines += [f"- **{r['obligation'].replace('-', ' ')}**: {r['explanation']}" for r in assessed["risks"]] + [""]
    surface = assessed.get("surface", assessed.get("features", []))
    if surface:
        text = listed([construct(name) for name in surface])
        lines += ["## Language surface recorded by this assessment", "", text[:1].upper() + text[1:] + ".", ""]
    if assessed["conflicts"]:
        lines += ["## Oracle conflicts", ""]
        lines += [f"- **{LABELS[c['kind']]}**: {c['explanation']}" for c in assessed["conflicts"]] + [""]
    if assessed["effects"]:
        lines += ["## External effects", ""]
        for effect in assessed["effects"]:
            allowed = "allowed" if effect["effect"] in policy["allowed_effects"] else "not allowed"
            lines.append(f"- **{LABELS[effect['effect']]}** ({allowed}): {effect['explanation']}")
        lines.append("")
    how = f"{assessed['model']} at {assessed['effort']} effort"
    if assessed.get("escalated_from"):
        how += f", escalated from {assessed['escalated_from']}"
    attribution = "Initially assessed" if assessed.get("review") else "Assessed"
    lines += [f"{attribution} on {assessed['assessed']} against page revision {assessed['revision']} of the "
              f"[task]({task['url']}) by {how}; "
              + ("current " if assessed.get("review") else "")
              + f"confidence {assessed['confidence']}. The inclusion policy "
              "is in `rosetta/coverage.json`."]
    if review := assessed.get("review"):
        up = "../" * len(task["path"].split("/"))
        lines += ["", f"Revised on {review['date']} by Codex through targeted source review; "
                  f"see the [review record]({up}{review['record']})."]
    if silver["stale"]:
        lines += ["", f"The page has changed since (now revision {task['revision']}); reassess it."]
    return "\n".join(lines) + "\n"


def build(cache: Path, stored: dict, info: dict, subpages: dict, index: dict[str, dict],
          output: Path) -> tuple[list[dict], dict]:
    categories = {name: set(titles) for name, titles in stored["categories"].items()}
    tasks, drafts = categories[TASKS], categories[DRAFTS]
    if output.exists():
        for entry in output.iterdir():
            if entry.is_dir() and GENERATED.fullmatch(entry.name):
                shutil.rmtree(entry)
        (output / "manifest.json").unlink(missing_ok=True)
    output.mkdir(parents=True, exist_ok=True)
    paths: dict[str, str] = {}
    manifest, report = [], {"category_without_heading": [], "heading_without_category": [],
                            "no_solution": []}
    for title in sorted(tasks | drafts, key=lambda t: (t.casefold(), t)):
        if title not in info:
            print(f"warning: no revision for {title}", file=sys.stderr)
            continue
        revision = info[title]["revision"]
        text = (cache / "pages" / f"{revision}.wiki").read_text(encoding="utf-8")
        found, preamble = sections(text)
        for name in LANGUAGES:
            if (title in categories[name]) != (name in found):
                key = "category_without_heading" if title in categories[name] else "heading_without_category"
                report[key].append([title, name])
        chosen = choose(found)
        if not chosen:
            report["no_solution"].append(title)
        path = task_path(title)
        if path in paths.values():
            raise SystemExit(f"directory name collision for {title!r}: {path}")
        paths[title] = path
        directory = output / path
        directory.mkdir(parents=True, exist_ok=True)
        (directory / "task.wiki").write_text(preamble.strip() + "\n", encoding="utf-8")
        solutions, written = [], {}
        for name in chosen:
            spans = found[name]
            key = tuple((s, e) for s, e, _, _ in spans)
            entry: dict = {"language": name, "headings": [h for _, _, h, _ in spans]}
            if key in written:
                entry["same_section_as"] = written[key]
                solutions.append(entry)
                continue
            written[key] = name
            section = "\n\n".join(text[s:e].strip("\n") for s, e, _, _ in spans) + "\n"
            stem = STEMS[name]
            (directory / f"{stem}.wiki").write_text(section, encoding="utf-8")
            blocks = code_blocks(section, name)
            pages = []
            for k, page_title in enumerate(subpage_titles(section, title, name, subpages["aliases"]), 1):
                if page_title not in subpages["pages"]:
                    print(f"warning: subpage {page_title!r} of {title!r} is missing", file=sys.stderr)
                    continue
                page = subpages["pages"][page_title]
                page_text = (cache / "pages" / f"{page['revision']}.wiki").read_text(encoding="utf-8")
                page_file = f"{stem}-page.wiki" if k == 1 else f"{stem}-page-{k}.wiki"
                (directory / page_file).write_text(page_text.strip("\n") + "\n", encoding="utf-8")
                pages.append({"title": page_title, "revision": page["revision"],
                              "timestamp": page["timestamp"], "wiki": page_file})
                blocks += code_blocks(page_text, name)
            files = []
            for number, (language, tagged, body) in enumerate(blocks, 1):
                file_name = f"{stem}-{number}{EXTENSIONS.get(language, '.txt')}"
                (directory / file_name).write_text(body, encoding="utf-8")
                item = {"file": file_name, "block_language": tagged or None}
                if tagged != language:
                    item["treated_as"] = language
                files.append(item)
            entry.update({"wiki": f"{stem}.wiki", "code": files, **({"subpages": pages} if pages else {}),
                          "libraries": sorted(set(LIBHEADER.findall(section))),
                          "works_with": sorted({w.strip() for w in WORKS_WITH.findall(section)})})
            solutions.append(entry)
        manifest.append({"title": title, "status": "task" if title in tasks else "draft", "path": path,
                         "url": url(title), "revision": revision,
                         "timestamp": index[str(revision)]["timestamp"],
                         "omitted_from_ada": title in categories[OMIT], "solutions": solutions,
                         "anchors": {name: found[name][0][3] for name in ("Ada", "SPARK") if name in found}})
    write_manifest(output, stored["retrieved"], manifest)
    return manifest, report


def write_manifest(output: Path, retrieved: str, manifest: list[dict]) -> None:
    published = [{key: value for key, value in task.items() if key != "silver"} for task in manifest]
    write_json(output / "manifest.json", {
        "schema_version": 1, "source": "https://rosettacode.org", "retrieved": retrieved,
        "license": "GNU Free Documentation License 1.3",
        "selection": "Ada, plus SPARK where present; otherwise FreeBASIC; otherwise Phix",
        "tasks": published})


def apply_coverage(manifest: list[dict], output: Path) -> None:
    """Note each assessed task's verdict and order, then write its silver.md and the progression."""
    coverage = read_json(output / "coverage.json") if (output / "coverage.json").is_file() else None
    supported = coverage.get("supported", []) if coverage else []
    unknown = [name for name in supported if name not in ADMISSION]
    if unknown:
        raise SystemExit(f"coverage.json lists unknown supported constructs: {unknown}")
    candidates = []
    for task in manifest:
        task.pop("silver", None)
        assessed = coverage["tasks"].get(task["title"]) if coverage else None
        if not assessed:
            (output / task["path"] / "silver.md").unlink(missing_ok=True)
            continue
        why = reasons(assessed, coverage["policy"])
        kind = verdict(assessed, why)
        risks = [r["obligation"].replace("-", " ") for r in assessed.get("risks", [])] if kind == "unlikely" else []
        task["silver"] = {"verdict": kind, "reasons": why, "risks": list(dict.fromkeys(risks)),
                          "stale": assessed["revision"] != task["revision"]}
        if kind in OUTLOOKS:
            candidates.append({"title": task["title"], "task": task, "assessed": assessed})
    order = progression(candidates, supported)
    stage = 0
    for position, (item, new) in enumerate(order, 1):
        stage += bool(new) or position == 1
        item["task"]["silver"].update({"rank": position, "stage": stage, "introduces": new})
    for task in manifest:
        if "silver" in task:
            (output / task["path"] / "silver.md").write_text(
                assessment(task, coverage["tasks"][task["title"]], coverage["policy"]), encoding="utf-8")
    page = output / "progression.md"
    if order:
        page.write_text(progression_page(manifest, order, supported), encoding="utf-8")
    else:
        page.unlink(missing_ok=True)


def progression_page(manifest: list[dict], order: list[tuple[dict, list[str]]], supported: list[str]) -> str:
    verdicts = [task["silver"]["verdict"] for task in manifest if "silver" in task]
    stages: list[tuple[list[str], list[dict]]] = []
    for item, new in order:
        if new or not stages:
            stages.append((new, []))
        stages[-1][1].append(item)
    extra = listed([construct(name) for name in supported]) if supported else ""
    baseline = f"today's Silver and the supported constructs ({extra})" if supported else "today's Silver"
    start = ("today's language" if not supported else
             f"today's language, plus the constructs `coverage.json` lists as supported ({extra}),")
    lines = ["# Silver progression", "",
             f"The order in which Silver could grow from {start} to support each Rosetta Code candidate,",
             "generated by `refresh.py` from `coverage.json`. Each stage adds the constructs it lists and",
             "supports the samples under it. A step takes the sample whose new constructs the most",
             "remaining samples need, on average, then the one needing the fewest new constructs,",
             "preferring proofs likely to discharge, then the shortest program. Samples that need nothing",
             "new follow as soon as they become possible, shortest first.", "",
             "A stage that adds an input construct (text parsing, standard input, files, exit status or",
             "further arguments) is driven by a sample that really uses that input. Such samples come",
             "first in their stage and are the stage's tests of the failure paths it lists.", "",
             "Each stage states the admission question for every construct it adds: the decidable rule",
             "under which every program using the construct proves automatically. The obligations the",
             "assessments flag, and how many samples are only plausible, show where that rule must be",
             "most restrictive.", "",
             f"{len(order):,} candidates in {len(stages):,} stages; {verdicts.count('unlikely'):,} samples are "
             f"unlikely to prove automatically and {verdicts.count('excluded'):,} are excluded."]
    pending = [task for task in manifest if task.get("silver", {}).get("verdict") == "design-pending"]
    if pending:
        lines += ["", f"{len(pending):,} assessment(s) await a faithful program design and have no stage."]
    position = 0
    for number, (new, items) in enumerate(stages, 1):
        lines += ["", f"## Stage {number}", ""]
        if new:
            lines += [f"Adds {listed([construct(name) for name in new])}.", "", "Admission questions:", ""]
            lines += [f"- **{construct(name)}**: {ADMISSION[name]}" for name in new] + [""]
            paths = [name for name in new if name in INPUT_EFFECTS]
            if paths:
                lines += ["Failure paths to test, with the samples that use the input:", ""]
                lines += [f"- **{construct(name)}**: {FAILURE_PATHS[name]}." for name in paths] + [""]
        else:
            lines += [f"Needs nothing beyond {baseline}.", ""]
        flagged = collections.Counter(obligation for item in items
                                      for obligation in dict.fromkeys(
                                          r["obligation"] for r in item["assessed"]["risks"]))
        plausible = sum(item["assessed"]["outlook"] == "plausible" for item in items)
        notes = []
        if flagged:
            notes.append("The assessments flag " + listed([f"{name.replace('-', ' ')} in {count}"
                                                            for name, count in sorted(
                                                                flagged.items(), key=lambda pair: (-pair[1], pair[0]))[:4]])
                         + f" of its {len(items)} sample{'s' * (len(items) != 1)}.")
        if plausible:
            notes.append(f"{plausible} of {len(items)} {'are' if plausible != 1 else 'is'} only plausible"
                         + ("; this stage needs the most restrictive admitted forms."
                            if plausible * 2 >= len(items) else "."))
        if notes:
            lines += [" ".join(notes), ""]
        for item in items:
            position += 1
            task, assessed = item["task"], item["assessed"]
            used = [USES[effect] for effect in USES if effect in {e["effect"] for e in assessed["effects"]}]
            lines.append(f"{position}. [{escape(task['title'])}]({task['path']}/silver.md): "
                         f"{assessed['outlook']}, about {assessed['size']} line{'s' * (assessed['size'] != 1)}"
                         + (f"; uses {listed(used)}" if used else ""))
    unlikely = [task for task in manifest if task.get("silver", {}).get("verdict") == "unlikely"]
    if unlikely:
        lines += ["", "## Unlikely to prove automatically", ""]
        lines += [f"- [{escape(task['title'])}]({task['path']}/silver.md): "
                  + (", ".join(task["silver"]["risks"]) or "see the assessment") for task in unlikely]
    if pending:
        lines += ["", "## Design pending", "",
                  "These assessments establish neither a required language surface nor an Oracle conflict.", ""]
        lines += [f"- [{escape(task['title'])}]({task['path']}/silver.md)" for task in pending]
    return "\n".join(lines) + "\n"


def url(title: str, anchor: str = "") -> str:
    path = urllib.parse.quote(title.replace(" ", "_"), safe="/:,!'.")
    return SITE + path + ("#" + urllib.parse.quote(anchor, safe="_.:-/") if anchor else "")


def escape(title: str) -> str:
    return "".join("\\" + c if c in "\\`*_[]<>|~$" else c for c in title)


def row(*cells: str) -> str:
    return "|" + "|".join(f" {cell} " if cell else " " for cell in cells) + "|"


def render(manifest: list[dict], retrieved: str, output: Path, listing: Path) -> None:
    local = Path(os.path.relpath(output, listing.parent)).as_posix()
    tasks = [t for t in manifest if t["status"] == "task"]
    drafts = [t for t in manifest if t["status"] == "draft"]
    has = lambda task, name: name in task["anchors"]
    count = lambda items, name: f"{sum(has(t, name) for t in items):,}"
    omitted = [t for t in manifest if t["omitted_from_ada"]]
    both = [t for t in omitted if has(t, "Ada")]
    if both:
        names = ", ".join(f"[{escape(t['title'])}]({t['url']})" for t in both)
        verb = "has an Ada solution" if len(both) == 1 else "have Ada solutions"
        rest = (f"The Ada column says\n\"omitted\" for {len(omitted) - len(both)} of them. "
                f"{'The other' if len(both) == 1 else 'The others'},\n{names},\n{verb} anyway.")
    else:
        rest = "The Ada column says \"omitted\" for them."
    category = lambda name: f"[{name.replace('_', ' ')}]({url('Category:' + name)})"
    groups: list[tuple[str, list[dict]]] = []
    for task in manifest:
        name = group(task["title"]).upper() if group(task["title"]) != "0-9" else "0-9"
        if not groups or groups[-1][0] != name:
            groups.append((name, []))
        groups[-1][1].append(task)
    assessed = any("silver" in t for t in manifest)
    kinds = [kind for kind in ("likely", "plausible", "included", "unlikely", "excluded", "design-pending")
             if any(t.get("silver", {}).get("verdict") == kind for t in manifest)]
    titles = {"likely": "Likely", "plausible": "Plausible", "included": "Included (earlier rubric)",
              "unlikely": "Unlikely", "excluded": "Excluded", "design-pending": "Design pending"}
    tally = lambda items, kind: f"{sum(t.get('silver', {}).get('verdict') == kind for t in items):,}"
    if any(kind in OUTLOOKS for kind in kinds):
        silver_note = f"""
The Silver column gives each task's verdict for Silver as the [Oracle](oracle.md)
envisions it and links to its assessment. A candidate shows its position in the
[progression]({local}/progression.md), the order in which Silver could grow to
support it, and whether its proofs would likely or plausibly discharge
automatically. Other tasks are unlikely to prove automatically or are excluded,
with the reasons. Design-pending tasks have no stage until a faithful program
is established. The assessments and the inclusion policy are in
[{local}/coverage.json]({local}/coverage.json).
"""
    elif assessed:
        silver_note = f"""
The Silver column gives each task's verdict for Silver as the [Oracle](oracle.md)
envisions it and links to its assessment, with the reasons when a task is
excluded. The assessments and the inclusion policy are in
[{local}/coverage.json]({local}/coverage.json).
"""
    else:
        silver_note = ""
    header = "| Status | Tasks | With an Ada solution | With a SPARK solution |"
    rule = "| --- | ---: | ---: | ---: |"
    totals = [(name, items) for name, items in (("Task", tasks), ("Draft", drafts), ("Total", manifest))]
    header += "".join(f" {titles[kind]} |" for kind in kinds)
    rule += " ---: |" * len(kinds)
    table = [header, rule] + [
        f"| {name} | {len(items):,} | {count(items, 'Ada')} | {count(items, 'SPARK')} |"
        + "".join(f" {tally(items, kind)} |" for kind in kinds) for name, items in totals]
    lines = f"""# Rosetta Code tasks

Every task and draft task on [Rosetta Code](https://rosettacode.org), listed
from its MediaWiki API on {retrieved}. Each name links to the task page. The Ada
and SPARK columns link to the solution in that language when the page has one.
The Local column links to the downloaded copy in [{local}/]({local}/README.md): Ada
where the page has it, otherwise FreeBASIC or Phix.
{silver_note}
{chr(10).join(table)}

Rosetta Code marks {len(omitted)} tasks as omitted from Ada. {rest}

The task lists come from the categories
{category(TASKS)} and
{category(DRAFTS)}.
The solution columns come from each page's language headings at the revision
recorded in [{local}/manifest.json]({local}/manifest.json). To refresh this list
and the local copy, run `python3 {local}/refresh.py`.

Rosetta Code content, including solution code, is available under the GNU Free
Documentation License 1.3.

""".splitlines()
    lines.append(" · ".join(f"[{name}](#{name.lower()})" for name, _ in groups))
    for name, items in groups:
        columns = ["Task", "Status", "Ada", "SPARK", "Local"] + (["Silver"] if assessed else [])
        lines += ["", f"## {name}", "", row(*columns), row(*["---"] * len(columns))]
        for task in items:
            title = task["title"]
            ada = (f"[yes]({url(title, task['anchors']['Ada'])})" if has(task, "Ada")
                   else "omitted" if task["omitted_from_ada"] else "")
            spark = f"[yes]({url(title, task['anchors']['SPARK'])})" if has(task, "SPARK") else ""
            languages = ", ".join(s["language"] for s in task["solutions"])
            copy = f"[{languages}]({local}/{task['path']}/)" if languages else ""
            cells = [f"[{escape(title)}]({task['url']})", task["status"].capitalize(), ada, spark, copy]
            if assessed:
                verdict = ""
                if "silver" in task:
                    silver = task["silver"]
                    link = f"{local}/{task['path']}/silver.md"
                    verdict = {"likely": f"[stage {silver.get('stage')}, #{silver.get('rank')} likely]({link})",
                               "plausible": f"[stage {silver.get('stage')}, #{silver.get('rank')} plausible]({link})",
                               "included": f"[included]({link})",
                               "design-pending": f"[design pending]({link})",
                               "unlikely": f"[unlikely]({link})" + (
                                   ": " + ", ".join(silver["risks"]) if silver["risks"] else ""),
                               "excluded": f"[excluded]({link}): {', '.join(silver['reasons'])}"}[silver["verdict"]]
                    if silver["stale"]:
                        verdict += " (stale)"
                cells.append(verdict)
            lines.append(row(*cells))
    listing.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main(arguments: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cache", type=Path,
                        help="keep downloaded pages here between runs (default: a temporary directory)")
    parser.add_argument("--offline", action="store_true",
                        help="rebuild from --cache without contacting Rosetta Code")
    parser.add_argument("--output", type=Path, default=ROOT / "rosetta",
                        help="task directory tree to rebuild (default: rosetta/)")
    parser.add_argument("--list", type=Path, default=ROOT / "rosetta.md", dest="listing",
                        help="task list to rewrite (default: rosetta.md)")
    parser.add_argument("--render", action="store_true",
                        help="only rewrite the task list and silver.md files from the existing tree, "
                             "for example after changing coverage.json")
    args = parser.parse_args(arguments)
    if sys.version_info < (3, 11):
        parser.error("Python 3.11 or newer is required")
    if args.offline and args.cache is None:
        parser.error("--offline needs --cache")
    output = args.output.resolve()
    if args.render:
        published = read_json(output / "manifest.json")
        manifest, report, retrieved = published["tasks"], {}, published["retrieved"]
        if any("anchors" not in task for task in manifest):
            raise SystemExit("manifest.json predates --render; run refresh.py once without --render")
    else:
        with tempfile.TemporaryDirectory(prefix="rosetta-") as temporary:
            cache = (args.cache or Path(temporary)).resolve()
            stored, info, subpages, index = gather(cache, online=not args.offline)
            manifest, report = build(cache, stored, info, subpages, index, output)
            retrieved = stored["retrieved"]
    apply_coverage(manifest, output)
    render(manifest, retrieved, output, args.listing.resolve())
    counts: dict[str, int] = {}
    for task in manifest:
        for solution in task["solutions"]:
            counts[solution["language"]] = counts.get(solution["language"], 0) + 1
    print(f"{len(manifest)} tasks; solutions: {counts}")
    for key, items in report.items():
        if items:
            print(f"warning: {key}: {items}", file=sys.stderr)


if __name__ == "__main__":
    main()
