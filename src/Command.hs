module Command where 

data Command a = Add a
				| Use1 Int (a -> a)
				| Use2 Int Int (a -> a -> a)


run :: [Command a] -> [a] -> Maybe [a]