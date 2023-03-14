local grafana = import 'grafonnet/grafana.libsonnet';
local stateTimelinePanel = import 'state-timeline-panel.libsonnet';

// Allow datasource to be easily changed for testing
local datasourceToUse = '${DS_PROMETHEUS}';

grafana.dashboard.new(
  'Bind9 Exporter',
  uid='bind9-exporter',
  tags=['generated', 'bind-exporter', 'dns'],
  schemaVersion=0
).addInput(
  name='DS_PROMETHEUS',
  label='Prometheus',
  type='datasource',
  pluginId='prometheus',
  pluginName='Prometheus'
).addTemplate(
  grafana.template.new(
    name='job',
    label='Job',
    datasource=datasourceToUse,
    query='label_values(bind_up, job)',
    sort=1
  )
).addTemplate(
  grafana.template.new(
    name='instance',
    datasource=datasourceToUse,
    query='label_values(bind_up{job="$job"}, instance)',
    hide=2
  )
).addPanel(
  grafana.row.new(
    title='System'
  ),
  gridPos={ x: 0, y: 0, w: 24, h: 1 }
).addPanel(
  grafana.statPanel.new(
    'Last Restarted',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false,
    unit='s'
  ).addTarget(
    grafana.prometheus.target(
      '${__to:date:seconds} - max(bind_boot_time_seconds{job="$job",instance="$instance"})',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 0, y: 1, w: 6, h: 4 }
).addPanel(
  grafana.statPanel.new(
    'Last Reconfigured',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false,
    unit='s'
  ).addTarget(
    grafana.prometheus.target(
      '${__to:date:seconds} - max(bind_config_time_seconds{job="$job",instance="$instance"})',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 6, y: 1, w: 6, h: 4 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Named CPU Time',
    legendMode='hidden',
    unit='s'
  ).addTarget(
    grafana.prometheus.target(
      'increase(process_cpu_seconds_total{job="$job",instance="$instance"}[120s])',
      datasource=datasourceToUse,
      legendFormat='CPU Time'
    )
  ),
  gridPos={ x: 12, y: 1, w: 12, h: 4 }
).addPanel(
  grafana.timeseriesPanel.new(
    'File Descriptors',
    fillOpacity=10,
    tooltip='all',
    unit='short'
  ).addTarget(
    grafana.prometheus.target(
      'process_max_fds{instance="$instance",job="$job"}',
      datasource=datasourceToUse,
      legendFormat='Max'
    )
  ).addTarget(
    grafana.prometheus.target(
      'process_open_fds{instance="$instance",job="$job"}',
      datasource=datasourceToUse,
      legendFormat='Open'
    )
  ).addOverridesForField(
    'Max',
    [grafana.timeseriesPanel.overrides.fillOpacity(0)]
  ),
  gridPos={ x: 0, y: 5, w: 12, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Memory',
    fillOpacity=20,
    tooltip='all',
    unit='bytes'
  ).addTarget(
    grafana.prometheus.target(
      'process_virtual_memory_bytes{instance="$instance",job="$job"}',
      datasource=datasourceToUse,
      legendFormat='Virtual'
    )
  ).addTarget(
    grafana.prometheus.target(
      'process_resident_memory_bytes{instance="$instance",job="$job"}',
      datasource=datasourceToUse,
      legendFormat='Resident'
    )
  ).addOverridesForField(
    'Virtual',
    [grafana.timeseriesPanel.overrides.fixedColor('#0A437C')]
  ).addOverridesForField(
    'Resident',
    [grafana.timeseriesPanel.overrides.fixedColor('#890F02')]
  ),
  gridPos={ x: 12, y: 5, w: 12, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Queries',
    fillOpacity=10,
    stackSeries='normal',
    tooltip='all'
  ).addTarget(
    grafana.prometheus.target(
      'increase(bind_query_duplicates_total{instance="$instance",job="$job"}[120s])',
      datasource=datasourceToUse,
      legendFormat='Duplicates'
    )
  ).addTarget(
    grafana.prometheus.target(
      'increase(bind_query_errors_total{instance="$instance",job="$job"}[120s])',
      datasource=datasourceToUse,
      legendFormat='{{error}}'
    )
  ).addTarget(
    grafana.prometheus.target(
      'increase(bind_query_recursions_total{instance="$instance",job="$job"}[120s])',
      datasource=datasourceToUse,
      legendFormat='Recursions'
    )
  ),
  gridPos={ x: 0, y: 13, w: 24, h: 8 }
).addPanel(
  grafana.row.new(
    'Incoming',
    collapse=true
  ).addPanel(
    grafana.timeseriesPanel.new(
      'Incoming Queries',
      fillOpacity=10,
      stackSeries='normal',
      tooltip='all'
    ).addTarget(
      grafana.prometheus.target(
        'increase(bind_incoming_queries_total{instance="$instance",job="$job"}[120s])',
        datasource=datasourceToUse,
        legendFormat='{{type}}'
      )
    ),
    gridPos={ x: 0, y: 21, w: 12, h: 8 }
  ).addPanel(
    grafana.timeseriesPanel.new(
      'Incoming Request Opcodes',
      fillOpacity=10,
      stackSeries='normal',
      tooltip='all'
    ).addTarget(
      grafana.prometheus.target(
        'increase(bind_incoming_requests_total{instance="$instance",job="$job"}[120s])',
        datasource=datasourceToUse,
        legendFormat='{{opcode}}'
      )
    ),
    gridPos={ x: 12, y: 21, w: 12, h: 8 }
  ).addPanel(
    grafana.timeseriesPanel.new(
      'Response Results',
      fillOpacity=10,
      stackSeries='normal',
      tooltip='all'
    ).addTarget(
      grafana.prometheus.target(
        'increase(bind_responses_total{instance="$instance",job="$job"}[120s])',
        datasource=datasourceToUse,
        legendFormat='{{result}}'
      )
    ),
    gridPos={ x: 0, y: 29, w: 24, h: 8 }
  ),
  gridPos={ x: 0, y: 21, w: 24, h: 1 }
).addPanel(
  grafana.row.new(
    'Zone',
    collapse=true
  ).addPanel(
    grafana.tablePanel.new(
      'Zone Serials'
    ).addTarget(
      grafana.prometheus.target(
        'bind_zone_serial{instance="$instance",job="$job"}',
        datasource=datasourceToUse,
        format='table',
        intervalFactor=null,
        instant=true
      )
    ).addTransformation(
      grafana.transformation.new(
        'organize',
        {
          excludeByName: {
            Time: true,
            __name__: true,
            instance: true,
            job: true,
            view: true,
          },
          indexByName: {},
          renameByName: {
            Value: 'SOA Serial',
            zone_name: 'Zone',
          },
        }
      )
    ).addTransformation(
      grafana.transformation.new(
        'filterByValue',
        {
          filters: [
            {
              config: {
                id: 'greater',
                options: {
                  value: 1000,
                },
              },
              fieldName: 'SOA Serial',
            },
          ],
          match: 'any',
          type: 'include',
        }
      )
    ),
    gridPos={ x: 0, y: 38, w: 6, h: 8 }
  ).addPanel(
    grafana.timeseriesPanel.new(
      'Zone Serial Changes',
      fillOpacity=10,
      stackSeries='normal',
      tooltip='all'
    ).addTarget(
      grafana.prometheus.target(
        'rate(bind_zone_serial{instance="$instance",job="$job"}[$__rate_interval])',
        datasource=datasourceToUse,
        legendFormat='{{zone_name}}'
      )
    ),
    gridPos={ x: 6, y: 38, w: 18, h: 8 }
  ).addPanel(
    stateTimelinePanel.new(
      'Failed Zone Transfers',
      colorMode='thresholds',
      displayName='-',
      fillOpacity=70,
      legendMode='hidden',
      showValue='never',
      tooltip='hidden'
    ).addTarget(
      grafana.prometheus.target(
        'rate(bind_zone_transfer_failure_total{instance="$instance",job="$job"}[$__rate_interval])',
        datasource=datasourceToUse,
        legendFormat='',
        intervalFactor=null
      )
    ).addThreshold(
      'green'
    ).addThreshold(
      'red',
      value=0.0001
    ),
    gridPos={ x: 0, y: 46, w: 12, h: 8 }
  ).addPanel(
    stateTimelinePanel.new(
      'Rejected Zone Transfers',
      colorMode='thresholds',
      displayName='-',
      fillOpacity=70,
      legendMode='hidden',
      showValue='never',
      tooltip='hidden'
    ).addTarget(
      grafana.prometheus.target(
        'rate(bind_zone_transfer_rejected_total{instance="$instance",job="$job"}[$__rate_interval])',
        datasource=datasourceToUse,
        legendFormat='',
        intervalFactor=null
      )
    ).addThreshold(
      'green'
    ).addThreshold(
      'red',
      value=0.0001
    ),
    gridPos={ x: 12, y: 46, w: 12, h: 8 }
  ),
  gridPos={ x: 0, y: 37, w: 24, h: 1 }
)
