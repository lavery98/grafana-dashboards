local grafana = import 'grafonnet/grafana.libsonnet';

grafana.dashboard.new(
  'S.M.A.R.T Status',
  uid='smart-status',
  tags=['generated'],
  schemaVersion=0
).addTemplate(
  grafana.template.datasource(
    'datasource',
    'prometheus',
    'Mimir'
  )
).addTemplate(
  grafana.template.new(
    'cluster',
    '$datasource',
    'label_values(node_exporter_build_info, cluster)',
    allValues='.+',
    includeAll=true,
    multi=true,
    sort=2
  )
).addTemplate(
  grafana.template.new(
    'namespace',
    '$datasource',
    'label_values(node_exporter_build_info{cluster=~"$cluster"}, namespace)',
    allValues='.+',
    includeAll=true,
    multi=true,
    sort=2
  )
).addTemplate(
  grafana.template.new(
    'host',
    '$datasource',
    'label_values(node_exporter_build_info{cluster=~"$cluster", namespace=~"$namespace"}, host)',
    sort=2
  )
).addPanel(
  grafana.row.new(
    title='Overview'
  ),
  gridPos={ x: 0, y: 0, w: 24, h: 1 }
).addPanel(
  grafana.statPanel.new(
    'Disks Monitored',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false
  ).addTarget(
    grafana.prometheus.target(
      'sum(smartmon_device_active{cluster=~"$cluster", namespace=~"$namespace", host="$host"})',
      datasource='$datasource',
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 0, y: 1, w: 4, h: 4 }
).addPanel(
  grafana.statPanel.new(
    'Unhealthy Disks',
    colorMode='thresholds',
    colorStyle='background',
    sparkLines=false
  ).addTarget(
    grafana.prometheus.target(
      'sum(smartmon_device_smart_enabled{cluster=~"$cluster", namespace=~"$namespace", host="$host"})-sum(smartmon_device_smart_healthy{cluster=~"$cluster", namespace=~"$namespace", host="$host"})',
      datasource='$datasource',
      intervalFactor=null,
      instant=true
    )
  ).addThreshold(
    'green'
  ).addThreshold(
    'red',
    value=1
  ),
  gridPos={ x: 0, y: 5, w: 4, h: 4 }
).addPanel(
  grafana.tablePanel.new(
    'Disk Drives'
  ).addTarget(
    grafana.prometheus.target(
      'smartmon_device_info{cluster=~"$cluster", namespace=~"$namespace", host="$host"}',
      datasource='$datasource',
      intervalFactor=null,
      instant=true,
      format='table'
    )
  ).addTransformation(
    grafana.transformation.new(
      id='groupBy',
      options={
        fields: {
          device: {
            aggregations: [],
            operation: 'groupby',
          },
          device_model: {
            aggregations: [
              'lastNotNull',
            ],
            operation: 'aggregate',
          },
          disk: {
            aggregations: [],
            operation: 'groupby',
          },
          firmware_version: {
            aggregations: [
              'lastNotNull',
            ],
            operation: 'aggregate',
          },
          model_family: {
            aggregations: [
              'lastNotNull',
            ],
            operation: 'aggregate',
          },
          serial_number: {
            aggregations: [
              'lastNotNull',
            ],
            operation: 'aggregate',
          },
        },
      }
    )
  ),
  gridPos={ x: 4, y: 1, w: 20, h: 8 }
).addPanel(
  grafana.row.new(
    title='Temperature',
    collapse=true
  ).addPanel(
    grafana.timeseriesPanel.new(
      'Temperature History',
      legendMode='table',
      legendPlacement='right',
      legendValues=['mean', 'min', 'max', 'last']
    ).addTarget(
      grafana.prometheus.target(
        'smartmon_attr_raw_value{name="temperature_celsius",cluster=~"$cluster", namespace=~"$namespace", host="$host"}',
        datasource='$datasource',
        legendFormat='{{device}} {{disk}}'
      )
    ),
    gridPos={ x: 0, y: 10, w: 24, h: 8 }
  ),
  gridPos={ x: 0, y: 9, w: 24, h: 1 }
).addPanel(
  grafana.row.new(
    title='Wear & Tear',
    collapse=true
  ).addPanel(
    grafana.barGaugePanel.new(
      'Power On Hours',
      thresholds=[
        {
          color: 'green',
          value: null,
        },
        {
          color: 'orange',
          value: 17520,
        },
        {
          color: 'red',
          value: 35040,
        },
      ],
      unit='h'
    ).addTarget(
      grafana.prometheus.target(
        'smartmon_attr_raw_value{name="power_on_hours",cluster=~"$cluster", namespace=~"$namespace", host="$host"}',
        datasource='$datasource',
        intervalFactor=null,
        instant=true,
        legendFormat='{{device}} {{disk}}'
      )
    ) + {
      fieldConfig+: {
        defaults+: {
          min: 0,
        },
      },
      options+: {
        displayMode: 'gradient',
        orientation: 'horizontal',
      },
    },
    gridPos={ x: 0, y: 19, w: 12, h: 8 }
  ).addPanel(
    grafana.barGaugePanel.new(
      'Start Stop Count',
      thresholds=[
        {
          color: 'green',
          value: null,
        },
        {
          color: 'orange',
          value: 750,
        },
        {
          color: 'red',
          value: 1500,
        },
      ]
    ).addTarget(
      grafana.prometheus.target(
        'smartmon_attr_raw_value{name="start_stop_count",cluster=~"$cluster", namespace=~"$namespace", host="$host"}',
        datasource='$datasource',
        intervalFactor=null,
        instant=true,
        legendFormat='{{device}} {{disk}}'
      )
    ) + {
      fieldConfig+: {
        defaults+: {
          min: 0,
        },
      },
      options+: {
        displayMode: 'gradient',
        orientation: 'horizontal',
      },
    },
    gridPos={ x: 12, y: 19, w: 12, h: 8 }
  ).addPanel(
    grafana.barGaugePanel.new(
      'Power Cycle Count',
      thresholds=[
        {
          color: 'green',
          value: null,
        },
        {
          color: 'orange',
          value: 1000,
        },
        {
          color: 'red',
          value: 2000,
        },
      ]
    ).addTarget(
      grafana.prometheus.target(
        'smartmon_attr_raw_value{name="power_cycle_count",cluster=~"$cluster", namespace=~"$namespace", host="$host"}',
        datasource='$datasource',
        intervalFactor=null,
        instant=true,
        legendFormat='{{device}} {{disk}}'
      )
    ) + {
      fieldConfig+: {
        defaults+: {
          min: 0,
        },
      },
      options+: {
        displayMode: 'gradient',
        orientation: 'horizontal',
      },
    },
    gridPos={ x: 0, y: 27, w: 12, h: 8 }
  ).addPanel(
    grafana.barGaugePanel.new(
      'Load Cycle Count',
      thresholds=[
        {
          color: 'green',
          value: null,
        },
        {
          color: 'orange',
          value: 5000,
        },
        {
          color: 'red',
          value: 10000,
        },
      ]
    ).addTarget(
      grafana.prometheus.target(
        'smartmon_attr_raw_value{name="load_cycle_count",cluster=~"$cluster", namespace=~"$namespace", host="$host"}',
        datasource='$datasource',
        intervalFactor=null,
        instant=true,
        legendFormat='{{device}} {{disk}}'
      )
    ) + {
      fieldConfig+: {
        defaults+: {
          min: 0,
        },
      },
      options+: {
        displayMode: 'gradient',
        orientation: 'horizontal',
      },
    },
    gridPos={ x: 12, y: 27, w: 12, h: 8 }
  ).addPanel(
    grafana.barGaugePanel.new(
      'Total Data Written',
      description='Please note: This may be slightly incorrect',
      thresholds=[
        {
          color: 'green',
          value: null,
        },
        {
          color: 'orange',
          value: 40000000000000,
        },
        {
          color: 'red',
          value: 60000000000000,
        },
      ],
      unit='decbytes'
    ).addTarget(
      grafana.prometheus.target(
        'smartmon_attr_raw_value{name="total_lbas_written",cluster=~"$cluster", namespace=~"$namespace", host="$host"}*512',
        datasource='$datasource',
        intervalFactor=null,
        instant=true,
        legendFormat='{{device}} {{disk}}'
      )
    ) + {
      fieldConfig+: {
        defaults+: {
          min: 0,
        },
      },
      options+: {
        displayMode: 'gradient',
        orientation: 'horizontal',
      },
    },
    gridPos={ x: 0, y: 35, w: 12, h: 8 }
  ).addPanel(
    grafana.barGaugePanel.new(
      'Reasslocated Sector Events',
      thresholds=[
        {
          color: 'green',
          value: null,
        },
        {
          color: 'red',
          value: 1,
        },
      ]
    ).addTarget(
      grafana.prometheus.target(
        'smartmon_attr_raw_value{name="reallocated_event_count",cluster=~"$cluster", namespace=~"$namespace", host="$host"}',
        datasource='$datasource',
        intervalFactor=null,
        instant=true,
        legendFormat='{{device}} {{disk}}'
      )
    ) + {
      fieldConfig+: {
        defaults+: {
          min: 0,
        },
      },
      options+: {
        displayMode: 'gradient',
        orientation: 'horizontal',
      },
    },
    gridPos={ x: 12, y: 35, w: 12, h: 8 }
  ),
  gridPos={ x: 0, y: 18, w: 24, h: 1 }
).addPanel(
  grafana.row.new(
    title='Errors',
    collapse=true
  ).addPanel(
    grafana.barGaugePanel.new(
      'Raw Read Error',
      thresholds=[
        {
          color: 'red',
          value: null,
        },
        {
          color: 'green',
          value: 100,
        },
      ],
      unit='percent'
    ).addTarget(
      grafana.prometheus.target(
        'smartmon_attr_value{name="raw_read_error_rate",cluster=~"$cluster", namespace=~"$namespace", host="$host"}',
        datasource='$datasource',
        intervalFactor=null,
        instant=true,
        legendFormat='{{device}} {{disk}}'
      )
    ) + {
      fieldConfig+: {
        defaults+: {
          min: 0,
        },
      },
      options+: {
        displayMode: 'gradient',
        orientation: 'horizontal',
      },
    },
    gridPos={ x: 0, y: 44, w: 12, h: 8 }
  ).addPanel(
    grafana.barGaugePanel.new(
      'Seek Error Rate',
      thresholds=[
        {
          color: 'red',
          value: null,
        },
        {
          color: 'orange',
          value: 30,
        }
        {
          color: 'green',
          value: 60,
        },
      ]
    ).addTarget(
      grafana.prometheus.target(
        'smartmon_attr_value{name="seek_error_rate",cluster=~"$cluster", namespace=~"$namespace", host="$host"}',
        datasource='$datasource',
        intervalFactor=null,
        instant=true,
        legendFormat='{{device}} {{disk}}'
      )
    ) + {
      fieldConfig+: {
        defaults+: {
          min: 0,
        },
      },
      options+: {
        displayMode: 'gradient',
        orientation: 'horizontal',
      },
    },
    gridPos={ x: 12, y: 44, w: 12, h: 8 }
  ).addPanel(
    grafana.barGaugePanel.new(
      'Spin Retry Count',
      thresholds=[
        {
          color: 'green',
          value: null,
        },
        {
          color: 'orange',
          value: 1,
        },
        {
          color: 'red',
          value: 10,
        },
      ]
    ).addTarget(
      grafana.prometheus.target(
        'smartmon_attr_raw_value{name="spin_retry_count",cluster=~"$cluster", namespace=~"$namespace", host="$host"}',
        datasource='$datasource',
        intervalFactor=null,
        instant=true,
        legendFormat='{{device}} {{disk}}'
      )
    ) + {
      fieldConfig+: {
        defaults+: {
          min: 0,
        },
      },
      options+: {
        displayMode: 'gradient',
        orientation: 'horizontal',
      },
    },
    gridPos={ x: 0, y: 52, w: 12, h: 8 }
  ).addPanel(
    grafana.barGaugePanel.new(
      'Command Timeout Count',
      thresholds=[
        {
          color: 'green',
          value: null,
        },
        {
          color: 'orange',
          value: 1,
        },
        {
          color: 'red',
          value: 10,
        },
      ]
    ).addTarget(
      grafana.prometheus.target(
        'smartmon_attr_raw_value{name="command_timeout",cluster=~"$cluster", namespace=~"$namespace", host="$host"}',
        datasource='$datasource',
        intervalFactor=null,
        instant=true,
        legendFormat='{{device}} {{disk}}'
      )
    ) + {
      fieldConfig+: {
        defaults+: {
          min: 0,
        },
      },
      options+: {
        displayMode: 'gradient',
        orientation: 'horizontal',
      },
    },
    gridPos={ x: 12, y: 52, w: 12, h: 8 }
  ).addPanel(
    grafana.barGaugePanel.new(
      'Current Pending Sector Count',
      thresholds=[
        {
          color: 'green',
          value: null,
        },
        {
          color: 'orange',
          value: 1,
        },
        {
          color: 'red',
          value: 10,
        },
      ]
    ).addTarget(
      grafana.prometheus.target(
        'smartmon_attr_raw_value{name="current_pending_sector",cluster=~"$cluster", namespace=~"$namespace", host="$host"}',
        datasource='$datasource',
        intervalFactor=null,
        instant=true,
        legendFormat='{{device}} {{disk}}'
      )
    ) + {
      fieldConfig+: {
        defaults+: {
          min: 0,
        },
      },
      options+: {
        displayMode: 'gradient',
        orientation: 'horizontal',
      },
    },
    gridPos={ x: 0, y: 60, w: 12, h: 8 }
  ).addPanel(
    grafana.barGaugePanel.new(
      'Offline Uncorrectable Sector Count',
      thresholds=[
        {
          color: 'green',
          value: null,
        },
        {
          color: 'orange',
          value: 1,
        },
        {
          color: 'red',
          value: 10,
        },
      ]
    ).addTarget(
      grafana.prometheus.target(
        'smartmon_attr_raw_value{name="offline_uncorrectable",cluster=~"$cluster", namespace=~"$namespace", host="$host"}',
        datasource='$datasource',
        intervalFactor=null,
        instant=true,
        legendFormat='{{device}} {{disk}}'
      )
    ) + {
      fieldConfig+: {
        defaults+: {
          min: 0,
        },
      },
      options+: {
        displayMode: 'gradient',
        orientation: 'horizontal',
      },
    },
    gridPos={ x: 12, y: 60, w: 12, h: 8 }
  ).addPanel(
    grafana.barGaugePanel.new(
      'Reported Uncorrectable Errors',
      thresholds=[
        {
          color: 'green',
          value: null,
        },
        {
          color: 'orange',
          value: 1,
        },
        {
          color: 'red',
          value: 10,
        },
      ]
    ).addTarget(
      grafana.prometheus.target(
        'smartmon_attr_raw_value{name="reported_uncorrect",cluster=~"$cluster", namespace=~"$namespace", host="$host"}',
        datasource='$datasource',
        intervalFactor=null,
        instant=true,
        legendFormat='{{device}} {{disk}}'
      )
    ) + {
      fieldConfig+: {
        defaults+: {
          min: 0,
        },
      },
      options+: {
        displayMode: 'gradient',
        orientation: 'horizontal',
      },
    },
    gridPos={ x: 0, y: 68, w: 12, h: 8 }
  ).addPanel(
    grafana.barGaugePanel.new(
      'UltraDMA CRC Error',
      thresholds=[
        {
          color: 'green',
          value: null,
        },
        {
          color: 'red',
          value: 1,
        },
      ]
    ).addTarget(
      grafana.prometheus.target(
        'smartmon_attr_raw_value{name="udma_crc_error_count",cluster=~"$cluster", namespace=~"$namespace", host="$host"}',
        datasource='$datasource',
        intervalFactor=null,
        instant=true,
        legendFormat='{{device}} {{disk}}'
      )
    ) + {
      fieldConfig+: {
        defaults+: {
          min: 0,
        },
      },
      options+: {
        displayMode: 'gradient',
        orientation: 'horizontal',
      },
    },
    gridPos={ x: 12, y: 68, w: 12, h: 8 }
  ),
  gridPos={ x: 0, y: 43, w: 24, h: 1 }
)
