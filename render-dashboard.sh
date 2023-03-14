#!/usr/bin/env bash
set -euo pipefail

error() {
    >&2 echo "ERROR:" "${@}"
    exit 1
}

[ $# = 1 ] || error "Usage: $(basename "${0}") JSONNET_FILE_OF_DASHBOARD"
dashboard_jsonnet_file="${1}"
rendered_json_file="rendered/$(basename "${dashboard_jsonnet_file%.jsonnet}").rendered.json"

export JSONNET_PATH="$(realpath vendor):$(realpath lib)"
jsonnet-lint ${dashboard_jsonnet_file}
jsonnet -o ${rendered_json_file} ${dashboard_jsonnet_file}

echo "Dashboard has been rendered to ${rendered_json_file}"