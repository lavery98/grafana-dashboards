local util = import '../dashboard-utils.libsonnet';
local grafonnet = import '../g.libsonnet';

local queries = import './queries.libsonnet';

local dashboard = grafonnet.dashboard;
local row = grafonnet.panel.row;
local table = grafonnet.panel.table;
local timeSeries = grafonnet.panel.timeSeries;

# Dashboards are from https://github.com/grafana/agent/blob/main/production/grafana-agent-mixin/dashboards.libsonnet
{
  'grafana-agent.json': (
    util.dashboard('Agent', tags=['generated', 'grafana-agent'])
    + util.addMultiVariable('cluster', 'agent_build_info', 'cluster')
    + util.addMultiVariable('namespace', 'agent_build_info{cluster=~"$cluster"}', 'namespace')
    + dashboard.withPanels(
      util.makeGrid([
        util.row('Agent Stats'),

        util.table.base('Agent Stats', [queries.agentCount, queries.agentUptime], width=24)
        + table.queryOptions.withTransformations([
          table.transformation.withId('merge'),

          table.transformation.withId('organize')
          + table.transformation.withOptions({
            excludeByName: {
              Time: true,
              "Value #A": true
            },
            indexByName: {
              cluster: 0,
              namespace: 1,
              instance: 2,
              version: 3,
              "Value #B": 4
            },
            renameByName: {
              "Value #B": "Uptime"
            }
          })
        ])
        + table.standardOptions.withOverrides(
          table.fieldOverride.byName.new('Uptime')
          + table.fieldOverride.byName.withPropertiesFromOptions(
            table.standardOptions.withUnit('s')
          )
        ),

        util.row('Prometheus Discovery', collapsed=true)
        + row.withPanels(
          util.makeGrid([
            util.timeSeries.base('Target Sync', queries.targetSync)
            + timeSeries.standardOptions.withUnit('ms'),

            util.timeSeries.base('Targets', queries.targets)
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
            + timeSeries.fieldConfig.defaults.custom.withStacking(true)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc')
          ])
        ),

        util.row('Prometheus Retrieval', collapsed=true)
        + row.withPanels(
          util.makeGrid([
            util.timeSeries.base('Average Scrape Interval Duration', queries.averageScrapeDuration)
            + timeSeries.standardOptions.withUnit('ms'),

            util.timeSeries.base('Scrape failures', [ queries.exceededSampleLimit, queries.sampleDuplicateTimestamp, queries.sampleOutOfBounds, queries.sampleOutOfOrder ])
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
        )
      ])
    )
  ),

  'grafana-agent-remote-write.json': (
    util.dashboard('Agent Prometheus Remote Write', tags=['generated', 'grafana-agent'])
  ),

  'grafana-agent-logs-pipeline.json': (
    util.dashboard('Agent Logs Pipeline', tags=['generated', 'grafana-agent'])
  )
}
