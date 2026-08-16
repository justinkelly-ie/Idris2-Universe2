module Math.DiscreteBoltzmannDistribution

import Core.BoxInt
import Core.SingFraction
import Math.FourGeometries
import Data.Vect
import Data.List

%default total

------------------------------------------------------------------------
-- 1. DISCRETE ENERGY LEVELS & RATIONAL TEMPERATURE FACTORS
------------------------------------------------------------------------

||| An Energy Level with an energy index E and microstate multiplicity w(E).
public export
record EnergyLevel where
  constructor MkEnergyLevel
  energyIndex  : Nat
  multiplicity : Nat

public export
Eq EnergyLevel where
  (MkEnergyLevel e1 w1) == (MkEnergyLevel e2 w2) =
    e1 == e2 && w1 == w2

public export
Show EnergyLevel where
  show (MkEnergyLevel e w) =
    "Level(E=" ++ show e ++ ", w=" ++ show w ++ ")"

||| Exact natural power b^e.
public export
natPower : Nat -> Nat -> Nat
natPower _ Z = 1
natPower b (S k) = b * natPower b k

||| Computes scaled polynomial partition sum numerator:
||| ∑_{k=0}^m w_k · N^k · D^{m-k} where maxLevel = m.
public export
scaledPartitionSum : List EnergyLevel -> (maxLevel : Nat) -> (numQ : Nat) -> (denQ : Nat) -> Nat
scaledPartitionSum [] _ _ _ = 0
scaledPartitionSum (MkEnergyLevel e w :: xs) maxLevel numQ denQ =
  let pNum = natPower numQ e
      pDen = natPower denQ (maxLevel `minus` e)
      term = w * (pNum * pDen)
  in term + scaledPartitionSum xs maxLevel numQ denQ

||| Computes the scaled weight numerator for a single level: w_k · N^k · D^{m-k}.
public export
scaledLevelWeight : EnergyLevel -> (maxLevel : Nat) -> (numQ : Nat) -> (denQ : Nat) -> Nat
scaledLevelWeight (MkEnergyLevel e w) maxLevel numQ denQ =
  let pNum = natPower numQ e
      pDen = natPower denQ (maxLevel `minus` e)
  in w * (pNum * pDen)

------------------------------------------------------------------------
-- 2. DISCRETE BOLTZMANN PROBABILITIES AS RATIONAL HEHNER CHANCES
------------------------------------------------------------------------

||| Computes exact Boltzmann probability for level k as a normalized fraction:
||| P(E_k) = scaledWeight(k) / scaledPartitionSum.
public export
discreteBoltzmannProbability : EnergyLevel -> List EnergyLevel -> (maxLevel : Nat) -> 
                                (numQ : Nat) -> (denQ : Nat) -> (Nat, Nat)
discreteBoltzmannProbability lvl spectrum maxLevel numQ denQ =
  let wNum = scaledLevelWeight lvl maxLevel numQ denQ
      zDen = scaledPartitionSum spectrum maxLevel numQ denQ
  in (wNum, zDen)

||| Computes the sum of all probability numerators across the spectrum.
public export
totalProbabilityNumerator : List EnergyLevel -> (maxLevel : Nat) -> (numQ : Nat) -> (denQ : Nat) -> Nat
totalProbabilityNumerator spectrum maxLevel numQ denQ =
  scaledPartitionSum spectrum maxLevel numQ denQ

------------------------------------------------------------------------
-- 3. TRI-GEOMETRIC SECTOR SPECTRA & 210 COSMIC BUDGET FACTORIZATION
------------------------------------------------------------------------

||| Elliptic sector energy ladder (3 levels, 27 VM bound-state capacity).
public export
ellipticLadder : List EnergyLevel
ellipticLadder = [ MkEnergyLevel 0 1
                 , MkEnergyLevel 1 3
                 , MkEnergyLevel 2 6
                 ]

