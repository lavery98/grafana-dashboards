# Grafana dashboards

This repository contains dashboards that I have created/modified for Grafana.

They can be imported into Grafana by clicking Import and pasting the JSON into the box. For all the data to appear you will also need to use the right exporter for each dashboard and use the [text collector scripts](https://github.com/lavery98/text-collectors).

## Known issues
There is currently an issue with Grafana that prevents the datasource selection from working correctly after importing. This can be fixed by going to the dashboard json and finding and replacing all occurances of the datasource uid with ${DS_PROMETHEUS}