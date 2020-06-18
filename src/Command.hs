module Command where 

data Command a = Add Song
						 	 | Use1 Int [Song]
						 	 | Use2 Int Int [Song]


run :: Command a -> [Song] -> Maybe [Song]