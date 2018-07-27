default: orbgo.js

ELM_FILES = $(shell find . -path ./elm-stuff -prune -o -type f -name '*.elm')

ELM_PATH := ./usr/local/bin/elm/
PATH := $(ELM_PATH)/bin:$(PATH)

orbgo.js: $(ELM_FILES)
	elm-make --yes Orbgo.elm --output ./js/orbgo.js

clean-deps:
	rm -rf elm-stuff

clean:
	rm -f ./js/orbgo.js
	rm -rf elm-stuff/build-artifacts