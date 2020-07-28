EXEC = composer
GHCILB = ghc

SOURCES1 = src/Tests.hs src/Command.hs src/Song.hs

$(EXEC):
	ghci $(SOURCES1)
