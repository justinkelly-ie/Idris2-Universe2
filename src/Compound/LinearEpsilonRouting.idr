module Compound.LinearEpsilonRouting

import Core.BoxInt
import Core.VexelMaxel
import Math.LinAlgebra.MetricTensor
import Math.Infinitesimal

%default total

||| A 2D Infinitesimal Vector representing localized velocity tokens
||| along the coordinate axes of the discrete lattice grid.
public export
record VelocityVector2D where
  constructor MkVelocity
  vAlpha : InfinitesimalToken -- Velocity along horizontal / spatial axis
  vBeta  : InfinitesimalToken -- Velocity along vertical / temporal axis

public export
Eq VelocityVector2D where
  (MkVelocity a1 b1) == (MkVelocity a2 b2) = a1 == a2 && b1 == b2

public export
Show VelocityVector2D where
  show (MkVelocity a b) = "Velocity2D(" ++ show a ++ ", " ++ show b ++ ")"

||| Linearly routes 2D velocity tokens through a symmetric gEM metric transformation.
public export
linearEpsilonRouting : Maxel -> (1 v : VelocityVector2D) -> VelocityVector2D
linearEpsilonRouting g (MkVelocity vA vB) =
  let g11Val = g11 g
      g12Val = g12 g
      g22Val = g22 g
      vA_12 = m12 vA
      vB_12 = m12 vB
      outAlpha = (g11Val * vA_12) + (g12Val * vB_12)
      outBeta  = (g12Val * vA_12) + (g22Val * vB_12)
  in MkVelocity (MkInfinitesimal (intToBoxInt 0) outAlpha (intToBoxInt 0))
                (MkInfinitesimal (intToBoxInt 0) outBeta  (intToBoxInt 0))

||| Linearly routes 2D velocity tokens through an asymmetric gSubstrate metric transformation.
||| When g22 = 0, the vertical component cannot feed back into itself, enforcing a one-way causal arrow.
public export
linearEpsilonSubstrateRouting : Maxel -> (1 v : VelocityVector2D) -> VelocityVector2D
linearEpsilonSubstrateRouting g (MkVelocity vA vB) =
  let g11Val = g11 g
      g12Val = g12 g
      g22Val = g22 g
      vA_12 = m12 vA
      vB_12 = m12 vB
      outAlpha = (g11Val * vA_12) + (g12Val * vB_12)
      outBeta  = (g12Val * vA_12) + (g22Val * vB_12)
  in MkVelocity (MkInfinitesimal (intToBoxInt 0) outAlpha (intToBoxInt 0))
                (MkInfinitesimal (intToBoxInt 0) outBeta  (intToBoxInt 0))
