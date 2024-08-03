#
# Copyright 2024 Ashley Lavery
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

.PHONY: clean generate generate-mixin lint fmt

JSONNET_BIN ?= jsonnet
JSONNET_FMT := jsonnetfmt -n 2 --max-blank-lines 2 --string-style s --comment-style s

JSONNET_FILE := generate.jsonnet
MIXIN_FILE := mixin.libsonnet

clean:
	rm -rf gen

generate: clean
	${JSONNET_BIN} -J vendor -m gen -c $(JSONNET_FILE)

generate-mixin: clean
	${JSONNET_BIN} -J vendor -m gen -c -e '(import "$(MIXIN_FILE)").grafanaDashboards'

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
