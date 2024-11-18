# Grafana mixins

This repository contains [mixins](https://monitoring.mixins.dev/) that I use to generate dashboards and alerts which are used on my Grafana instance.
All of the mixins use [Grafonnet](https://github.com/grafana/grafonnet) for the dashboard generation.

The mixins can be added to a dashboard repository using [jsonnet-bundler](https://github.com/jsonnet-bundler/jsonnet-bundler) and the command `jb install https://github.com/lavery98/grafana-dashboards/mixins`

Each mixin exposes a `grafanaDashboards` object with the generated dashboards. There are currently no alerts or rules exposed via the `prometheusAlerts` and `prometheusRules` objects.

## Available mixins
| Mixin | Description | Requirements |
| ----- | ----------- | ------------ |
| Bind  | Bind overview dashboard providing various information from the Bind exporter | The bind-mixin uses metrics provided by the [bind_exporter](https://github.com/prometheus-community/bind_exporter) |
| Blackbox Exporter | Blackbox exporter dashboard providing various information from the Blackbox Exporter | The blackbox-exporter-mixin uses metrics provided by the [blackbox_exporter](https://github.com/prometheus/blackbox_exporter) |
| Docker | Docker overview dashboard providing various information from cAdvisor | The docker-mixin uses metrics provided by [cAdvisor](https://github.com/google/cadvisor) |
| SMART | SMART overview dashboard providing various information from the smartmon.py text collector | The smart-mixin uses metrics provided by the [smartmon.py](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/smartmon.py) text collector |
| SNMP  | SNMP dashboard providing various information from the SNMP exporter | The snmp-mixin uses metrics provided by the [snmp_exporter](https://github.com/prometheus/snmp_exporter) |

## Generating mixins
The `make generate-mixin` command can be used to generate the dashboard JSON without adding the mixin to a dashboard jsonnet repository. It has a `MIXIN_FILE` variable which should be set to the mixin that you want to generate the dashboards for. The dashboardw will be output into the `gen` directory.
