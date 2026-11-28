# Unit totality focused draft diagnostics

First draft: arithmetic tactic lacked the projected post-step upper bound; the
bound was already proved in Bounded but not exposed to omega. Add next.2.
Normalize Bool.false guards when composing nested Outcome.bind and use the
current ite_eq_right spelling. No claim/domain or evaluator bound changed.

Second draft: all generic totality and model-observation proofs elaborate;
remove one unused simp argument and open the existing ObjectRows namespace for
the model object's unconditional cursor theorem. Next check is the same focused
UnitTotal target. Native source remains unchanged.
