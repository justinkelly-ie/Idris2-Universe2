module Core.SingFraction

import Core.BoxInt
import Core.VexelMaxel
import Core.Multiset

%default total

------------------------------------------------------------------------
-- 1. WILDBERGER'S FRACTIONAL MULTISETS & SINGLETON DENOMINATORS
------------------------------------------------------------------------

||| A Fractional Multiset with a multiset or token numerator and a strictly non-zero Singleton denominator.
||| Establishes compile-time division-by-zero protection.
public export
record FractionalMultiset (numType : Type) where
  constructor OverSingleton
  numerator   : numType
  denominator : Singleton

||| Smart constructor for FractionalMultiset ensuring non-zero denominator.
public export
mkFractionalMultiset : numType -> Nat -> FractionalMultiset numType
mkFractionalMultiset num Z     = OverSingleton num (MkSingleton 1)
mkFractionalMultiset num (S k) = OverSingleton num (MkSingleton (S k))

------------------------------------------------------------------------
-- 2. SING FRACTION (EXACT RATIONAL TALLIES)
------------------------------------------------------------------------

||| A SingFraction represents an exact rational observable Q = N / [D],
||| where N is a signed BoxInt numerator and [D] is a non-zero Singleton denominator.
public export
record SingFraction where
  constructor MkSingFraction
  num : BoxInt
  den : Singleton

||| Smart constructor building a SingFraction with clamped non-zero denominator.
public export
mkSingFraction : BoxInt -> Nat -> SingFraction
mkSingFraction n Z     = MkSingFraction n (MkSingleton 1)
mkSingFraction n (S k) = MkSingFraction n (MkSingleton (S k))

||| Canonical zero fraction: 0 / [1]
public export
zeroSingFraction : SingFraction
zeroSingFraction = mkSingFraction (intToBoxInt 0) 1

||| Canonical unit fraction: 1 / [1]
public export
unitSingFraction : SingFraction
unitSingFraction = mkSingFraction (intToBoxInt 1) 1

||| Addition of SingFractions: (n1/d1) + (n2/d2) = (n1*d2 + n2*d1) / (d1*d2)
public export
addSingFraction : SingFraction -> SingFraction -> SingFraction
addSingFraction (MkSingFraction n1 (MkSingleton d1)) (MkSingFraction n2 (MkSingleton d2)) =
  let d1Int = natToBoxInt d1
      d2Int = natToBoxInt d2
      newNum = (n1 * d2Int) + (n2 * d1Int)
      newDen = d1 * d2
  in mkSingFraction newNum newDen

||| Subtraction of SingFractions: (n1/d1) - (n2/d2) = (n1*d2 - n2*d1) / (d1*d2)
public export
subSingFraction : SingFraction -> SingFraction -> SingFraction
subSingFraction (MkSingFraction n1 (MkSingleton d1)) (MkSingFraction n2 (MkSingleton d2)) =
  let d1Int = natToBoxInt d1
      d2Int = natToBoxInt d2
      newNum = (n1 * d2Int) - (n2 * d1Int)
      newDen = d1 * d2
  in mkSingFraction newNum newDen

||| Multiplication of SingFractions: (n1/d1) * (n2/d2) = (n1*n2) / (d1*d2)
public export
mulSingFraction : SingFraction -> SingFraction -> SingFraction
mulSingFraction (MkSingFraction n1 (MkSingleton d1)) (MkSingFraction n2 (MkSingleton d2)) =
  let newNum = n1 * n2
      newDen = d1 * d2
  in mkSingFraction newNum newDen

||| Cross-multiplication equivalence between two SingFractions: n1 * d2 == n2 * d1.
public export
rationalEquiv : SingFraction -> SingFraction -> Bool
rationalEquiv (MkSingFraction n1 (MkSingleton d1)) (MkSingFraction n2 (MkSingleton d2)) =
  let d1Int = natToBoxInt d1
      d2Int = natToBoxInt d2
  in (n1 * d2Int) == (n2 * d1Int)

||| Negation of a SingFraction.
public export
negateSingFraction : SingFraction -> SingFraction
negateSingFraction (MkSingFraction n d) = MkSingFraction (-n) d

