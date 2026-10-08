The following constructs are imprecisely supported in proof. They can be used safely but might lead to unexpected behavior. Warnings for these constructs can  be enabled individually using the ``-W`` switch and the tag between parentheses, or collectively using the ``--info`` switch.

* Explicit and implicit postconditions of a recursive subprogram cannot be used on (mutually) recursive calls occurring inside assertions and contracts, but will still be available in regular code (contracts-recursive),

* The Default_Initial_Condition of a type won't be assumed on subcomponents initialized by default inside assertions and contracts, but will still be available in regular code (dic-ignored),

* The adress of objects is not precisely known if it is not supplied through an address clause (imprecise-address),

* The alignment of an object might not be known for proof if it is not supplied through an attribute definition clause (imprecise-align),

* The behavior of a call might not be known by SPARK and handled in an imprecise way; its precondition might be impossible to prove and nothing will be known about its result (imprecise-call),

* the value of attribute Component_Size might not be known for proof if it is not supplied through an attribute definition clause (imprecise-component-size),

* the value of attributes First_Bit, Last_Bit, and Position on record components are handled in an imprecise way if the record does not have a record representation clause (imprecise-record-component-attribute),

* The attributes Size, Object_Size or Value_Size might not be handled precisely, nothing will be known about their evaluation (imprecise-size),

* Overlay might not be handled precisely by SPARK, the value of other overlaid objects will be unknown after an object is updated (imprecise-overlay),

* Unchecked conversion might not be handled precisely by SPARK, nothing will be known about their result (imprecise-unchecked-conversion),

* References to the attribute Value are handled in an imprecise way; its precondition is impossible to prove and nothing will be known about the evaluation of the attribute reference (imprecise-value),

* References to the attributes Image and Img are handled in an imprecise way; nothing will be known about the evaluation of the attribute reference apart from a bound on its length (imprecise-image),

* The initial value of constants declared before the loop invariant is not visible after the invariant; it shall be restated in the invariant if necessary (constants-in-loops),

* No reclamation function or reclaimed value was found for an ownership type, which may make it impossible to prove that values of this type are reclaimed (no-reclamation-function),

* For recursive expression functions with a numeric (not structural) Subprogram_Variant, the definition of the expression function might not be available for recursive calls occurring inside assertions and contracts, but will still be available in regular code (numeric-variant),

* The tool enforces that mutable discriminants of standalone objects and parameters with relaxed initialization are always initialized (relaxed-mutable-discriminants),

* A type with predefined map aggregates doesn't have a Length function; the length of aggregates will not be known for this type (map-length-aggregates),

* A type with predefined set aggregates doesn't have a Length function; the length of aggregates will not be known for this type (set-length-aggregates).

