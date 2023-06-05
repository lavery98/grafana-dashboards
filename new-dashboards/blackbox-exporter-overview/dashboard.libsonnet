local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v9.4.0/main.libsonnet';

local queries = import './queries.libsonnet';

(import '../dashboard-utils.libsonnet') {
  'blackbox-exporter-overview.json': (
    $.dashboard('Blackbox Exporter Overview')
    + $.addMultiVariable('cluster', 'probe_success', 'cluster', allValue='.+')
    + grafonnet.dashboard.withPanels(
      $.makeGrid([
        $.tablePanel('Probes (Up/Down) - Current Status', queries.probesCurrentStatus)
        + grafonnet.panel.table.fieldConfig.defaults.withCustom({
          filterable: true,
        })
        + grafonnet.panel.table.fieldConfig.withOverrides([
          grafonnet.panel.table.fieldConfig.overrides.withProperties([
            grafonnet.panel.table.fieldConfig.overrides.properties.withId('mappings')
            + grafonnet.panel.table.fieldConfig.overrides.properties.withValue([
              {
                type: 'value',
                options: {
                  '0': {
                    color: 'red',
                    text: 'Down'
                  },
                  '1': {
                    color: 'green',
                    text: 'Up'
                  }
                }
              }
            ]),

            grafonnet.panel.table.fieldConfig.overrides.properties.withId('custom.cellOptions')
            + grafonnet.panel.table.fieldConfig.overrides.properties.withValue({
              type: 'color-background'
            })
          ])
          + grafonnet.panel.table.fieldConfig.overrides.matcher.withId('byName')
          + grafonnet.panel.table.fieldConfig.overrides.matcher.withOptions('Status')
        ])
        + grafonnet.panel.table.options.withCellHeight('sm')
        + grafonnet.panel.table.options.withFooter()
        + grafonnet.panel.table.options.withShowHeader()
        + grafonnet.panel.table.options.footer.TableFooterOptions.withEnablePagination(true)
        + grafonnet.panel.table.withTransformations([
          grafonnet.panel.table.transformations.withId('organize')
          + grafonnet.panel.table.transformations.withOptions({
            excludeByName: {
              Time: true,
              __name__: true,
              host: true,
              namespace: true
            },
            indexByName: {},
            renameByName: {
              cluster: 'Cluster',
              instance: 'Instance',
              job: 'Job',
              Value: 'Status'
            }
          })
        ])
        + grafonnet.panel.table.gridPos.withH(8)
        + grafonnet.panel.table.gridPos.withW(10),

        $.timeseriesPanel('Probes (Up/Down) - Historic Status', queries.probesHistoricStatus)
        + grafonnet.panel.timeSeries.options.tooltip.withMode('multi')
        + grafonnet.panel.timeSeries.options.tooltip.withSort('desc')
        + grafonnet.panel.timeSeries.gridPos.withH(8)
        + grafonnet.panel.timeSeries.gridPos.withW(14),

        $.tablePanel('SSL Certificate Expiry', queries.sslCertificateExpiry)
        + grafonnet.panel.table.fieldConfig.withOverrides([
          grafonnet.panel.table.fieldConfig.overrides.withProperties([
            grafonnet.panel.table.fieldConfig.overrides.properties.withId('unit')
            + grafonnet.panel.table.fieldConfig.overrides.properties.withValue('s'),

            grafonnet.panel.table.fieldConfig.overrides.properties.withId('thresholds')
            + grafonnet.panel.table.fieldConfig.overrides.properties.withValue({
              mode: 'absolute',
              steps: [
                {
                  color: 'red',
                  value: null
                },
                {
                  color: 'orange',
                  value: 604800
                },
                {
                  color: 'green',
                  value: 2419200
                }
              ]
            }),

            grafonnet.panel.table.fieldConfig.overrides.properties.withId('custom.cellOptions')
            + grafonnet.panel.table.fieldConfig.overrides.properties.withValue({
              type: 'color-background'
            })
          ])
          + grafonnet.panel.table.fieldConfig.overrides.matcher.withId('byName')
          + grafonnet.panel.table.fieldConfig.overrides.matcher.withOptions('Time left')
        ])
        + grafonnet.panel.table.fieldConfig.defaults.withCustom({
          filterable: true,
        })
        + grafonnet.panel.table.fieldConfig.defaults.color.withMode('thresholds')
        + grafonnet.panel.table.options.withCellHeight('sm')
        + grafonnet.panel.table.options.withFooter()
        + grafonnet.panel.table.options.withShowHeader()
        + grafonnet.panel.table.options.footer.TableFooterOptions.withEnablePagination(true)
        + grafonnet.panel.table.withTransformations([
          grafonnet.panel.table.transformations.withId('organize')
          + grafonnet.panel.table.transformations.withOptions({
            excludeByName: {
              Time: true,
              __name__: true
            },
            indexByName: {},
            renameByName: {
              cluster: 'Cluster',
              instance: 'Instance',
              job: 'Job',
              Value: 'Time left'
            }
          })
        ])
        + grafonnet.panel.table.gridPos.withH(8)
        + grafonnet.panel.table.gridPos.withW(10),
      ])
    )
  )
}
