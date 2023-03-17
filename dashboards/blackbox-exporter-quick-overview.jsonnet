local grafana = import 'grafonnet/grafana.libsonnet';

// Allow datasource to be easily changed for testing
local datasourceToUse = '${DS_PROMETHEUS}';

grafana.dashboard.new(
  'Blackbox Exporter Quick Overview',
  uid='blackbox-exporter-quick-overview',
  tags=['generated', 'blackbox-exporter'],
  schemaVersion=0
).addInput(
  name='DS_PROMETHEUS',
  label='Prometheus',
  type='datasource',
  pluginId='prometheus',
  pluginName='Prometheus'
).addPanel(
  grafana.tablePanel.new(
    'Probes (Up/Down) - Current Status',
    pagination=true
  ).addTarget(
    grafana.prometheus.target(
      'probe_success',
      datasource=datasourceToUse,
      format='table',
      intervalFactor=null,
      instant=true
    )
  ).addTransformation(
    grafana.transformation.new(
      id='organize',
      options={
        excludeByName: {
          Time: true,
          __name__: true,
        },
        indexByName: {},
        renameByName: {
          Value: 'status',
        },
      }
    )
  ).addTransformation(
    grafana.transformation.new(
      id='sortBy',
      options={
        fields: {},
        sort: [
          {
            field: 'Value',
          },
        ],
      }
    )
  ).addThreshold(
    color='red'
  ).addThreshold(
    color='green',
    value='1'
  ).addOverridesForField(
    'Value',
    [
      {
        id: 'custom.cellOptions',
        value: {
          type: 'color-background',
          mode: 'basic',
        },
      },
      {
        id: 'mappings',
        value: [
          {
            type: 'value',
            options: {
              '0': {
                text: 'Down',
                index: 1,
              },
              '1': {
                text: 'Up',
                index: 0,
              },
            },
          },
        ],
      },
    ]
  ),
  gridPos={ x: 0, y: 0, w: 10, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Probes (Up/Down) - Historic Status',
    decimals=0,
    max=1,
    min=0,
    tooltip='all'
  ).addTarget(
    grafana.prometheus.target(
      'probe_success',
      datasource=datasourceToUse,
      legendFormat='{{instance}}'
    )
  ).addValueMapping(
    value='0',
    color='red',
    displayText='Down'
  ).addValueMapping(
    value='1',
    color='green',
    displayText='Up'
  ),
  gridPos={ x: 10, y: 0, w: 14, h: 8 }
).addPanel(
  grafana.tablePanel.new(
    'SSL Certificate Expiry',
    pagination=true
  ).addTarget(
    grafana.prometheus.target(
      'probe_ssl_earliest_cert_expiry-time()',
      datasource=datasourceToUse,
      format='table',
      intervalFactor=null,
      instant=true
    )
  ).addTransformation(
    grafana.transformation.new(
      id='organize',
      options={
        excludeByName: {
          Time: true,
        },
        indexByName: {},
        renameByName: {
          Value: 'time left',
        },
      }
    )
  ).addTransformation(
    grafana.transformation.new(
      id='sortBy',
      options={
        fields: {},
        sort: [
          {
            field: 'time left',
          },
        ],
      }
    )
  ).addThreshold(
    color='red'
  ).addThreshold(
    color='orange',
    value=604800
  ).addThreshold(
    color='green',
    value=2419200
  ).addOverridesForField(
    'time left',
    [
      {
        id: 'unit',
        value: 's',
      },
      {
        id: 'custom.cellOptions',
        value: {
          type: 'color-background',
          mode: 'basic',
        },
      },
    ]
  ),
  gridPos={ x: 0, y: 8, w: 10, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'DNS Lookup',
    tooltip='all',
    unit='s'
  ).addTarget(
    grafana.prometheus.target(
      'probe_dns_lookup_time_seconds',
      datasource=datasourceToUse,
      legendFormat='{{instance}}'
    )
  ),
  gridPos={ x: 10, y: 8, w: 14, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Probe Duration',
    tooltip='all',
    unit='s'
  ).addTarget(
    grafana.prometheus.target(
      'probe_duration_seconds',
      datasource=datasourceToUse,
      legendFormat='{{instance}}'
    )
  ),
  gridPos={ x: 0, y: 16, w: 24, h: 8 }
)
