# Grafana dashboards

This repository contains the dashboards that I use on my Grafana instance.
Some have been downloaded from other places, some have been modified to fit my use case and some have been generated from scratch.
Where Jsonnet is used, [Grafonnet](https://github.com/grafana/grafonnet) is used to provide grafana panels.

They can be imported into Grafana by clicking Import and pasting the JSON into the box. For all the data to appear you will also need to use the right exporter for each dashboard and use the [text collector scripts](https://github.com/lavery98/text-collectors).

## Available dashbords
| Dashboard                  | Status    | Changes |
| -------------------------- | --------- | ------- |
| Bind Overview              | generated |         |
| Blackbox Exporter Overview | generated |         |
| Dnsmasq Overview           | generated |         |
| Docker Overview            | generated |         |
| [Node Exporter](https://grafana.com/grafana/dashboards/1860)              | modified | Added disk labels, lvm storage amounts, fan speed and hardware voltages. Modified from original using jsonnet |
| Smart Overview             | generated |         |
| SNMP Interface Status      | generated |         |
| UPS Overview               | generated |         |

## Updating dashboards
Dashboards that do not have a corresponding Jsonnet can be refreshed in this repository by:
1. Clicking the `Share dashboard` button
2. Choosing the export tab
3. Setting the export for sharing externally
4. Hitting the `Save to file` button

## Updating Jsonnet dashboards
Dashboards that have a corresponding Jsonnet can only be updated by modifying the Jsonnet.
Once modified `make generate` can be used to generate the rendered json in the gen directory.
