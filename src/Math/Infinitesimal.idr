module Math.Infinitesimal

import Core.BoxInt

%default total

||| The explicit 2x2 matrix representation of Wildberger's infinitesimal token.
||| Defined as [[0, 1], [0, 0]] in discrete dihedron algebra.
public export
record InfinitesimalToken where
  constructor MkInfinitesimal
  m11 : BoxInt -- Fixed at 0
  m12 : BoxInt -- Velocity / Derivative coefficient
  m22 : BoxInt -- Fixed at 0

public export
Eq InfinitesimalToken where
  (MkInfinitesimal a1 b1 c1) == (MkInfinitesimal a2 b2 c2) =
    a1 == a2 && b1 == b2 && c1 == c2

public export
Show InfinitesimalToken where
  show (MkInfinitesimal a b c) = "ε(" ++ show (unwrapBox b) ++ ")"

||| The canonical basis infinitesimal token ε.
public export
epsilon : InfinitesimalToken
epsilon = MkInfinitesimal (intToBoxInt 0) (intToBoxInt 1) (intToBoxInt 0)

||| Multiplication rule for the infinitesimal token: ε * ε = 0.
public export
mulEpsilon : (1 e1 : InfinitesimalToken) -> (1 e2 : InfinitesimalToken) -> BoxInt
mulEpsilon (MkInfinitesimal _ _ _) (MkInfinitesimal _ _ _) = intToBoxInt 0

||| A Dual Number a + b*ε tracking both discrete position and instantaneous velocity.
public export
record DualComplex where
  constructor MkDual
  realPart : BoxInt
  epsPart  : BoxInt

public export
Eq DualComplex where
  (MkDual r1 i1) == (MkDual r2 i2) = r1 == r2 && i1 == i2

public export
Show DualComplex where
  show (MkDual r i) = show (unwrapBox r) ++ " + " ++ show (unwrapBox i) ++ "ε"

public export
Num DualComplex where
  (+) (MkDual r1 i1) (MkDual r2 i2) = MkDual (r1 + r2) (i1 + i2)
  (*) (MkDual r1 i1) (MkDual r2 i2) = 
    -- (r1 + i1 ε)(r2 + i2 ε) = r1*r2 + (r1*i2 + i1*r2)ε + i1*i2 ε²
    -- ε² = 0 naturally clips the second-order term
    MkDual (r1 * r2) ((r1 * i2) + (i1 * r2))
  fromInteger n = MkDual (fromInteger n) (intToBoxInt 0)

public export
Neg DualComplex where
  negate (MkDual r i) = MkDual (-r) (-i)
  (-) (MkDual r1 i1) (MkDual r2 i2) = MkDual (r1 - r2) (i1 - i2)
