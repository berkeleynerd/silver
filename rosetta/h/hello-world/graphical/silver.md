# Hello world/Graphical

**Excluded from Silver: GUI.** The task requires showing "Goodbye, World!" on a GUI object, which needs a windowed widget. Silver has no GUI effect, so this is reported as an effect rather than a conflict. The task names no mandatory run-time errors, annotations, or unsafe constructs, and a GUI-free program would not meet the stated requirement. Its features reduce to a single string constant and one output call, which are already in Silver's fragment, so no extra SPARK features are needed.

## External effects

- **GUI** (not allowed): The task explicitly requires displaying the string on a GUI object (alert box, plain window, text area, etc.), so a windowed widget is needed. Silver has no GUI effect today, but this is an effect, not a conflict.

Assessed on 2026-10-15 against page revision 407802 of the [task](https://rosettacode.org/wiki/Hello_world/Graphical) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
