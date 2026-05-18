all:
	@stack ghc --package aeson --package postgresql-simple src/raspi-finance-database.hs
	@rm -rf *.hi *.o *.dyn_hi *.dyn_o
