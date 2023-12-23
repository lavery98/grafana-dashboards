local util = import '../dashboard-utils.libsonnet';
local grafonnet = import '../g.libsonnet';

local queries = import './queries.libsonnet';

local dashboard = grafonnet.dashboard;
local grid = grafonnet.util.grid;
local row = grafonnet.panel.row;
local table = grafonnet.panel.table;
local timeSeries = grafonnet.panel.timeSeries;

// Dashboards are from https://github.com/prometheus/prometheus/blob/main/documentation/prometheus-mixin/dashboards.libsonnet
{
  'prometheus-overview.json': (
    util.dashboard('Prometheus / Overview', tags=['generated', 'prometheus'])
    + util.addMultiVariable('cluster', 'prometheus_build_info', 'cluster')
    + util.addMultiVariable('namespace', 'prometheus_build_info{cluster=~"$cluster"}', 'namespace')
    + dashboard.withLinks(
      dashboard.link.dashboards.new('Prometheus Dashboards', ['prometheus'])
      + dashboard.link.dashboards.options.withAsDropdown()
      + dashboard.link.dashboards.options.withIncludeVars()
      + dashboard.link.dashboards.options.withKeepTime()
    )
    + dashboard.withPanels(
      grid.wrapPanels([
        util.row('Prometheus Stats'),

        util.table.base('Prometheus Stats', [queries.prometheusCount, queries.prometheusUptime], width=24)
        + table.queryOptions.withTransformations([
          table.transformation.withId('merge'),

          table.transformation.withId('organize')
          + table.transformation.withOptions({
            excludeByName: {
              Time: true,
              'Value #A': true,
            },
            indexByName: {
              cluster: 0,
              namespace: 1,
              instance: 2,
              version: 3,
              'Value #B': 4,
            },
            renameByName: {
              'Value #B': 'Uptime',
            },
          }),
        ])
        + table.standardOptions.withOverrides(
          table.fieldOverride.byName.new('Uptime')
          + table.fieldOverride.byName.withPropertiesFromOptions(
            table.standardOptions.withUnit('s')
          )
        ),

        util.row('Discovery', collapsed=true)
        + row.withPanels(
          grid.wrapPanels([
            util.timeSeries.base('Target Sync', queries.targetSync)
            + timeSeries.standardOptions.withUnit('ms'),

            util.timeSeries.base('Targets', queries.targets)
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
            + timeSeries.fieldConfig.defaults.custom.withStacking(true)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),
          ])
        ),

        util.row('Retrieval', collapsed=true)
        + row.withPanels(
          grid.wrapPanels([
            util.timeSeries.base('Average Scrape Interval Duration', queries.averageScrapeDuration)
            + timeSeries.standardOptions.withUnit('ms'),

            util.timeSeries.base('Scrape failures', [queries.exceededBodySizeLimit, queries.exceededSampleLimit, queries.sampleDuplicateTimestamp, queries.sampleOutOfBounds, queries.sampleOutOfOrder])
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
            + timeSeries.fieldConfig.defaults.custom.withStacking(true)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Appended Samples', queries.appendedSamples)
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
            + timeSeries.fieldConfig.defaults.custom.withStacking(true)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),
          ])
        ),

        util.row('Storage', collapsed=true)
        + row.withPanels(
          grid.wrapPanels([
            util.timeSeries.base('Head Series', queries.headSeries)
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
            + timeSeries.fieldConfig.defaults.custom.withStacking(true)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Head Chunks', queries.headChunks)
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
            + timeSeries.fieldConfig.defaults.custom.withStacking(true)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),
          ])
        ),

        util.row('Query', collapsed=true)
        + row.withPanels(
          grid.wrapPanels([
            util.timeSeries.base('Query Rate', queries.queryRate)
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
            + timeSeries.fieldConfig.defaults.custom.withStacking(true)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Stage Duration', queries.stageDuration)
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
            + timeSeries.fieldConfig.defaults.custom.withStacking(true)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc')
            + timeSeries.standardOptions.withUnit('ms'),
          ])
        ),
      ])
    )
  ),
  'prometheus-remote-write.json': (
    util.dashboard('Prometheus / Remote Write', tags=['generated', 'prometheus'])
    + util.addMultiVariable('cluster', 'prometheus_build_info', 'cluster')
    + util.addMultiVariable('namespace', 'prometheus_build_info{cluster=~"$cluster"}', 'namespace')
    + util.addVariable('url', 'prometheus_remote_storage_shards{cluster=~"$cluster", namespace=~"$namespace"}', 'url', allValue='.+', includeAll=true)
    + dashboard.withLinks(
      dashboard.link.dashboards.new('Prometheus Dashboards', ['prometheus'])
      + dashboard.link.dashboards.options.withAsDropdown()
      + dashboard.link.dashboards.options.withIncludeVars()
      + dashboard.link.dashboards.options.withKeepTime()
    )
  ),
}
