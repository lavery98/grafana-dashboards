
.PHONY: clean generate

JSONNET_BIN ?= jsonnet

clean:
	rm -rf gen

generate: clean
	${JSONNET_BIN} -J vendor -m gen -c generate.jsonnet
