module Evolution.StructuralAccounting

import Core.BoxInt
import Data.Vect

%default total

||| Pure, cast-free structural summation of BoxInt vectors.
||| Accumulates memory units purely through inductive box container algebra (+),
||| with zero reliance on backend primitive integer casts.
public export
sumStructural : {n : Nat} -> Vect n BoxInt -> BoxInt
sumStructural []        = intToBoxInt 0
sumStructural (x :: xs) = x + sumStructural xs

||| Pure structural summation of standard integer vectors directly into BoxInt algebra.
public export
sumStructuralInt : {n : Nat} -> Vect n Int -> BoxInt
sumStructuralInt []        = intToBoxInt 0
sumStructuralInt (x :: xs) = (intToBoxInt (cast x)) + sumStructuralInt xs

||| Pure structural counting of a vector's length directly into a BoxInt container:
||| Each element adds exactly one physical unit box (intToBoxInt 1).
public export
countStructural : {n : Nat} -> {0 a : Type} -> Vect n a -> BoxInt
countStructural []        = intToBoxInt 0
countStructural (x :: xs) = (intToBoxInt 1) + countStructural xs

||| Evaluates associative grouping across a 3-way vector split during scale transitions:
||| (A + B) + C == A + (B + C)
public export
verifyAssociativeTransition : (a : BoxInt) -> (b : BoxInt) -> (c : BoxInt) -> Bool
verifyAssociativeTransition a b c =
  ((a + b) + c) == (a + (b + c))
