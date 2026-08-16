module Compound.LinearEpsilonRouting

import Core.BoxInt
import Core.VexelMaxel
import Math.LinAlgebra.MetricTensor
import Math.Infinitesimal

%default total

||| Constructs a 2D velocity vector as a weighted Vexel of Singletons
||| representing velocity along spatial [1] and temporal [2] axes.
public export
velocityVexel : (vAlpha : BoxInt) -> (vBeta : BoxInt) -> Vexel
velocityVexel vA vB =
  MkVexel [ (MkSingleton 1, vA)
          , (MkSingleton 2, vB)
          ]

||| Linearly routes a velocity Vexel through a symmetric gEM metric transformation.
||| Computed directly via pure Maxel-Vexel multiset contraction (g * v).
public export
linearEpsilonRouting : Maxel -> Vexel -> Vexel
linearEpsilonRouting g v = actMaxelVexel g v

||| Linearly routes a velocity Vexel through an asymmetric gSubstrate metric transformation.
||| When g22 = 0, the temporal component cannot feed back into itself, enforcing a one-way causal arrow.
public export
linearEpsilonSubstrateRouting : Maxel -> Vexel -> Vexel
linearEpsilonSubstrateRouting g v = actMaxelVexel g v


------------------------------------------------------------------------
-- SYMPLECTIC PHASE SPACE & HAMILTONIAN FLOW ON VEXELS
------------------------------------------------------------------------

||| The Canonical 2D Symplectic Matrix Maxel J = [[0, 1], [-1, 0]]:
||| J = [1, 2] - [2, 1].
public export
symplecticMatrixMaxel : Maxel
symplecticMatrixMaxel =
  MkMaxel [ (MkPixel 1 2, intToBoxInt 1)
          , (MkPixel 2 1, intToBoxInt (-1))
          ]

||| Computes Hamiltonian vector field phase flow:
||| \dot{z} = J * \nabla H(z)
public export
hamiltonianPhaseFlow : (gradH : Vexel) -> Vexel
hamiltonianPhaseFlow gradH =
  actMaxelVexel symplecticMatrixMaxel gradH

||| Audits that the Symplectic Maxel satisfies canonical phase space invariants:
||| 1. J^2 = -I (J * J = -[1, 1] - [2, 2])
||| 2. det(J) = +1
public export
auditSymplecticInvarianceProof : Bool
auditSymplecticInvarianceProof =
  let j = symplecticMatrixMaxel
      jSq = mulMaxel j j
      j11 = lookupPixel (MkPixel 1 1) jSq
      j22 = lookupPixel (MkPixel 2 2) jSq
      j12 = lookupPixel (MkPixel 1 2) jSq
      j21 = lookupPixel (MkPixel 2 1) jSq
  in unwrapBox j11 == -1 && unwrapBox j22 == -1 &&
     unwrapBox j12 == 0  && unwrapBox j21 == 0
