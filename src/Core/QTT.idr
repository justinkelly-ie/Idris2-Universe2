module Core.QTT

import Core.Multiset

%default total

||| A linear resource container holding an exact quantity of type a.
||| Guarantees that the underlying resource cannot be silently dropped or duplicated.
public export
data Conserved : (a : Type) -> Type where
  MkConserved : (1 item : a) -> Conserved a

||| Consumes a conserved resource safely using a linear continuation.
public export
useConserved : (1 container : Conserved a) -> (1 f : (1 item : a) -> b) -> b
useConserved (MkConserved item) f = f item

||| A conserved linear pair holding two items without resource duplication or loss.
public export
data LinearPair : (a : Type) -> (b : Type) -> Type where
  MkLinearPair : (1 fst : a) -> (1 snd : b) -> LinearPair a b

||| Splits a pair of linearly tracked items without resource loss.
public export
splitLinearPair : (1 pair : LinearPair a b) -> (1 f : (1 x : a) -> (1 y : b) -> c) -> c
splitLinearPair (MkLinearPair x y) f = f x y

||| Linearly merges two items into a single conserved tuple.
public export
joinLinear : (1 x : a) -> (1 y : b) -> LinearPair a b
joinLinear x y = MkLinearPair x y

||| Erased proof witness ensuring a cosmological invariant holds
||| at compile-time with zero runtime memory footprint.
public export
data InvariantProof : (0 prop : Type) -> Type where
  Witness : (0 p : prop) -> InvariantProof prop
