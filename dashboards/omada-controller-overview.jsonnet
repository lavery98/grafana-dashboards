local grafana = import 'grafonnet/grafana.libsonnet';

// Allow datasource to be easily changed for testing
local datasourceToUse = '${DS_PROMETHEUS}';

grafana.dashboard.new(
  'Omada Controller Overview',
  uid='omada-controller',
  tags=['generated', 'omada-exporter'],
  schemaVersion=0,
  refresh='5s'
).addInput(
  name='DS_PROMETHEUS',
  label='Prometheus',
  type='datasource',
  pluginId='prometheus',
  pluginName='Prometheus'
).addTemplate(
  grafana.template.new(
    'device',
    datasourceToUse,
    'omada_device_need_upgrade',
    hide=2,
    regex='device_type="(?<text>[^"]+)|device="(?<value>[^"]+).*',
    refresh=1,
    includeAll=true
  )
).addLink(
  grafana.link.dashboards(
    'Exporter',
    [],
    asDropdown=false,
    url='https://github.com/charlie-haley/omada_exporter',
    targetBlank=true,
    type='link'
  )
).addPanel(
  grafana.row.new(
    'Overview'
  ),
  gridPos={ x: 0, y: 0, w: 24, h: 1 }
).addPanel(
  grafana.statPanel.new(
    'Controller Uptime',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false,
    unit='s'
  ).addTarget(
    grafana.prometheus.target(
      'omada_controller_uptime_seconds',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 0, y: 1, w: 4, h: 2 }
).addPanel(
  grafana.statPanel.new(
    'Connected Clients',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false
  ).addTarget(
    grafana.prometheus.target(
      'omada_client_connected_total',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 4, y: 1, w: 4, h: 2 }
).addPanel(
  grafana.statPanel.new(
    'Clients on 5GHz',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false
  ).addTarget(
    grafana.prometheus.target(
      'count(omada_client_signal_dbm{wifi_mode="5"})',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 8, y: 1, w: 4, h: 2 }
).addPanel(
  grafana.statPanel.new(
    'Clients on 2.4GHz',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false
  ).addTarget(
    grafana.prometheus.target(
      'count(omada_client_signal_dbm{wifi_mode="4"} or omada_client_signal_dbm{wifi_mode="2"})',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 12, y: 1, w: 4, h: 2 }
).addPanel(
  grafana.statPanel.new(
    'Current Receive Rate',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false,
    unit='binBps'
  ).addTarget(
    grafana.prometheus.target(
      'sum(omada_device_rx_rate)',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 16, y: 1, w: 4, h: 2 }
).addPanel(
  grafana.statPanel.new(
    'Current Transmit Rate',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false,
    unit='binBps'
  ).addTarget(
    grafana.prometheus.target(
      'sum(omada_device_tx_rate)',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 20, y: 1, w: 4, h: 2 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Client Download Activity',
    legendPlacement='right',
    unit='binBps'
  ).addTarget(
    grafana.prometheus.target(
      'sum by (client, ip) (omada_client_download_activity_bytes) > 0',
      datasource=datasourceToUse,
      legendFormat='{{client}} - {{ip}}'
    )
  ),
  gridPos={ x: 0, y: 3, w: 24, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Client Signal Strength',
    legendPlacement='right',
    unit='dBm'
  ).addTarget(
    grafana.prometheus.target(
      'sum by (client, ip) (omada_client_signal_dbm)',
      datasource=datasourceToUse,
      legendFormat='{{client}} - {{ip}}'
    )
  ),
  gridPos={ x: 0, y: 11, w: 24, h: 8 }
).addPanel(
  grafana.row.new(
    '$device',
    collapse=true,
    repeat='device'
  ).addPanel(
    grafana.statPanel.new(
      'Device MAC Address',
      colorMode='fixed',
      fields='/^mac$/',
      fixedColor='text',
      sparkLines=false
    ).addTarget(
      grafana.prometheus.target(
        'omada_device_need_upgrade{device="$device"}',
        datasource=datasourceToUse,
        format='table',
        intervalFactor=null,
        instant=true
      )
    ),
    gridPos={ x: 0, y: 20, w: 4, h: 2 }
  ).addPanel(
    grafana.statPanel.new(
      'Device Uptime',
      colorMode='fixed',
      fixedColor='text',
      sparkLines=false,
      unit='s'
    ).addTarget(
      grafana.prometheus.target(
        'omada_device_uptime_seconds{device="$device"}',
        datasource=datasourceToUse,
        intervalFactor=null,
        instant=true
      )
    ),
    gridPos={ x: 4, y: 20, w: 4, h: 2 }
  ).addPanel(
    grafana.statPanel.new(
      'Connected Clients',
      colorMode='fixed',
      fixedColor='text',
      sparkLines=false
    ).addTarget(
      grafana.prometheus.target(
        'count(omada_client_signal_dbm{ap_name="$device"})',
        datasource=datasourceToUse,
        intervalFactor=null,
        instant=true
      )
    ),
    gridPos={ x: 8, y: 20, w: 4, h: 2 }
  ).addPanel(
    grafana.statPanel.new(
      'Clients on 5GHz',
      colorMode='fixed',
      fixedColor='text',
      sparkLines=false
    ).addTarget(
      grafana.prometheus.target(
        'count(omada_client_signal_dbm{ap_name="$device",wifi_mode="5"})',
        datasource=datasourceToUse,
        intervalFactor=null,
        instant=true
      )
    ),
    gridPos={ x: 12, y: 20, w: 4, h: 2 }
  ).addPanel(
    grafana.statPanel.new(
      'Clients on 2.4GHz',
      colorMode='fixed',
      fixedColor='text',
      sparkLines=false
    ).addTarget(
      grafana.prometheus.target(
        'count(omada_client_signal_dbm{ap_name="$device",wifi_mode="4"} or omada_client_signal_dbm{ap_name="$device",wifi_mode="2"})',
        datasource=datasourceToUse,
        intervalFactor=null,
        instant=true
      )
    ),
    gridPos={ x: 16, y: 20, w: 4, h: 2 }
  ).addPanel(
    grafana.timeseriesPanel.new(
      'CPU Usage',
      legendMode='hidden',
      max=100,
      min=0,
      unit='percent'
    ).addTarget(
      grafana.prometheus.target(
        'omada_device_cpu_percentage{device="$device"}',
        datasource=datasourceToUse,
        legendFormat='{{device}}'
      )
    ),
    gridPos={ x: 0, y: 22, w: 12, h: 8 }
  ).addPanel(
    grafana.timeseriesPanel.new(
      'Memory Usage',
      legendMode='hidden',
      max=100,
      min=0,
      unit='percent'
    ).addTarget(
      grafana.prometheus.target(
        'omada_device_mem_percentage{device="$device"}',
        datasource=datasourceToUse,
        legendFormat='{{device}}'
      )
    ),
    gridPos={ x: 12, y: 22, w: 12, h: 8 }
  ).addPanel(
    grafana.timeseriesPanel.new(
      'Network Traffic',
      legendPlacement='right',
      tooltip='all',
      unit='binBps'
    ).addTarget(
      grafana.prometheus.target(
        'omada_device_rx_rate{device="$device"}',
        datasource=datasourceToUse,
        legendFormat='{{device}} receive'
      )
    ).addTarget(
      grafana.prometheus.target(
        '-omada_device_tx_rate{device="$device"}',
        datasource=datasourceToUse,
        legendFormat='{{device}} transmit'
      )
    ),
    gridPos={ x: 0, y: 30, w: 12, h: 8 }
  ).addPanel(
    grafana.timeseriesPanel.new(
      'Client Signal Strength',
      legendPlacement='right',
      unit='dBm'
    ).addTarget(
      grafana.prometheus.target(
        'sum by (client, ip) (omada_client_signal_dbm{ap_name="$device"})',
        datasource=datasourceToUse,
        legendFormat='{{client}} - {{ip}}'
      )
    ),
    gridPos={ x: 12, y: 30, w: 12, h: 8 }
  ),
  gridPos={ x: 0, y: 19, w: 24, h: 1 }
)
