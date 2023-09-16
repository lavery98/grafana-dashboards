local util = import '../dashboard-utils.libsonnet';
local grafonnet = import '../g.libsonnet';

local queries = import './queries.libsonnet';

local dashboard = grafonnet.dashboard;
local table = grafonnet.panel.table;
local timeSeries = grafonnet.panel.timeSeries;

{
  'blackbox-exporter-overview.json': (
    util.dashboard('Blackbox Exporter Overview', tags=['generated', 'blackbox_exporter'])
    + util.addMultiVariable('cluster', 'probe_success', 'cluster')
    + dashboard.withPanels(
      util.makeGrid([
        util.table.base('Probes (Up/Down) - Current Status', queries.probesCurrentStatus)
        + util.table.withFilterable(true)
        + table.options.footer.TableFooterOptions.withEnablePagination(true)
        + table.queryOptions.withTransformations([
          table.transformation.withId('organize')
          + table.transformation.withOptions({
            excludeByName: {
              Time: true,
              __name__: true,
              host: true,
              namespace: true,
            },
            indexByName: {},
            renameByName: {
              cluster: 'Cluster',
              instance: 'Instance',
              job: 'Job',
              Value: 'Status',
            },
          }),
        ])
        + table.standardOptions.withOverrides([
          table.fieldOverride.byName.new('Status')
          + table.fieldOverride.byName.withPropertiesFromOptions(
            table.standardOptions.withMappings([
              table.valueMapping.ValueMap.withOptions({
                '0': {
                  color: 'red',
                  text: 'Down',
                },
                '1': {
                  color: 'green',
                  text: 'Up',
                },
              })
              + table.valueMapping.ValueMap.withType('value'),
            ])
          )
          + table.fieldOverride.byName.withProperty('custom.cellOptions', {
            type: 'color-background',
          }),
        ]),

        util.timeSeries.base('Probes (Up/Down) - Historic Status', queries.probesHistoricStatus)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withDecimals(0)
        + timeSeries.standardOptions.withMappings([
          timeSeries.valueMapping.ValueMap.withOptions({
            '0': {
              text: 'Down',
            },
            '1': {
              text: 'Up',
            },
          })
          + timeSeries.valueMapping.ValueMap.withType('value'),
        ])
        + timeSeries.standardOptions.withMax(1)
        + timeSeries.standardOptions.withMin(0),

        util.table.base('SSL Certificate Expiry', queries.sslCertificateExpiry)
        + util.table.withFilterable(true)
        + table.options.footer.TableFooterOptions.withEnablePagination(true)
        + table.queryOptions.withTransformations([
          table.transformation.withId('organize')
          + table.transformation.withOptions({
            excludeByName: {
              Time: true,
              __name__: true,
              host: true,
              namespace: true,
            },
            indexByName: {},
            renameByName: {
              cluster: 'Cluster',
              instance: 'Instance',
              job: 'Job',
              Value: 'Time left',
            },
          }),
        ])
        + table.standardOptions.withOverrides([
          table.fieldOverride.byName.new('Time left')
          + table.fieldOverride.byName.withPropertiesFromOptions(
            table.standardOptions.withUnit('s')
          )
          + table.fieldOverride.byName.withProperty('custom.cellOptions', {
            type: 'color-background',
          }),
        ])
        + table.standardOptions.color.withMode('thresholds')
        + table.standardOptions.thresholds.withMode('absolute')
        + table.standardOptions.thresholds.withSteps([
          table.thresholdStep.withColor('red')
          + table.thresholdStep.withValue(null),
          table.thresholdStep.withColor('orange')
          + table.thresholdStep.withValue(604800),
          table.thresholdStep.withColor('green')
          + table.thresholdStep.withValue(2419200),
        ]),

        util.timeSeries.base('DNS Lookup', queries.dnsLookup)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('s'),

        util.timeSeries.base('Probe Duration', queries.probeDuration, width=24)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('s'),
      ])
    )
  ),
}
