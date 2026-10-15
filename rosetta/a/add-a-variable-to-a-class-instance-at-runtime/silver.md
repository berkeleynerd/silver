# Add a variable to a class instance at runtime

**Excluded from Silver: outside SPARK.** Excluded: the task needs members added to an existing class instance at run time (monkeypatching), and Ada/SPARK's static types cannot do that. The existing Ada solution also only imitates it, with a statically declared type extension that delegates to the original object through an access discriminant.

## Language surface beyond today's Silver

Records, tagged types and string operations.

## Oracle conflicts

- **outside SPARK**: The task asks to add new member variables to an existing object while the program runs, with the names possibly coming from data only known at run time (monkeypatching or metaprogramming). Ada/SPARK types are fixed at compile time. A record extension declared in a nested block is still a static type, not a change to the instance, and storing names and values in a bounded map would only imitate the feature rather than add a variable to the object. Doing this faithfully needs dynamic typing or metaprogramming, which SPARK cannot express.

## External effects

- **console output** (allowed): The program prints the object's members, including the added one, to show the result.

Assessed on 2026-10-15 against page revision 408077 of the [task](https://rosettacode.org/wiki/Add_a_variable_to_a_class_instance_at_runtime) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
