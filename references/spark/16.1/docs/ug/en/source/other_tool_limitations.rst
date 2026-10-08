The following constructs are incompletely supported. They can be used safely but might lead to unexpected behavior. Warnings for these constructs can be enabled individually using the ``-W`` switch and the tag between parentheses, or collectively using the ``--info`` switch.

* If all components of a given type are annotated with  Relaxed_Initialization, the containing type is treated as if it had the same annotation (component-relaxed-init),

* The full view of an incomplete type deferred to the body of a withed unit might be visible by GNATprove (full-view-visible).

