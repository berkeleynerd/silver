# Object serialization

**Candidate: proofs likely to discharge automatically.** Every check is a byte-to-field range check guarded just before use, a for-loop index, or a static bound, and tagged types with dispatching procedures are supported by SPARK without annotations. Serialization uses hand-written byte encoding because SPARK has no stream attributes, and nothing else needs an annotation.

Position 1561 in the [progression](../../progression.md#stage-35), in stage 35.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

A package declares a tagged root record (Message, with an Id field in a declared range) and two derived types (Sensor_Message and Control_Message), each extending it with integer fields and overriding a primitive Print, plus a class-wide Display that dispatches; Main builds one instance of each from embedded data and displays them. Each object is serialized to objects.dat as a kind byte followed by its fields split into bytes with / and mod, and a record count is written first. The file is read back with a for loop over that count, where at most 3 are accepted; each record's kind byte selects which concrete object to rebuild, and the program rejects an unknown kind, an out-of-range field or an I/O failure with a visible message. About 130 lines.

## Proof obligations to watch

- **range**: Rebuilding ranged integer fields from bytes read back from the file is guarded by an explicit comparison against the field's range, and a malformed record is rejected with a visible message.
- **other**: Flow analysis of dispatching Print calls needs every overriding Print to touch the same globals (the output state) as the root's Print, which holds because they all write only through Silver_IO.
- **other**: SPARK excludes stream attributes such as 'Class'Output and 'Class'Input, so serialization must be written by hand as a kind byte plus field bytes through an admitted binary file library whose failure outcomes are specified.

## Language surface beyond today's Silver

Integers, ranged subtypes, integer division, modular types, arrays, records, tagged types, packages, procedures, 'Image of scalars, for loops, file output and file input.

## External effects

- **console output** (allowed): Each object's print procedure writes its contents to standard output, before writing and after reading back.
- **files** (allowed): The objects are written in binary form to objects.dat, which is then reopened and read back, with open, write or read failure and malformed content each giving a specified outcome.

Assessed on 2026-10-15 against page revision 413203 of the [task](https://rosettacode.org/wiki/Object_serialization) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
