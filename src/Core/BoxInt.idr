module Core.BoxInt

import Data.Nat

%default total

||| A BoxInt is a signed integer wrapped in a discrete box.
||| It represents concrete particle counts, quadrances, and metric entries
||| in Wildberger's Box Arithmetic.
public export
record BoxInt where
  constructor MkBoxInt
  value : Integer

public export
unwrapBox : BoxInt -> Integer
unwrapBox (MkBoxInt v) = v

public export
intToBoxInt : Integer -> BoxInt
intToBoxInt n = MkBoxInt n

public export
integerToBoxInt : Integer -> BoxInt
integerToBoxInt n = MkBoxInt n

public export
natToBoxInt : Nat -> BoxInt
natToBoxInt n = MkBoxInt (natToInteger n)

public export
addBoxLinear : (1 a : BoxInt) -> (1 b : BoxInt) -> BoxInt
addBoxLinear (MkBoxInt a) (MkBoxInt b) = MkBoxInt (a + b)

public export
Num BoxInt where
  (+) (MkBoxInt a) (MkBoxInt b) = MkBoxInt (a + b)
  (*) (MkBoxInt a) (MkBoxInt b) = MkBoxInt (a * b)
  fromInteger n = MkBoxInt n

public export
Neg BoxInt where
  negate (MkBoxInt a) = MkBoxInt (-a)
  (-) (MkBoxInt a) (MkBoxInt b) = MkBoxInt (a - b)

public export
Eq BoxInt where
  (MkBoxInt a) == (MkBoxInt b) = a == b

public export
Ord BoxInt where
  compare (MkBoxInt a) (MkBoxInt b) = compare a b

public export
Show BoxInt where
  show (MkBoxInt a) = "[" ++ show a ++ "]"

public export
div : BoxInt -> BoxInt -> BoxInt
div (MkBoxInt a) (MkBoxInt b) = 
  if b == 0 then MkBoxInt 0 else MkBoxInt (a `div` b)

public export
mod : BoxInt -> BoxInt -> BoxInt
mod (MkBoxInt a) (MkBoxInt b) = 
  if b == 0 then MkBoxInt 0 else MkBoxInt (a `mod` b)