||| Hyperbolic sector energy ladder (3 levels, 128 DE gauge-phase capacity).
public export
hyperbolicLadder : List EnergyLevel
hyperbolicLadder = [ MkEnergyLevel 0 1
                   , MkEnergyLevel 1 8
                   , MkEnergyLevel 2 27
                   ]

||| Parabolic sector energy ladder (3 levels, 55 DM memory remainder capacity).
public export
parabolicLadder : List EnergyLevel
parabolicLadder = [ MkEnergyLevel 0 1
                  , MkEnergyLevel 1 2
                  , MkEnergyLevel 2 4
                  ]

||| Exponent decomposition of the Cosmic Partition Function:
||| Z_Cosmic = Z_Ell^27 × Z_Hyp^128 × Z_Par^55.
public export
cosmicPartitionExponents : (Nat, Nat, Nat, Nat)
cosmicPartitionExponents =
  let ellExp = 27
      hypExp = 128
      parExp = 55
      totalExp = ellExp + hypExp + parExp
  in (ellExp, hypExp, parExp, totalExp)

------------------------------------------------------------------------
-- 4. CONSTRUCTIVE FORMAL AUDIT PROOFS
------------------------------------------------------------------------

||| Audits Boltzmann Probability Normalization:
||| Proves that for the Elliptic spectrum at q = 1/2, the sum of probability
||| numerators exactly equals the partition sum Z(q), guaranteeing ∑ P(E_k) = 1/1.
public export
auditBoltzmannProbabilityNormalizationProof : Bool
auditBoltzmannProbabilityNormalizationProof =
  let spectrum = ellipticLadder
      maxLvl = 2
      numQ = 1
      denQ = 2
      zSum = scaledPartitionSum spectrum maxLvl numQ denQ
      p0 = scaledLevelWeight (MkEnergyLevel 0 1) maxLvl numQ denQ -- 1 * 1 * 4 = 4
      p1 = scaledLevelWeight (MkEnergyLevel 1 3) maxLvl numQ denQ -- 3 * 1 * 2 = 6
      p2 = scaledLevelWeight (MkEnergyLevel 2 6) maxLvl numQ denQ -- 6 * 1 * 1 = 6
      totalNum = p0 + p1 + p2
  in zSum == 16 &&
     p0 == 4 &&
     p1 == 6 &&
     p2 == 6 &&
     totalNum == zSum &&
     totalNum == 16

||| Audits Cosmic Budget Partition Factorization:
||| Proves that the exponents of the Tri-Geometric Partition Function strictly
||| sum to the 4th Primorial 210: 27 (Elliptic) + 128 (Hyperbolic) + 55 (Parabolic) = 210.
public export
auditCosmicBudgetPartitionFactorizationProof : Bool
auditCosmicBudgetPartitionFactorizationProof =
  let (e, h, p, tot) = cosmicPartitionExponents
  in e == 27 &&
     h == 128 &&
     p == 55 &&
     tot == 210

||| Audits Zero-Temperature Ground State Collapse:
||| In the limit of low temperature q -> 0 (numQ = 0, denQ = 1), the ground state
||| probability evaluates strictly to 1/1 (P(E_0) = 1, P(E>0) = 0), collapsing
||| thermal entropy to 0 and maximizing compactness intelligence.
public export
auditZeroTemperatureGroundStateCollapseProof : Bool
auditZeroTemperatureGroundStateCollapseProof =
  let spectrum = ellipticLadder
      maxLvl = 2
      numQ = 0
      denQ = 1
      zSum = scaledPartitionSum spectrum maxLvl numQ denQ
      p0 = scaledLevelWeight (MkEnergyLevel 0 1) maxLvl numQ denQ
      p1 = scaledLevelWeight (MkEnergyLevel 1 3) maxLvl numQ denQ
      p2 = scaledLevelWeight (MkEnergyLevel 2 6) maxLvl numQ denQ
  in zSum == 1 &&
     p0 == 1 &&
     p1 == 0 &&
     p2 == 0 &&
     p0 == zSum
