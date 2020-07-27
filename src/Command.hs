module Command where 

import Song
-- import Example

data Command a = Add a
               | Use1 Int (a -> a) --- use 1 (repeat 4)
               | Use2 Int Int (a -> a -> a) --- use 0 1 (Concat)

--- Puede fallar cuando los indices esten fuera de rango (devolver Nothing)
--- Es el que construye el stack


run :: [Command a] -> [a] -> Maybe [a]
run [] stack = Just stack
run (Add a : xs) stack = run xs (a :stack)
run ((Use1 n fun) : xs) stack | n > (length stack -1)  = Nothing
                              | n < 0 = Nothing
                              | otherwise = (run xs (fun (stack !! n) : stack))
run ((Use2 n1 n2 fun) : xs) stack | n1 > (length stack -1) || n2 > (length stack -1) = Nothing
                                  | n1 < 0 || n2 < 0 = Nothing
                                  | otherwise = (run xs ((fun (stack!!n1) (stack!!n2)) : stack))