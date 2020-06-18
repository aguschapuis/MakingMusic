module Song where

import Euterpea

s1 :: Song
s1 = Fragment [Note qn (A, 1), Note qn (B, 1), Note qn (C, 1)]

data Song = Fragment [Primitive Pitch]
          | Tanspose Int Song 
          | Repeat Int Song
          | Concat Song Song
          | Parallel Song Song
        deriving Show

data Notas = Do | Re | Mi | Fa | So | La | Si deriving (Eq,Ord,Enum,Show)

-- transpose_by :: Int -> Maybe Song -> Song
-- transpose_by 0 sng = sng
-- transpose_by i 

-- compute :: Song -> Music Pitch --puede usar unfould--

-- time :: Song -> Int

-- unfould :: Song -> Maybe Song
-- unfould Fragment [] = Nothing
-- unfould (Fragment ls) = Just (Fragment ls)
-- unfould (Transpose i sng) = 