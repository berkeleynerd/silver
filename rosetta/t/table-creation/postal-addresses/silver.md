# Table creation/Postal addresses

**Excluded from Silver: other.** This task can be included. A Silver program could define the address schema with bounded types: an integer ID, bounded strings for street and city, a two-letter state code and a constrained ZIP code. It would create the table through an admitted database-library operation and report a visible outcome if that operation fails. Nothing breaks an Oracle rule; the only gap is that Silver has no database effect yet.

## Language surface recorded by this assessment

Records, string operations, integers and packages.

## External effects

- **other** (not allowed): For a non-database language, the task asks the program to open a connection to a database of its choice and create an address table in it. That needs an admitted database library operation, such as an embedded file-backed store, with specified failure outcomes.
- **files** (allowed): An embedded database such as SQLite keeps the table in a named database file. The connection opens or creates that file.
- **console output** (allowed): The program reports whether the table was created or the database operation failed.

Assessed on 2026-10-15 against page revision 410862 of the [task](https://rosettacode.org/wiki/Table_creation/Postal_addresses) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
