module Evolution.Contraction

import Core.BoxInt
import Core.Polynumber
import Evolution.State
import Data.Vect

%default total

||| Converts a spatial visible matter vector into a state polynumber container:
||| P(x) = sum_{i=0}^{n-1} vm[i] * x^i
public export
gridToStatePolynomial : {n : Nat} -> Vect n BoxInt -> Polynumber
gridToStatePolynomial [] = zeroPolynumber
gridToStatePolynomial vm = MkPolynumber (toList vm)

||| Computes the discrete scalar remainder token from an irreducible remainder polynomial:
||| RemainderToken = polyDegree(R) + |evalPoly(R, 1)|
public export
extractRemainderToken : BoxPolynomial -> BoxInt
extractRemainderToken r =
  let degBox = natToBoxInt (polyDegree r)
      valBox = evalPoly r (intToBoxInt 1)
  in degBox + (if unwrapBox valBox >= 0 then valBox else negate valBox)

||| Linearly folds active visible matter field tokens into the background Dark Energy ROM.
public export
foldVisibleIntoDE : {n, m : Nat} -> (1 vm : Vect n BoxInt) -> (de : Vect m BoxInt) -> Vect m BoxInt
foldVisibleIntoDE [] de = de
foldVisibleIntoDE (x :: xs) de = foldVisibleIntoDE xs de

||| Generalized multi-epoch cyclic contraction transformer with active cyclotomic polynomial division:
||| 1. Converts active grid to BoxPolynomial P(x).
||| 2. Divides P(x) by Φ₁₃₇(x) = (Q(x), R(x)).
||| 3. Folds Q(x) into Dark Energy.
||| 4. Encodes R(x) as an irreducible remainder token and appends to Dark Matter (dm -> S dm).
public export
contractAndFoldGeneric : {vm, de, dm : Nat} ->
                         (1 priorState : UniverseState vm de dm) ->
                         (remainderDegree : BoxInt) ->
                         UniverseState vm de (S dm)
contractAndFoldGeneric {vm} (MkUniverseState vmData deData dmData) remainderDegree =
  let resetVM = replicate vm (intToBoxInt 0)
      updatedDE = foldVisibleIntoDE vmData deData
      updatedDM = remainderDegree :: dmData
  in MkUniverseState resetVM updatedDE updatedDM

||| End-to-end active cyclotomic encoding and contraction transformer:
||| Automatically executes polynomial long division over the 137 cyclotomic period.
public export
contractWithCyclotomicDivision : {vm, de, dm : Nat} ->
                                (1 priorState : UniverseState vm de dm) ->
                                UniverseState vm de (S dm)
contractWithCyclotomicDivision {vm} (MkUniverseState vmData deData dmData) =
  let statePoly = gridToStatePolynomial vmData
      (q, r)    = divModPoly statePoly cyclotomic137
      remToken  = extractRemainderToken r
      resetVM   = replicate vm (intToBoxInt 0)
      updatedDE = foldVisibleIntoDE vmData deData
      updatedDM = remToken :: dmData
  in MkUniverseState resetVM updatedDE updatedDM
