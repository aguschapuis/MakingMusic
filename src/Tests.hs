module Tests where

import Euterpea
import Song
import Command

s1 :: Song
s1 = Fragment [Note qn (A, 1), Note qn (B, 1), Note qn (C, 1)]

s3 :: Song
s3 = Fragment [Note qn (C, 2), Note qn (D, 2), Note qn (Ds, 2), Rest qn, Note qn (G, 2)]

s4 :: Song
s4 = Transpose_by 2 (Repeat 3 (Fragment [Note qn (E, 2)]))

chord_c :: Song
chord_c = Parallel (Fragment [Note qn (C, 3)]) (Fragment [Note qn (G, 3)])

chord_g :: Song
chord_g = Parallel (Fragment [Note qn (G, 3)]) (Fragment [Note qn (D, 3)])

s2 :: Song
s2 = Repeat 2 (Transpose_by 2 (Concat (Repeat 4 chord_c) (Repeat 4 chord_g)))

add_chord_c = Add (Parallel (Fragment [Note qn (C, 3)]) (Fragment [Note qn (G, 3)]))
add_chord_g = Add (Parallel (Fragment [Note qn (G, 3)]) (Fragment [Note qn (D, 3)]))
join_chords = Use2 1 0 (\c g -> Repeat 4 (Concat (Repeat 4 c) (Repeat 4 g)))

testUnfold :: Song
testUnfold = case unfold s2 of
                Just x -> x
                Nothing -> (Fragment [])

testCompute :: Music Pitch
testCompute = compute s2

testTime :: Dur
testTime = time s2

testRun :: Maybe Song
testRun = run [add_chord_c, add_chord_g, join_chords] [] >>= \r-> return (r!!0)