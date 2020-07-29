module Song where

import Euterpea

data Song = Fragment [Primitive Pitch]
          | Transpose_by Int Song 
          | Repeat Int Song
          | Concat Song Song
          | Parallel Song Song
        deriving Show

nextPitch :: PitchClass -> PitchClass
nextPitch Cf = C
nextPitch C = Cs
nextPitch Cs = D
nextPitch Df = D
nextPitch D = Ds
nextPitch Ds = E
nextPitch Ef = E
nextPitch E = F
nextPitch Ff = F
nextPitch F = Fs
nextPitch Fs = G
nextPitch Gf = G
nextPitch G = Gs
nextPitch Gs = A
nextPitch Af = A
nextPitch A = As
nextPitch As = B
nextPitch Bf = B
nextPitch B = C
nextPitch _ = error "Unsoported note"

nNextsPitchs :: Int -> Primitive Pitch -> Primitive Pitch
nNextsPitchs _ (Rest qn) = (Rest qn)
nNextsPitchs 0 tone = tone
nNextsPitchs n (Note dur (pitch, octv)) 
            = nNextsPitchs (n-1) (Note dur (nextPitch pitch, octv)) 


--- Transpone todas las notas en n semi-tonos con la funcion nNextsPitchs

transp_by :: Int -> Song -> Song
transp_by _ (Fragment []) = Fragment []
transp_by n (Fragment xs)
    = (Fragment (map (nNextsPitchs n) xs)) 
transp_by i (Concat sng1 sng2)
    = Concat (transp_by i sng1) (transp_by i sng2)
transp_by i (Parallel sng1 sng2)
    = Parallel (transp_by i sng1) (transp_by i sng2)
transp_by i (Repeat n sng1)
    = Repeat n (transp_by i sng1)


-- Funcion para transformMaybear el tipo Maybe de computeBis 

compute :: Song -> Music Pitch
compute a = case computeBis a of
                (Just x) -> x
                Nothing  -> Prim (Rest 0)


-- Remplaza todos los elementos de Song por otros reproducibles por Euterpea

computeBis :: Song -> Maybe (Music Pitch)
computeBis (Fragment []) = Just (Prim (Rest 0)) 
computeBis (Fragment xs) = case computeBis (Fragment(tail xs)) of 
                                    (Just x)    -> Just (Prim(head xs) :+: x)
                                    Nothing     -> Nothing
computeBis (Concat sng1 sng2) = case (computeBis sng1, computeBis sng2) of
                                (Just x, Just y)    -> Just (x :+: y)
                                (_, _) -> Nothing
computeBis (Parallel sng1 sng2) = case (computeBis sng1, computeBis sng2) of
                                    (Just x, Just y)    -> Just (x :=: y)
                                    (_, _)              -> Nothing
computeBis sng1 = case unfold sng1 of
                    Just x -> computeBis x
                    Nothing -> error ("Caso nothing computeBis")                                    

--- Transforma el maybe song en Song para que pueda ser usado por el Concat
transformMaybe :: Maybe Song -> Song
transformMaybe sng = case sng of 
                Just x -> x
                Nothing -> Fragment []

-- Funciones Auxiliares para Repeat
repeatN :: Int -> Maybe Song -> Maybe Song
repeatN 1 sng = sng
repeatN n sng = Just (Concat (transformMaybe sng) (transformMaybe (repeatN (n-1) sng)))


--- reemplaza los nodos de transporte por la accion que representa
--- ya sean Transpose_by o Repeat
unfold :: Song -> Maybe Song
unfold (Fragment xs)  | (xs == []) =  Nothing
                      | otherwise = Just (Fragment xs)
unfold (Transpose_by i sng) = case (unfold sng) of
                                  Just x -> Just (transp_by i x)
                                  Nothing -> Nothing
unfold (Repeat i sng) | i == 0 = Nothing
                      | i == 1 = unfold sng
                      | otherwise = repeatN i (unfold sng) 
unfold (Concat sng1 sng2) = case  (unfold sng1, unfold sng2) of
                                  (Just x, Just y) -> Just (Concat x y)
                                  (_, _) -> Nothing 
unfold (Parallel sng1 sng2) = case  (unfold sng1, unfold sng2) of
                                    (Just x, Just y) -> Just (Parallel x y)
                                    (_, _) -> Nothing


--- para casos de error en el tiempo ---
minDur :: Dur
minDur = -9999999

