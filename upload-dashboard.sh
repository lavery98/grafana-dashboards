#!/usr/bin/env bash
set -eu -o pipefail

error() {
    >&2 echo "ERROR:" "${@}"
    exit 1
}

[ -n "${GRAFANA_API_KEY:-}" ] || error "Invalid GRAFANA_API_KEY"
[[ "${GRAFANA_URL:-}" =~ ^https?://[^/]+/$ ]] || error "Invalid GRAFANA_URL (example: 'http://localhost:3000/' incl. slash at end)"

[ $# = 1 ] || error "Usage: $(basename "${0}") JSON_FILE_OF_DASHBOARD"
json_file="${1}"

cat "${json_file}" \
    | jq '{"dashboard":.,"folderId":0,"overwrite":true} | .dashboard.editable = true' \
    | curl --fail-with-body -sS -X POST -H "Authorization: Bearer ${GRAFANA_API_KEY}" -H "Content-Type: application/json" --data-binary @- "${GRAFANA_URL}api/dashboards/db" \
    && echo "" \
    || error "Failed to upload dashboard"