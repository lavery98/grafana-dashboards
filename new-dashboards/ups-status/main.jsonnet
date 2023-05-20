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
  + grafonnet.panel.stat.options.withTextMode('auto'),
  g.statPanel('Battery Time Remaining', 'ups_runtime_remaining'),
  g.statPanel('UPS Load', 'ups_load')
])