--- Calcula el tiempo y el en caso de que haya error devuelve minDur 
time :: Song -> Dur
time (Fragment []) = 0
time (Fragment ((Note t a):xs)) = t + time (Fragment xs)
time (Fragment ((Rest t):xs))   = t + time (Fragment xs) -- para los silencios
time (Concat sng1 sng2) = time sng1 + time sng2
time (Parallel sng1 sng2) = max (time sng1) (time sng2)
time s = case unfold s of
            Just x  -> time x
            Nothing -> minDur  


--- remueve el tiempo de mas que tiene la lista dejandola
--- con duracion igual a la pasada por parametro
my_remove :: Dur -> [Primitive Pitch] -> [Primitive Pitch]
my_remove _ [] = []
my_remove 0 xs = xs
my_remove newDur ((Rest dur): xs) | (dur < newDur) 
                                    = (Rest dur): my_remove (newDur-dur) xs 
                                  | (dur == newDur) = [Rest dur]
                                  | otherwise = [Rest newDur]
my_remove newDur ((Note dur p): xs) | (dur < newDur) 
                                        = (Note dur p): my_remove (newDur-dur) xs 
                                    | (dur == newDur) = [Note dur p]
                                    | otherwise = [Note newDur p] 


--- recorre la cancion para recortar el tiempo de la misma
--- con la funcion definida anteriormente my_remove 
cutSong :: Song -> Dur ->  Song
cutSong (Fragment []) newDur= Fragment []
cutSong (Fragment xs) newDur = Fragment (my_remove newDur xs)
cutSong (Parallel sng1 sng2) newDur 
            | (time sng1) > newDur && (time sng2) > newDur 
                    = Parallel (cutSong sng1 newDur) (cutSong sng2 newDur)
            | (time sng1) > newDur && (time sng2) <= newDur 
                    = Parallel (cutSong sng1 newDur) sng2
            | (time sng1) <= newDur && (time sng2) > newDur 
                    = Parallel sng1 (cutSong sng2 newDur)
            | otherwise = Parallel sng1 sng2
cutSong (Concat sng1 sng2) newDur 
            | (time sng1 <= newDur) && (time sng2 > (newDur - (time sng1))) 
                    = Concat sng1 (cutSong sng2 (newDur - time sng1))
            | (time sng1 > newDur)  = cutSong sng1 newDur
            | otherwise = Concat sng1 sng2
cutSong sng1 newDur = case unfold sng1 of
                    Just x -> cutSong x newDur
                    Nothing -> error("Caso Nothing cutSong")


--- compone dos canciones en paralelo y reduce el tiempo de la que 
--- tenga mayor duracion igualandola a la de menor 
parallelMin :: Song -> Song -> Song
parallelMin sng1 sng2 | (time sng1 > time sng2) 
                            = Parallel (cutSong sng1 (time sng2)) sng2 
                      | (time sng1 < time sng2) 
                            = Parallel sng1 (cutSong sng2 (time sng1))
                      | otherwise = Parallel sng1 sng2 -- caso igual duracion


--- Agrega un silencio a la lista con la duracion pasada
add_rest :: Dur -> [Primitive Pitch] -> [Primitive Pitch]
add_rest dur [] = [Rest dur]
add_rest dur (x:xs) = x : (add_rest dur xs)


--- Agrega un silencio a la cancion con la funcion add_rest para que este 
--- quede con un tiempo igual al pasado por parametro 
add_silence :: Dur -> Song -> Song
add_silence 0 sng1 = sng1
add_silence dur (Fragment []) = Fragment[Rest dur]
add_silence dur (Fragment xs) = Fragment (add_rest dur xs)
add_silence dur (Parallel sng1 sng2)
            | (time sng1) < dur && (time sng2) < dur  
                    = Parallel (add_silence dur sng1) (add_silence dur sng2)
            | (time sng1) >= dur && (time sng2) < dur 
                    = Parallel sng1 (add_silence dur sng2)
            | (time sng1) < dur && (time sng2) >= dur 
                    = Parallel (add_silence dur sng1) sng2
            | otherwise = (Parallel sng1 sng2)
add_silence dur (Concat sng1 sng2) = Parallel sng1 (add_silence dur sng2)
add_silence dur sng1 = case unfold sng1 of
                    Just x -> add_silence dur x
                    Nothing -> error("Caso Nothing add_silence")


--- compone dos canciones en paralelo y extiende el tiempo de la que 
--- tenga menor duracion igualandola a la de menor (agregando silencios) 
parallelMax :: Song -> Song -> Song
parallelMax sng1 sng2 | (time sng1 > time sng2) 
                            = Parallel sng1  (add_silence (time sng1-time sng2) sng2)
                      | (time sng1 < time sng2) 
                            = Parallel (add_silence (time sng2-time sng1) sng1) sng2
                      | otherwise = (Parallel sng1 sng2) 