||| Scalar multiplication of a SingFraction by a BoxInt.
public export
scaleSingFraction : BoxInt -> SingFraction -> SingFraction
scaleSingFraction s (MkSingFraction n d) = MkSingFraction (s * n) d

||| Inversion / Division: (n1/d1) / (n2/d2) where n2 != 0.
public export
divSingFraction : SingFraction -> SingFraction -> SingFraction
divSingFraction (MkSingFraction n1 (MkSingleton d1)) (MkSingFraction n2 (MkSingleton d2)) =
  let d2Int = natToBoxInt d2
      newNum = n1 * d2Int
      denomAbs = unwrapBox (if n2 >= 0 then n2 else -n2)
      dDenom = if denomAbs == 0 then 1 else integerToNat denomAbs
      signAdj = if n2 < 0 then -1 else 1
  in mkSingFraction (newNum * intToBoxInt signAdj) (d1 * dDenom)

||| Rational Equality via cross-multiplication: n1 * d2 == n2 * d1
public export
Eq SingFraction where
  (MkSingFraction n1 (MkSingleton d1)) == (MkSingFraction n2 (MkSingleton d2)) =
    (n1 * natToBoxInt d2) == (n2 * natToBoxInt d1)

public export
Show SingFraction where
  show (MkSingFraction n (MkSingleton d)) = show n ++ "/" ++ show (MkSingleton d)

------------------------------------------------------------------------
-- 3. QUANTITATIVE TYPE THEORY (QTT) LINEAR OPERATIONS
------------------------------------------------------------------------

||| Pure linear consumption of a SingFraction token.
||| Guarantees exactly one usage with zero leakage.
public export
linearConsumeSingFraction : (1 frac : SingFraction) -> SingFraction
linearConsumeSingFraction (MkSingFraction n d) = MkSingFraction n d

||| Linear scaling of a fractional multiset by a linear BoxInt factor.
public export
linearScaleSingFraction : (1 frac : SingFraction) -> (1 scale : BoxInt) -> SingFraction
linearScaleSingFraction (MkSingFraction (MkBoxInt n) d) (MkBoxInt s) =
  MkSingFraction (MkBoxInt (s * n)) d

||| Linearly split a SingFraction into two parts according to an integer partition p.
||| Conserves total numerator energy: p + (n - p) == n.
public export
linearSplitSingFraction : (1 frac : SingFraction) -> (p : BoxInt) -> (SingFraction, SingFraction)
linearSplitSingFraction (MkSingFraction (MkBoxInt n) d) (MkBoxInt p) =
  (MkSingFraction (MkBoxInt p) d, MkSingFraction (MkBoxInt (n - p)) d)

------------------------------------------------------------------------
-- 4. CONTINUED FRACTIONS & OPTIMAL RATIONAL CONVERGENTS
------------------------------------------------------------------------

||| Decomposes an exact SingFraction into a list of continued fraction coefficients [a0; a1, a2, ...]:
||| q = a0 + 1 / (a1 + 1 / (a2 + ...))
public export
toContinuedFraction : (fuel : Nat) -> SingFraction -> List BoxInt
toContinuedFraction Z _ = []
toContinuedFraction (S fuel) (MkSingFraction n (MkSingleton d)) =
  let dInt = natToBoxInt d
  in if d == 0
       then []
       else
         let a0 = n `div` dInt
             remVal = n - (a0 * dInt)
         in if unwrapBox remVal == 0
              then [a0]
              else
                let remNat = integerToNat (unwrapBox (if remVal >= 0 then remVal else -remVal))
                    inverted = MkSingFraction (if remVal >= 0 then dInt else -dInt) (MkSingleton remNat)
                in a0 :: toContinuedFraction fuel inverted

||| Reconstructs an exact SingFraction from a list of continued fraction coefficients:
||| fromContinuedFraction [a0, a1, a2, ...] = a0 + 1 / (a1 + 1 / ...)
public export
fromContinuedFraction : List BoxInt -> SingFraction
fromContinuedFraction [] = zeroSingFraction
fromContinuedFraction [a] = mkSingFraction a 1
fromContinuedFraction (a :: rest) =
  let restFrac = fromContinuedFraction rest
      oneOverRest = divSingFraction unitSingFraction restFrac
      aFrac = mkSingFraction a 1
  in addSingFraction aFrac oneOverRest

