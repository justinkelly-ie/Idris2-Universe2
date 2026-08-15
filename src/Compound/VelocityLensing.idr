module Compound.VelocityLensing

import Evolution.State
import Math.LinAlgebra.MetricTensor
import Math.Infinitesimal
import Compound.LinearEpsilonRouting
import Core.BoxInt
import Data.Vect

%default total

||| Evaluates the total sum of BoxInt tokens across a vector.
public export
sumBoxInt : {n : Nat} -> Vect n BoxInt -> BoxInt
sumBoxInt [] = intToBoxInt 0
sumBoxInt (x :: xs) = x + sumBoxInt xs

||| Evaluates the inductive drag scalar factor exerted by the Dark Matter residue
||| directly from BoxInt tokens without continuous casts.
public export
computeInductiveDrag : {dm : Nat} -> Vect dm BoxInt -> BoxInt
computeInductiveDrag {dm} dmLogData = sumBoxInt dmLogData

||| Dynamically lenses 2D velocity tokens across a scale change,
||| where the inductive drag is automatically determined by the Dark Matter residue size.
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
      rawOutAlpha = (g11 * vA_12) + (g12 * vB_12)
      rawOutBeta  = (g12 * vA_12) + (g22 * vB_12)
      outAlpha = rawOutAlpha `div` scaleFactor
      outBeta  = rawOutBeta  `div` scaleFactor
  in MkVelocity (MkInfinitesimal (intToBoxInt 0) outAlpha (intToBoxInt 0))
                (MkInfinitesimal (intToBoxInt 0) outBeta  (intToBoxInt 0))
