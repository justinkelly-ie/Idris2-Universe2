module Compound.VelocityLensing

import Evolution.State
import Evolution.StructuralAccounting
import Math.LinAlgebra.MetricTensor
import Math.Infinitesimal
import Compound.LinearEpsilonRouting
import Core.BoxInt
import Core.VexelMaxel
import Data.Vect

%default total

||| Linearly lenses a velocity Vexel across a scale change with pure structural accounting.
||| Contracts the metric Maxel against the velocity Vexel and applies inductive Dark Matter drag.
public export
lensVelocityAcrossScale : {vm, de, dm : Nat} ->
                          (state : UniverseState vm de dm) ->
                          (metric : Maxel) ->
                          (1 velocity : Vexel) ->
                          Vexel
lensVelocityAcrossScale (MkUniverseState vm de dm) metric vel =
  let drag = sumStructural dm
      scaleFactor = intToBoxInt 1 + drag
      (MkVexel unscaledTerms) = actMaxelVexel metric vel
      scaledTerms = map (\(s, w) => (s, w `div` scaleFactor)) unscaledTerms
  in MkVexel scaledTerms