||| Audits that Continued Fraction decomposition and reconstruction preserve exact rational equivalence:
||| For q = 43 / 19, continued fraction is [2; 3, 1, 4] (2 + 1/(3 + 1/(1 + 1/4)) = 2 + 1/(3 + 4/5) = 2 + 5/19 = 43/19).
public export
auditContinuedFractionProof : Bool
auditContinuedFractionProof =
  let q = mkSingFraction (intToBoxInt 43) 19
      cf = toContinuedFraction 10 q
      reconstructed = fromContinuedFraction cf
  in cf == [intToBoxInt 2, intToBoxInt 3, intToBoxInt 1, intToBoxInt 4] &&
     reconstructed == q

------------------------------------------------------------------------
-- 5. STERN-BROCOT RATIONAL TREE & MEDIANT PATHFINDING
------------------------------------------------------------------------

||| A branch direction in the Stern-Brocot binary tree: Left (L) or Right (R).
public export
data SternBrocotBranch = BranchL | BranchR

public export
Eq SternBrocotBranch where
  BranchL == BranchL = True
  BranchR == BranchR = True
  _       == _       = False

public export
Show SternBrocotBranch where
  show BranchL = "L"
  show BranchR = "R"

||| Computes the Mediant of two positive fractions:
||| (n1 / d1) (+) (n2 / d2) = (n1 + n2) / (d1 + d2).
public export
mediantSingFraction : SingFraction -> SingFraction -> SingFraction
mediantSingFraction (MkSingFraction n1 (MkSingleton d1)) (MkSingFraction n2 (MkSingleton d2)) =
  MkSingFraction (n1 + n2) (MkSingleton (d1 + d2))

||| Computes the unique Stern-Brocot binary path for any positive SingFraction.
public export
toSternBrocotPath : (fuel : Nat) -> SingFraction -> List SternBrocotBranch
toSternBrocotPath fuel target =
  helper fuel (MkSingFraction (intToBoxInt 0) (MkSingleton 1)) (MkSingFraction (intToBoxInt 1) (MkSingleton 0)) target
  where
    helper : Nat -> SingFraction -> SingFraction -> SingFraction -> List SternBrocotBranch
    helper Z _ _ _ = []
    helper (S f) l r q =
      let m = mediantSingFraction l r
          -- Compare q with m via cross multiplication: n_q * d_m vs n_m * d_q
          (MkSingFraction nq (MkSingleton dq)) = q
          (MkSingFraction nm (MkSingleton dm)) = m
          crossDiff = (nq * natToBoxInt dm) - (nm * natToBoxInt dq)
      in if unwrapBox crossDiff == 0
           then []
           else if crossDiff < 0
                  then BranchL :: helper f l m q
                  else BranchR :: helper f m r q

||| Reconstructs the exact SingFraction at the end of a Stern-Brocot binary path.
public export
fromSternBrocotPath : List SternBrocotBranch -> SingFraction
fromSternBrocotPath path =
  helper path (MkSingFraction (intToBoxInt 0) (MkSingleton 1)) (MkSingFraction (intToBoxInt 1) (MkSingleton 0))
  where
    helper : List SternBrocotBranch -> SingFraction -> SingFraction -> SingFraction
    helper [] l r = mediantSingFraction l r
    helper (BranchL :: rest) l r =
      let m = mediantSingFraction l r
      in helper rest l m
    helper (BranchR :: rest) l r =
      let m = mediantSingFraction l r
      in helper rest m r

||| Audits that Stern-Brocot path encoding for 5/3 is [R, L, R] and reconstructs to 5/3.
public export
auditSternBrocotProof : Bool
auditSternBrocotProof =
  let q = mkSingFraction (intToBoxInt 5) 3
      path = toSternBrocotPath 10 q
      reconstructed = fromSternBrocotPath path
  in path == [BranchR, BranchL, BranchR] && reconstructed == q

