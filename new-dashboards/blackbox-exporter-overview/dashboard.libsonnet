local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local queries = import './queries.libsonnet';

local dashboard = grafonnet.dashboard;
local table = grafonnet.panel.table;
local timeSeries = grafonnet.panel.timeSeries;

(import '../dashboard-utils.libsonnet') {
  'blackbox-exporter-overview.json': (
    $.dashboard('Blackbox Exporter Overview')
    + $.addMultiVariable('cluster', 'probe_success', 'cluster')
    + dashboard.withPanels(
      $.makeGrid([
        $.tablePanel('Probes (Up/Down) - Current Status', queries.probesCurrentStatus)
        + table.fieldConfig.defaults.withCustom({
          filterable: true,
        })
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
        ])
        + table.gridPos.withH(8)
        + table.gridPos.withW(10),

        $.timeseriesPanel('Probes (Up/Down) - Historic Status', queries.probesHistoricStatus)
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
        + timeSeries.standardOptions.withMin(0)
        + timeSeries.gridPos.withH(8)
        + timeSeries.gridPos.withW(14),

        $.tablePanel('SSL Certificate Expiry', queries.sslCertificateExpiry)
        + table.fieldConfig.defaults.withCustom({
          filterable: true,
        })
        + table.options.footer.TableFooterOptions.withEnablePagination(true)
        + table.queryOptions.withTransformations([
          table.transformation.withId('organize')
          + table.transformation.withOptions({
            excludeByName: {
              Time: true,
              __name__: true,
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
        ])
        + table.gridPos.withH(8)
        + table.gridPos.withW(10),

        $.timeseriesPanel('DNS Lookup', queries.dnsLookup)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('s')
        + timeSeries.gridPos.withH(8)
        + timeSeries.gridPos.withW(14),

        $.timeseriesPanel('Probe Duration', queries.probeDuration)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('s')
        + timeSeries.gridPos.withH(8)
        + timeSeries.gridPos.withW(24),
      ])
    )
  ),
}
