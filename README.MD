# Grafana dashboards

This repository contains dashboards that I have created/modified for Grafana.

They can be imported into Grafana by clicking Import and pasting the JSON into the box. For all the data to appear you will also need to use the right exporter for each dashboard and use the [text collector scripts](https://github.com/lavery98/text-collectors).

## Available dashbords
| Dashboard            | Status   | Changes |
| -------------------- | -------- | ------- |
| Node exporter        |          |         |
| [Prometheus 2.0 stats](https://grafana.com/grafana/dashboards/15489-prometheus-2-0-stats/) | modified | Updated Graph(old) panels to time series |
| Smart Monitor        |          |         |
| Unbound stats        |          |         |

## Updating dashboards
Dashboards can be refreshed in this repository by:
1. Clicking the `Share dashboard` button
2. Choosing the export tab
3. Setting the export for sharing externally
4. Hitting the `Save to file` button

## Known issues
There is currently an issue with Grafana that prevents the datasource selection from working correctly after importing. This can be fixed by going to the dashboard json and finding and replacing all occurances of the datasource uid with ${DS_PROMETHEUS}