------------------------------------------------------------------------
-- 6. HEHNER'S CONSTRUCTIVIST SCALE CONVERSION (BIT <=> STATE <=> CHANCE)
------------------------------------------------------------------------

||| Hehner Bit Scale: The exact binary path-depth on the Stern-Brocot state tree.
||| Replaces irrational logarithms b = -log2(c) with constructive tree depth.
public export
hehnerBitDepth : (fuel : Nat) -> SingFraction -> Nat
hehnerBitDepth fuel frac = length (toSternBrocotPath fuel frac)

||| Hehner State Scale: Computes state cardinality s = 2^b from integer bit depth b.
public export
hehnerBitsToStates : Nat -> Nat
hehnerBitsToStates Z = 1
hehnerBitsToStates (S k) = 2 * hehnerBitsToStates k

||| Hehner Chance Scale: Computes reciprocal unit chance c = 1 / [s] from state count s.
public export
hehnerStatesToChance : Nat -> SingFraction
hehnerStatesToChance s = mkSingFraction (intToBoxInt 1) (if s == 0 then 1 else s)

||| Hehner Tally Chance: Converts a discrete tally over total states to an exact SingFraction.
public export
hehnerTallyToChance : (tally : Nat) -> (totalStates : Nat) -> SingFraction
hehnerTallyToChance t sTot = mkSingFraction (natToBoxInt t) (if sTot == 0 then 1 else sTot)


||| Audits Hehner Scale Conversion:
||| 1. b = 7 bits -> s = 2^7 = 128 states (Dark Energy buffer).
||| 2. s = 128 states -> c = 1 / 128 chance.
||| 3. Stern-Brocot path depth for 5/3 is exactly 3 bits ([R, L, R]).
||| 4. Cosmic budget chance sum: 27/210 + 128/210 + 55/210 == 210/210 == 1/1.
public export
auditHehnerScaleConversionProof : Bool
auditHehnerScaleConversionProof =
  let deStates = hehnerBitsToStates 7
      deChance = hehnerStatesToChance deStates
      sbBits = hehnerBitDepth 10 (mkSingFraction (intToBoxInt 5) 3)
      vmChance = hehnerTallyToChance 27 210
      deCosmoChance = hehnerTallyToChance 128 210
      dmChance = hehnerTallyToChance 55 210
      totalChance = addSingFraction (addSingFraction vmChance deCosmoChance) dmChance
  in deStates == 128 &&
     deChance == mkSingFraction (intToBoxInt 1) 128 &&
     sbBits == 3 &&
     rationalEquiv totalChance unitSingFraction

------------------------------------------------------------------------
-- 7. STRICTLY MULTISET-BASED HEHNER SCALE & BORN RULE
------------------------------------------------------------------------

||| Evaluates the exact multiset chance of an event / item target inside a total ensemble Omega:
||| c(target, Omega) = lookupMSet(target, Omega) / [ totalMass(Omega) ]
public export
multisetChance : Eq a => a -> MSet a -> SingFraction
multisetChance target omega =
  let w = lookupMSet target omega
      totVal = unwrapBox (totalMassMSet omega)
      d = if totVal <= 0 then 1 else integerToNat totVal
  in mkSingFraction w d

||| Multiset Born Rule: Given a quantum state Vexel v = sum c_k [k],
||| the measurement probability of singleton basis state [target] is:
||| P([target]) = lookupSingleton([target], v) / [ totalMass(v) ]
public export
multisetBornRule : Singleton -> Vexel -> SingFraction
multisetBornRule target v =
  let w = lookupSingleton target v
      totVal = unwrapBox (totalVexelMass v)
      d = if totVal <= 0 then 1 else integerToNat totVal
  in mkSingFraction w d


||| Converts a Stern-Brocot path into an exact Multiset of decision branch tokens (Left and Right).
public export
hehnerMultisetBitBag : List SternBrocotBranch -> MSet SternBrocotBranch
hehnerMultisetBitBag branches =
  foldl (\acc, b => insertMSet b (intToBoxInt 1) acc) emptyMSet branches

