local grafana = import 'grafonnet/grafana.libsonnet';

// Allow datasource to be easily changed for testing
local datasourceToUse = '${DS_PROMETHEUS}';

grafana.dashboard.new(
  'Docker Overview',
  uid='docker-overview',
  tags=['generated', 'docker'],
  schemaVersion=0
).addInput(
  name='DS_PROMETHEUS',
  label='Prometheus',
  type='datasource',
  pluginId='prometheus',
  pluginName='Prometheus'
).addPanel(
  grafana.statPanel.new(
    'Containers',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false
  ).addTarget(
    grafana.prometheus.target(
      'count(container_start_time_seconds{name=~".+"})',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 0, y: 0, w: 4, h: 4 }
).addPanel(
  grafana.statPanel.new(
    'Total CPU Usage',
    unit='percent'
  ).addTarget(
    grafana.prometheus.target(
      'sum(rate(container_cpu_usage_seconds_total{name=~".+"}[$__rate_interval]))  * 100',
      datasource=datasourceToUse
    )
  ),
  gridPos={ x: 4, y: 0, w: 4, h: 4 }
).addPanel(
  grafana.statPanel.new(
    'Total Memory Usage',
    unit='bytes'
  ).addTarget(
    grafana.prometheus.target(
      'sum(container_memory_rss{name=~".+"})',
      datasource=datasourceToUse
    )
  ),
  gridPos={ x: 8, y: 0, w: 4, h: 4 }
).addPanel(
  grafana.statPanel.new(
    'Total Swap Usage',
    unit='bytes'
  ).addTarget(
    grafana.prometheus.target(
      'sum(container_memory_swap{name=~".+"})',
      datasource=datasourceToUse
    )
  ),
  gridPos={ x: 12, y: 0, w: 4, h: 4 }
).addPanel(
  grafana.statPanel.new(
    'Total Received Network Traffic',
    unit='Bps'
  ).addTarget(
    grafana.prometheus.target(
      'sum(rate(container_network_receive_bytes_total{name=~".+"}[$__rate_interval]))',
      datasource=datasourceToUse
    )
  ),
  gridPos={ x: 16, y: 0, w: 4, h: 4 }
).addPanel(
  grafana.statPanel.new(
    'Total Sent Network Traffic',
    unit='Bps'
  ).addTarget(
    grafana.prometheus.target(
      'sum(rate(container_network_transmit_bytes_total{name=~".+"}[$__rate_interval]))',
      datasource=datasourceToUse
    )
  ),
  gridPos={ x: 20, y: 0, w: 4, h: 4 }
).addPanel(
  grafana.timeseriesPanel.new(
    'CPU Usage per Container',
    legendPlacement='right',
    fillOpacity='20',
    stackSeries='normal',
    tooltip='all',
    tooltipSort='descending',
    unit='percent'
  ).addTarget(
    grafana.prometheus.target(
      'sum(rate(container_cpu_usage_seconds_total{name=~".+"}[$__rate_interval])) by (name) * 100',
      datasource=datasourceToUse,
      legendFormat='{{name}}'
    )
  ),
  gridPos={ x: 0, y: 4, w: 12, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Memory Usage per Container',
    legendPlacement='right',
    fillOpacity='20',
    stackSeries='normal',
    tooltip='all',
    tooltipSort='descending',
    unit='bytes'
  ).addTarget(
    grafana.prometheus.target(
      'sum(container_memory_rss{name=~".+"}) by (name)',
      datasource=datasourceToUse,
      legendFormat='{{name}}'
    )
  ),
  gridPos={ x: 12, y: 4, w: 12, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Received Network Traffic per Container',
    legendPlacement='right',
    fillOpacity='20',
    stackSeries='normal',
    tooltip='all',
    tooltipSort='descending',
    unit='Bps'
  ).addTarget(
    grafana.prometheus.target(
      'sum(rate(container_network_receive_bytes_total{name=~".+"}[$__rate_interval])) by (name)',
      datasource=datasourceToUse,
      legendFormat='{{name}}'
    )
  ),
  gridPos={ x: 0, y: 12, w: 12, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Sent Network Traffic per Container',
    legendPlacement='right',
    fillOpacity='20',
    stackSeries='normal',
    tooltip='all',
    tooltipSort='descending',
    unit='Bps'
  ).addTarget(
    grafana.prometheus.target(
      'sum(rate(container_network_transmit_bytes_total{name=~".+"}[$__rate_interval])) by (name)',
      datasource=datasourceToUse,
      legendFormat='{{name}}'
    )
  ),
  gridPos={ x: 12, y: 12, w: 12, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Filesystem Reads per container',
    legendPlacement='right',
    fillOpacity='20',
    stackSeries='normal',
    tooltip='all',
    tooltipSort='descending',
    unit='Bps'
  ).addTarget(
    grafana.prometheus.target(
      'sum(rate(container_fs_reads_bytes_total{name=~".+"}[$__rate_interval])) by (name)',
      datasource=datasourceToUse,
      legendFormat='{{name}}'
    )
  ),
  gridPos={ x: 0, y: 20, w: 12, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Filesystem Writes per container',
    legendPlacement='right',
    fillOpacity='20',
    stackSeries='normal',
    tooltip='all',
    tooltipSort='descending',
    unit='Bps'
  ).addTarget(
    grafana.prometheus.target(
      'sum(rate(container_fs_writes_bytes_total{name=~".+"}[$__rate_interval])) by (name)',
      datasource=datasourceToUse,
      legendFormat='{{name}}'
    )
  ),
  gridPos={ x: 12, y: 20, w: 12, h: 8 }
)
