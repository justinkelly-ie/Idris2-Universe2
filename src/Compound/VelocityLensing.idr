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

||| Linearly lenses 2D velocity tokens across a scale change with pure structural accounting.
||| Contains zero unverified casting operators.
public export
lensVelocityAcrossScale : {vm, de, dm : Nat} ->
                          (state : UniverseState vm de dm) ->
                          (metric : Maxel) ->
                          (1 velocity : VelocityVector2D) ->
                          VelocityVector2D
lensVelocityAcrossScale (MkUniverseState vm de dm) metric (MkVelocity vA vB) =
  let drag = sumStructural dm
      g11Val = g11 metric
      g12Val = g12 metric
      g22Val = g22 metric
      vA_12 = m12 vA
      vB_12 = m12 vB
      scaleFactor = intToBoxInt 1 + drag
      
      -- Vector components scale cleanly under pure BoxInt algebra
      rawOutAlpha = (g11Val * vA_12) + (g12Val * vB_12)
      rawOutBeta  = (g12Val * vA_12) + (g22Val * vB_12)
      outAlpha = rawOutAlpha `div` scaleFactor
      outBeta  = rawOutBeta  `div` scaleFactor
  in MkVelocity (MkInfinitesimal (intToBoxInt 0) outAlpha (intToBoxInt 0))
                (MkInfinitesimal (intToBoxInt 0) outBeta  (intToBoxInt 0))
