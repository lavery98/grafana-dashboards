# Grafana dashboards

This repository contains the dashboards that I use on my Grafana instance.
Some have been downloaded from other places, some have been modified to fit my use case and some have been generated from scratch.

They can be imported into Grafana by clicking Import and pasting the JSON into the box. For all the data to appear you will also need to use the right exporter for each dashboard and use the [text collector scripts](https://github.com/lavery98/text-collectors).

## Available dashbords
| Dashboard            | Status    | Changes |
| -------------------- | --------- | ------- |
| [Bind9 Exporter DNS](https://grafana.com/grafana/dashboards/12309-bind9-exporter-dns/) | modified | Removed the queries row and added a zone row |
| Node exporter        |           |         |
| Smart Status         | generated |         |
| Unbound stats        |           |         |
| UPS Status           | generated |         |

## Updating dashboards
Dashboards that do not have a corresponding Jsonnet can be refreshed in this repository by:
1. Clicking the `Share dashboard` button
2. Choosing the export tab
3. Setting the export for sharing externally
4. Hitting the `Save to file` button

## Updating Jsonnet dashboard
Dashboard that have a corresponding Jsonnet can only be updated by modifying the Jsonnet.
Once modified `render-dashboard.sh` can be used to generate the rendered json in the rendered directory.

## Known issues
There is currently an issue with Grafana that prevents the datasource selection from working correctly after importing. This can be fixed by going to the dashboard json and finding and replacing all occurances of the datasource uid with ${DS_PROMETHEUS}