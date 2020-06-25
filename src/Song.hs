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

compute :: Song -> Maybe(Music Pitch) --puede usar unfould--
compute Fragment xs | xs == [] = Just(Prim (Rest 0))
                    | otherwise = case (compute Fragment (tail xs)) of 
                                        (Just x)    -> Just (Prim((head xs) :+: x))
                                        Nothing     -> Nothing
comput Concat sng1 sng2 = case (compute sng1, compute sng2) of
                                (Just x, Just y)    -> (x :+: y)
                                (Nothing, Just y)   -> y
                                (Just x, Nothing)   -> x
                                (_, _) -> Nothing
compute Parallel sng1 sng2 = case (compute sng1, compute sng2) of
                                    (Just x, Just y)    -> (x :=: y)
                                    (Nothing, Just y)   -> y
                                    (Just x, Nothing)   -> x
                                    (_, _)              -> Nothing  
compute sng = case (unfold sng) of
                    (Just x)    -> compute x
                    Nothing     -> Nothing


-- time :: Song -> Int

unfold :: Song -> Maybe Song
unfold Fragment xs  | (xs == []) =  Nothing
                    | otherwise = Just (Fragment xs)
unfold Transpose i sng = Just (transpose_by i (unfold sng))
unfold Repeat i sng | i == 0 = Nothing
                    | i == 1 = Just (unfold sng1)
                    | otherwise = case  (unfold sng1) of 
                                        (Just x) -> Just(Concat x (Repeat (i-1) x))
unfold Concat sng1 sng2 = case  (unfold sng1, unfold sng2) of
                                (Just x, Just y) -> Just (Concat x y)
                                (_, _) -> Nothing 
unfold Parallel sng1 sng2 = case  (unfold sng1, unfold sng2) of
                                    (Just x, Just y) -> Just (Parallel x y)
                                    (_, _) -> Nothing

