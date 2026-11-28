module

public import Silver.PackageEffectSummaries
public import Silver.ApplicationPackageSourceEffects

@[expose] public section

/-! Original routine source supplies inferred effect membership in the native
footer summary. The conservative summary remains at its original identity. -/
namespace Silver.ApplicationPackageRoutineEffects
open Packages Packages.EffectSummaries

export Packages.EffectSummaries
  (Included execute_local_summary append_respects_summary append_local_summary)

end Silver.ApplicationPackageRoutineEffects
