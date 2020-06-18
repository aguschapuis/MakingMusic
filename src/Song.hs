module Song where

import Euterpea

--Ejemplos para probar-- 

s1 :: Song
s1 = Fragment [Note qn (A, 1), Note qn (B, 1), Note qn (C, 1)]

chord_c :: Song
chord_c = Parallel (Fragment [Note qn (C, 3)]) (Fragment [Note qn (G, 3)])

chord_g :: Song
chord_g = Parallel (Fragment [Note qn (G, 3)]) (Fragment [Note qn (D, 3)])

s2 :: Song
s2 = Repeat 4 (Concat (Repeat 4 chord_c) (Repeat 4 chord_g))

s3 :: Song
s3 = Fragment [Note qn (C, 2), Note qn (D, 2), Note qn (Ds, 2), Rest qn, Note qn (G, 2)]

-- s4 :: Song
-- s4 = Transpose 2 (Repeat 3 (Fragment [Note qn (E, 2)]))


data Song = Fragment [Primitive Pitch]
          | Tanspose Int Song 
          | Repeat Int Song
          | Concat Song Song
          | Parallel Song Song
        deriving Show

nextSTone :: PitchClass -> PitchClass
nextSTone Cf = C
nextSTone C = Cs
nextSTone Cs = D
nextSTone Df = D
nextSTone D = Ds
nextSTone Ds = E
nextSTone Ef = E
nextSTone E = F
nextSTone Ff = F
nextSTone F = Fs
nextSTone Fs = G
nextSTone Gf = G
nextSTone G = Gs
nextSTone Gs = A
nextSTone Af = A
nextSTone A = As
nextSTone As = B
nextSTone Bf = B
nextSTone B = C
nextSTone _ = error "Unsoported note"

-- data Notas = Do | Re | Mi | Fa | So | La | Si deriving (Eq,Ord,Enum,Show)

transpose_by :: Int -> Song -> Song
transpose_by _ (Fragment []) = Fragment []
transpose_by i (Fragment ((Note dur (pitch, octv)):xs))
    = Concat (Fragment [Note dur (nextSTone pitch, octv)]) (transpose_by i (Fragment xs)) 
transpose_by i (Fragment ((Rest qn):xs)) 
    = Concat (Fragment [Rest qn]) (transpose_by i (Fragment xs))
transpose_by i (Concat sng1 sng2)
    = Concat (transpose_by i sng1) (transpose_by i sng2)
transpose_by i (Parallel sng1 sng2)
    = Parallel (transpose_by i sng1) (transpose_by i sng2)

-- compute :: Song -> Music Pitch --puede usar unfould--

-- time :: Song -> Int

-- unfould :: Song -> Maybe Song
-- unfould Fragment [] = Nothing
-- unfould (Fragment ls) = Just (Fragment ls)
-- unfould (Transpose i sng) = 