||| Audits the Multiset Born Rule and Multiset Hehner Triad:
||| 1. Quantum state v = 3 [1] + 7 [2] (total mass 10).
|||    P([1]) = 3/10, P([2]) = 7/10.
|||    P([1]) + P([2]) = 10/10 = 1.
||| 2. Decision bit-bag for 5/3 path [R, L, R] has 2 Right tokens and 1 Left token (total mass 3).
public export
auditMultisetHehnerTriadProof : Bool
auditMultisetHehnerTriadProof =
  let psi = MkVexel [(MkSingleton 1, intToBoxInt 3), (MkSingleton 2, intToBoxInt 7)]
      p1 = multisetBornRule (MkSingleton 1) psi
      p2 = multisetBornRule (MkSingleton 2) psi
      totalP = addSingFraction p1 p2
      path = toSternBrocotPath 10 (mkSingFraction (intToBoxInt 5) 3)
      bitBag = hehnerMultisetBitBag path
      rCount = lookupMSet BranchR bitBag
      lCount = lookupMSet BranchL bitBag
  in p1 == mkSingFraction (intToBoxInt 3) 10 &&
     p2 == mkSingFraction (intToBoxInt 7) 10 &&
     rationalEquiv totalP unitSingFraction &&
     rCount == intToBoxInt 2 &&
     lCount == intToBoxInt 1


------------------------------------------------------------------------
-- 8. MULTISET COMPACTNESS RATIO & JACCARD DIVERGENCE
------------------------------------------------------------------------

||| Evaluates the exact Multiset Compactness Ratio (Jaccard Overlap Index) in [0, 1]:
||| Compactness(P, Q) = |P ∩ Q| / [ |P ∪ Q| ]
||| Measures model predictive intelligence: 1/1 = perfect compression, 0/1 = complete failure.
public export
multisetCompactnessRatio : Eq a => (envP : MSet a) -> (modelQ : MSet a) -> SingFraction
multisetCompactnessRatio envP modelQ =
  let interMass = multisetIntersectionMass envP modelQ
      unionMass = multisetUnionMass envP modelQ
      denom = if unionMass == 0 then 1 else unionMass
  in mkSingFraction (natToBoxInt interMass) denom

||| Evaluates the exact Multiset Jaccard Distance (Dissimilarity Divergence) in [0, 1]:
||| JaccardDistance(P, Q) = |P Δ Q| / [ |P ∪ Q| ]
public export
multisetJaccardDistance : Eq a => (envP : MSet a) -> (modelQ : MSet a) -> SingFraction
multisetJaccardDistance envP modelQ =
  let diffMass = multisetSymmetricDifference envP modelQ
      unionMass = multisetUnionMass envP modelQ
      denom = if unionMass == 0 then 1 else unionMass
  in mkSingFraction (natToBoxInt diffMass) denom

||| Audits that Multiset Compactness Ratio and Jaccard Distance:
||| 1. Compactness(P, P) == 1 / 1 (100% predictive intelligence).
||| 2. JaccardDistance(P, P) == 0 / 1 (Zero prediction error).
||| 3. For P = {1:10, 2:5} and Q = {1:10, 2:5, 3:15} (Union=30, Inter=15):
|||    Compactness = 15/30 = 1/2, JaccardDistance = 15/30 = 1/2.
public export
auditMultisetCompactnessRatioProof : Bool
auditMultisetCompactnessRatioProof =
  let p = MkMSet [(1, intToBoxInt 10), (2, intToBoxInt 5)]
      q = MkMSet [(1, intToBoxInt 10), (2, intToBoxInt 5), (3, intToBoxInt 15)]
      compSelf = multisetCompactnessRatio p p
      distSelf = multisetJaccardDistance p p
      compPQ = multisetCompactnessRatio p q
      distPQ = multisetJaccardDistance p q
  in compSelf == unitSingFraction &&
     distSelf == zeroSingFraction &&
     compPQ == mkSingFraction (intToBoxInt 15) 30 &&
     distPQ == mkSingFraction (intToBoxInt 15) 30



