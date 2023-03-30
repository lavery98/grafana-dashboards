local grafana = import 'grafonnet/grafana.libsonnet';

// Allow datasource to be easily changed for testing
local datasourceToUse = '${DS_PROMETHEUS}';

grafana.dashboard.new(
  'Power Usage Overview',
  uid='power-usage-overview',
  tags=['generated'],
  schemaVersion=0
).addInput(
  name='DS_PROMETHEUS',
  label='Prometheus',
  type='datasource',
  pluginId='prometheus',
  pluginName='Prometheus'
).addPanel(
  grafana.row.new(
    'Overview'
  ),
  gridPos={ x: 0, y: 0, w: 24, h: 1 }
).addPanel(
  grafana.statPanel.new(
    'Current voltage',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false,
    unit='volt'
  ).addTarget(
    grafana.prometheus.target(
      'avg(homeassistant_sensor_voltage_v)',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 0, y: 1, w: 4, h: 4 }
).addPanel(
  grafana.statPanel.new(
    'Total Amps',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false,
    unit='amp'
  ).addTarget(
    grafana.prometheus.target(
      'sum(homeassistant_sensor_current_a)',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 4, y: 1, w: 4, h: 4 }
).addPanel(
  grafana.statPanel.new(
    'Total Power',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false,
    unit='watt'
  ).addTarget(
    grafana.prometheus.target(
      'sum(homeassistant_sensor_power_w)',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 8, y: 1, w: 4, h: 4 }
).addPanel(
  grafana.statPanel.new(
    'Total Apparent Power',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false,
    unit='voltamp'
  ).addTarget(
    grafana.prometheus.target(
      'sum(homeassistant_sensor_apparent_power_va)',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 12, y: 1, w: 4, h: 4 }
).addPanel(
  grafana.statPanel.new(
    'Total Reactive Power',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false,
    unit='voltampreact'
  ).addTarget(
    grafana.prometheus.target(
      'sum(homeassistant_sensor_reactive_power_var)',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 16, y: 1, w: 4, h: 4 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Voltage',
    legendPlacement='right',
    tooltip='all',
    unit='volt'
  ).addTarget(
    grafana.prometheus.target(
      'homeassistant_sensor_voltage_v',
      datasource=datasourceToUse,
      legendFormat='{{friendly_name}}'
    )
  ),
  gridPos={ x: 0, y: 5, w: 12, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Amps',
    legendPlacement='right',
    tooltip='all',
    unit='amp'
  ).addTarget(
    grafana.prometheus.target(
      'homeassistant_sensor_current_a',
      datasource=datasourceToUse,
      legendFormat='{{friendly_name}}'
    )
  ),
  gridPos={ x: 12, y: 5, w: 12, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Power',
    legendPlacement='right',
    tooltip='all',
    unit='watt'
  ).addTarget(
    grafana.prometheus.target(
      'homeassistant_sensor_power_w',
      datasource=datasourceToUse,
      legendFormat='{{friendly_name}}'
    )
  ),
  gridPos={ x: 0, y: 13, w: 12, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Power Factor',
    legendPlacement='right',
    max=1,
    min=0,
    tooltip='all'
  ).addTarget(
    grafana.prometheus.target(
      'homeassistant_sensor_power_factor_None',
      datasource=datasourceToUse,
      legendFormat='{{friendly_name}}'
    )
  ),
  gridPos={ x: 12, y: 13, w: 12, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Apparent Factor',
    legendPlacement='right',
    tooltip='all',
    unit='voltamp'
  ).addTarget(
    grafana.prometheus.target(
      'homeassistant_sensor_apparent_power_va',
      datasource=datasourceToUse,
      legendFormat='{{friendly_name}}'
    )
  ),
  gridPos={ x: 0, y: 21, w: 12, h: 8 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Reactive Factor',
    legendPlacement='right',
    tooltip='all',
    unit='voltampreact'
  ).addTarget(
    grafana.prometheus.target(
      'homeassistant_sensor_reactive_power_var',
      datasource=datasourceToUse,
      legendFormat='{{friendly_name}}'
    )
  ),
  gridPos={ x: 12, y: 21, w: 12, h: 8 }
)
