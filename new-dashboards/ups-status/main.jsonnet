local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v9.4.0/main.libsonnet';
local g = import '../g.libsonnet';

g.dashboard('UPS Status')
+ grafonnet.dashboard.withPanels([
  g.statPanel('UPS State', 'ups_state')
  + grafonnet.panel.stat.fieldConfig.defaults.withMappings([
    grafonnet.panel.stat.fieldConfig.defaults.mappings.ValueMap.withType('value')
    + grafonnet.panel.stat.fieldConfig.defaults.mappings.ValueMap.withOptions({
      "0": {
        text: 'Not Normal',
        color: 'red'
      },
      "1": {
        text: 'Normal',
        color: 'green'
      }
    })
  ])
  + grafonnet.panel.stat.options.withGraphMode('none')
  + grafonnet.panel.stat.options.withColorMode('value')
  + grafonnet.panel.stat.options.withJustifyMode('auto')
  + grafonnet.panel.stat.options.withTextMode('auto')
  + grafonnet.panel.stat.gridPos.withH(5)
  + grafonnet.panel.stat.gridPos.withW(6)
  + grafonnet.panel.stat.gridPos.withX(0)
  + grafonnet.panel.stat.gridPos.withY(0),
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
    + grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withValue(80)
  ])
  + grafonnet.panel.gauge.gridPos.withH(5)
  + grafonnet.panel.gauge.gridPos.withW(6)
  + grafonnet.panel.gauge.gridPos.withX(6)
  + grafonnet.panel.gauge.gridPos.withY(0),
  g.statPanel('Battery Time Remaining', 'ups_runtime_remaining')
  + grafonnet.panel.stat.fieldConfig.defaults.withUnit('m')
  + grafonnet.panel.stat.fieldConfig.defaults.thresholds.withMode('absolute')
  + grafonnet.panel.stat.fieldConfig.defaults.thresholds.withSteps([
    grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withColor('red'),
    grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withColor('orange')
    + grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withValue(15),
    grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withColor('green')
    + grafonnet.panel.gauge.fieldConfig.defaults.thresholds.steps.withValue(30)
  ])
  + grafonnet.panel.stat.options.withGraphMode('none')
  + grafonnet.panel.stat.options.withColorMode('value')
  + grafonnet.panel.stat.options.withJustifyMode('auto')
  + grafonnet.panel.stat.options.withTextMode('auto')
  + grafonnet.panel.stat.gridPos.withH(5)
  + grafonnet.panel.stat.gridPos.withW(6)
  + grafonnet.panel.stat.gridPos.withX(12)
  + grafonnet.panel.stat.gridPos.withY(0),
  g.statPanel('UPS Load', 'ups_load')
  + grafonnet.panel.stat.fieldConfig.defaults.withUnit('watt')
  + grafonnet.panel.stat.fieldConfig.defaults.color.withFixedColor('text')
  + grafonnet.panel.stat.fieldConfig.defaults.color.withMode('fixed')
  + grafonnet.panel.stat.options.withGraphMode('none')
  + grafonnet.panel.stat.options.withColorMode('value')
  + grafonnet.panel.stat.options.withJustifyMode('auto')
  + grafonnet.panel.stat.options.withTextMode('auto')
  + grafonnet.panel.stat.gridPos.withH(5)
  + grafonnet.panel.stat.gridPos.withW(6)
  + grafonnet.panel.stat.gridPos.withX(18)
  + grafonnet.panel.stat.gridPos.withY(0),
])

/*g.makeGrid([
  g.gaugePanel('Battery Capacity', 'ups_battery_capacity')
  + grafonnet.panel.gauge.gridPos.withH(4)
  + grafonnet.panel.gauge.gridPos.withW(6),
  g.statPanel('Battery Time Remaining', 'ups_runtime_remaining')
  + grafonnet.panel.stat.options.withGraphMode('none')
  + grafonnet.panel.stat.options.withColorMode('value')
  + grafonnet.panel.stat.options.withJustifyMode('auto')
  + grafonnet.panel.stat.options.withTextMode('auto')
  + grafonnet.panel.stat.gridPos.withH(4)
  + grafonnet.panel.stat.gridPos.withW(6)
])*/