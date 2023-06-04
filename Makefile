
.PHONY: clean generate lint fmt

JSONNET_BIN ?= jsonnet
JSONNET_FMT := jsonnetfmt -n 2 --max-blank-lines 2 --string-style s --comment-style s

clean:
	rm -rf gen

generate: clean
	${JSONNET_BIN} -J vendor -m gen -c generate.jsonnet

lint:
	@RESULT=0; \
	for f in $$(find . -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print); do \
		jsonnet-lint -J vendor "$$f"; \
		RESULT=$$(($$RESULT + $$?)); \
	done; \
	exit $$RESULT

fmt:
	@find . -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print | \
		xargs -n 1 -- $(JSONNET_FMT) -i
