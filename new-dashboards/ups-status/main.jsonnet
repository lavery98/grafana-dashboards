local g = import '../g.libsonnet';
local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v9.4.0/main.libsonnet';

g.dashboard('UPS Status')
+ grafonnet.dashboard.withPanels(
  g.makeGrid([
    g.statPanel('UPS State', 'ups_state')
    + grafonnet.panel.stat.fieldConfig.defaults.withMappings([
      grafonnet.panel.stat.fieldConfig.defaults.mappings.ValueMap.withType('value')
      + grafonnet.panel.stat.fieldConfig.defaults.mappings.ValueMap.withOptions({
        '0': {
          text: 'Not Normal',
          color: 'red',
        },
        '1': {
          text: 'Normal',
          color: 'green',
        },
      }),
    ])
    + grafonnet.panel.stat.options.withGraphMode('none')
    + grafonnet.panel.stat.options.withColorMode('value')
    + grafonnet.panel.stat.options.withJustifyMode('auto')
    + grafonnet.panel.stat.options.withTextMode('auto')
    + grafonnet.panel.stat.gridPos.withH(5)
    + grafonnet.panel.stat.gridPos.withW(6),

    g.gaugePanel('Battery Capacity', 'ups_battery_capacity')
    + grafonnet.panel.gauge.fieldConfig.defaults.withMax(100)
    + grafonnet.panel.gauge.fieldConfig.defaults.withMin(0)
    + grafonnet.panel.gauge.fieldConfig.defaults.withUnit('percent')
    + grafonnet.panel.gauge.fieldConfig.defaults.thresholds.withMode('absolute')
    + grafonnet.panel.gauge.fieldConfig.defaults.thresholds.withSteps([
      grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withColor('red'),
      grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withColor('orange')
      + grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withValue(50),
      grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withColor('green')
      + grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withValue(80),
    ])
    + grafonnet.panel.gauge.gridPos.withH(5)
    + grafonnet.panel.gauge.gridPos.withW(6),

    g.statPanel('Battery Time Remaining', 'ups_runtime_remaining')
    + grafonnet.panel.stat.fieldConfig.defaults.withUnit('m')
    + grafonnet.panel.stat.fieldConfig.defaults.thresholds.withMode('absolute')
    + grafonnet.panel.stat.fieldConfig.defaults.thresholds.withSteps([
      grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withColor('red'),
      grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withColor('orange')
      + grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withValue(15),
      grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withColor('green')
      + grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withValue(30),
    ])
    + grafonnet.panel.stat.options.withGraphMode('none')
    + grafonnet.panel.stat.options.withColorMode('value')
    + grafonnet.panel.stat.options.withJustifyMode('auto')
    + grafonnet.panel.stat.options.withTextMode('auto')
    + grafonnet.panel.stat.gridPos.withH(5)
    + grafonnet.panel.stat.gridPos.withW(6),

    g.statPanel('UPS Load', 'ups_load')
    + grafonnet.panel.stat.fieldConfig.defaults.withUnit('watt')
    + grafonnet.panel.stat.fieldConfig.defaults.color.withFixedColor('text')
    + grafonnet.panel.stat.fieldConfig.defaults.color.withMode('fixed')
    + grafonnet.panel.stat.options.withGraphMode('none')
    + grafonnet.panel.stat.options.withColorMode('value')
    + grafonnet.panel.stat.options.withJustifyMode('auto')
    + grafonnet.panel.stat.options.withTextMode('auto')
    + grafonnet.panel.stat.gridPos.withH(5)
    + grafonnet.panel.stat.gridPos.withW(6),

    // New row
    g.timeseriesPanel('UPS State')
    + grafonnet.panel.timeSeries.withTargets([
      g.prometheusQuery('ups_state')
      + grafonnet.query.prometheus.withLegendFormat('{{device}}'),
    ])
    + grafonnet.panel.timeSeries.fieldConfig.defaults.withMappings([
      grafonnet.panel.timeSeries.fieldConfig.defaults.mappings.ValueMap.withType('value')
      + grafonnet.panel.timeSeries.fieldConfig.defaults.mappings.ValueMap.withOptions({
        '0': {
          text: 'Not Normal',
          color: 'red',
        },
        '1': {
          text: 'Normal',
          color: 'green',
        },
      }),
    ])
    + grafonnet.panel.timeSeries.fieldConfig.defaults.withMax(1)
    + grafonnet.panel.timeSeries.fieldConfig.defaults.withMin(0)
    + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.withFillOpacity(100)
    + grafonnet.panel.timeSeries.gridPos.withH(8)
    + grafonnet.panel.timeSeries.gridPos.withW(6),

    g.timeseriesPanel('Battery Capacity')
    + grafonnet.panel.timeSeries.withTargets([
      g.prometheusQuery('ups_battery_capacity')
      + grafonnet.query.prometheus.withLegendFormat('{{device}}'),
    ])
    + grafonnet.panel.timeSeries.fieldConfig.defaults.withMax(100)
    + grafonnet.panel.timeSeries.fieldConfig.defaults.withMin(0)
    + grafonnet.panel.timeSeries.fieldConfig.defaults.withUnit('percent')
    + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.thresholdsStyle.withMode('dashed')
    + grafonnet.panel.timeSeries.fieldConfig.defaults.thresholds.withMode('absolute')
    + grafonnet.panel.timeSeries.fieldConfig.defaults.thresholds.withSteps([
      grafonnet.panel.timeSeries.fieldConfig.defaults.thresholds.steps.withColor('red'),
      grafonnet.panel.timeSeries.fieldConfig.defaults.thresholds.steps.withColor('orange')
      + grafonnet.panel.timeSeries.fieldConfig.defaults.thresholds.steps.withValue(50),
      grafonnet.panel.timeSeries.fieldConfig.defaults.thresholds.steps.withColor('green')
      + grafonnet.panel.timeSeries.fieldConfig.defaults.thresholds.steps.withValue(80),
    ])
    + grafonnet.panel.timeSeries.gridPos.withH(8)
    + grafonnet.panel.timeSeries.gridPos.withW(6),

    g.timeseriesPanel('Battery Time Remaining')
    + grafonnet.panel.timeSeries.withTargets([
      g.prometheusQuery('ups_runtime_remaining')
      + grafonnet.query.prometheus.withLegendFormat('{{device}}'),
    ])
    + grafonnet.panel.timeSeries.fieldConfig.defaults.withUnit('m')
    + grafonnet.panel.timeSeries.gridPos.withH(8)
    + grafonnet.panel.timeSeries.gridPos.withW(6),

    g.timeseriesPanel('UPS Load')
    + grafonnet.panel.timeSeries.withTargets([
      g.prometheusQuery('ups_load')
      + grafonnet.query.prometheus.withLegendFormat('{{device}}'),
    ])
    + grafonnet.panel.timeSeries.fieldConfig.defaults.withUnit('watt')
    + grafonnet.panel.timeSeries.gridPos.withH(8)
    + grafonnet.panel.timeSeries.gridPos.withW(6),

    // New row
    g.timeseriesPanel('UPS Input Voltage')
    + grafonnet.panel.timeSeries.withTargets([
      g.prometheusQuery('ups_in_voltage')
      + grafonnet.query.prometheus.withLegendFormat('{{device}}'),
    ])
    + grafonnet.panel.timeSeries.fieldConfig.defaults.withUnit('volt')
    + grafonnet.panel.timeSeries.gridPos.withH(8)
    + grafonnet.panel.timeSeries.gridPos.withW(24),

    // New row
    g.timeseriesPanel('UPS Output Voltage')
    + grafonnet.panel.timeSeries.withTargets([
      g.prometheusQuery('ups_out_voltage')
      + grafonnet.query.prometheus.withLegendFormat('{{device}}'),
    ])
    + grafonnet.panel.timeSeries.fieldConfig.defaults.withUnit('volt')
    + grafonnet.panel.timeSeries.gridPos.withH(8)
    + grafonnet.panel.timeSeries.gridPos.withW(24),
  ])
)
