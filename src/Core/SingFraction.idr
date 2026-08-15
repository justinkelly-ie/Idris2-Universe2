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
  mkSingFraction (n1 * n2) (d1 * d2)

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
