module Compound.VelocityLensing

import Evolution.State
import Evolution.StructuralAccounting
import Math.LinAlgebra.MetricTensor
import Math.Infinitesimal
import Compound.LinearEpsilonRouting
import Core.BoxInt
import Data.Vect

%default total

||| Evaluates the total sum of BoxInt tokens across a vector purely structurally.
||| Bypasses all unverified primitive runtime casting operations.
public export
sumBoxInt : {n : Nat} -> Vect n BoxInt -> BoxInt
sumBoxInt dmLog = sumStructural dmLog

||| Evaluates the inductive drag scalar factor exerted by the Dark Matter residue
||| purely from the structural geometry of the Dark Matter array.
public export
computeInductiveDrag : {dm : Nat} -> Vect dm BoxInt -> BoxInt
computeInductiveDrag {dm} dmLogData = sumStructural dmLogData

||| Linearly lenses 2D velocity tokens across a scale change with pure structural accounting.
||| Contains zero unverified casting operators.
public export
lensVelocityAcrossScale : {vm, de, dm : Nat} ->
                          (state : UniverseState vm de dm) ->
                          (metric : MetricTensor2D) ->
                          (1 velocity : VelocityVector2D) ->
                          VelocityVector2D
lensVelocityAcrossScale (MkUniverseState vm de dm) (MkMetricTensor2D g11 g12 g22) (MkVelocity vA vB) =
  let drag = computeInductiveDrag dm
      vA_12 = m12 vA
      vB_12 = m12 vB
      scaleFactor = intToBoxInt 1 + drag
      
      -- Vector components scale cleanly under pure BoxInt algebra
      rawOutAlpha = (g11 * vA_12) + (g12 * vB_12)
      rawOutBeta  = (g12 * vA_12) + (g22 * vB_12)
      outAlpha = rawOutAlpha `div` scaleFactor
      outBeta  = rawOutBeta  `div` scaleFactor
  in MkVelocity (MkInfinitesimal (intToBoxInt 0) outAlpha (intToBoxInt 0))
                (MkInfinitesimal (intToBoxInt 0) outBeta  (intToBoxInt 0))
