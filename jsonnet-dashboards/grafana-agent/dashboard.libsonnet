/*
 * Copyright 2024 Ashley Lavery
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

local util = import '../dashboard-utils.libsonnet';
local grafonnet = import '../g.libsonnet';

local queries = import './queries.libsonnet';

local dashboard = grafonnet.dashboard;
local row = grafonnet.panel.row;
local table = grafonnet.panel.table;
local timeSeries = grafonnet.panel.timeSeries;

// Dashboards are from https://github.com/grafana/agent/blob/main/production/grafana-agent-mixin/dashboards.libsonnet
{
  'agent-overview.json': (
    util.dashboard('Agent / Overview', tags=['generated', 'grafana-agent'])
    + util.addMultiVariable('cluster', 'agent_build_info', 'cluster')
    + util.addMultiVariable('namespace', 'agent_build_info{cluster=~"$cluster"}', 'namespace')
    + dashboard.withLinks(
      dashboard.link.dashboards.new('Grafana Agent Dashboards', ['grafana-agent'])
      + dashboard.link.dashboards.options.withAsDropdown()
      + dashboard.link.dashboards.options.withIncludeVars()
      + dashboard.link.dashboards.options.withKeepTime()
    )
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

        util.row('Prometheus Discovery', collapsed=true)
        + row.withPanels(
          util.makeGrid([
            util.timeSeries.base('Target Sync', queries.targetSync)
            + timeSeries.standardOptions.withUnit('ms'),

            util.timeSeries.base('Targets', queries.targets)
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
            + timeSeries.fieldConfig.defaults.custom.withStacking(true)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),
          ])
        ),

        util.row('Prometheus Retrieval', collapsed=true)
        + row.withPanels(
          util.makeGrid([
            util.timeSeries.base('Average Scrape Interval Duration', queries.averageScrapeDuration)
            + timeSeries.standardOptions.withUnit('ms'),

            util.timeSeries.base('Scrape failures', [queries.exceededSampleLimit, queries.sampleDuplicateTimestamp, queries.sampleOutOfBounds, queries.sampleOutOfOrder])
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
      ])
    )
  ),

  'agent-remote-write.json': (
    util.dashboard('Agent / Prometheus Remote Write', tags=['generated', 'grafana-agent'])
    + util.addMultiVariable('cluster', 'agent_build_info', 'cluster')
    + util.addMultiVariable('namespace', 'agent_build_info{cluster=~"$cluster"}', 'namespace')
    + dashboard.withLinks(
      dashboard.link.dashboards.new('Grafana Agent Dashboards', ['grafana-agent'])
      + dashboard.link.dashboards.options.withAsDropdown()
      + dashboard.link.dashboards.options.withIncludeVars()
      + dashboard.link.dashboards.options.withKeepTime()
    )
    + dashboard.withPanels(
      util.makeGrid([
        util.row('Timestamps'),

        util.timeSeries.base('Highest Timestamp In vs. Highest Timestamp Sent', queries.timestampComparison, width=12)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc'),

        util.timeSeries.base('Latency [1m]', [queries.meanRemoteSendLatency, queries.p99RemoteSendLatency], width=12)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc'),

        util.row('Samples', collapsed=true)
        + row.withPanels(
          util.makeGrid([
            util.timeSeries.base('Rate in [5m]', queries.samplesInRate, width=12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Rate succeeded [5m]', queries.samplesOutRate, width=12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Pending Samples', queries.pendingSamples, width=12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Dropped Samples', queries.droppedSamples, width=12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Failed Samples', queries.failedSamples, width=12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Retried Samples', queries.retriedSamples, width=12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),
          ])
        ),

        util.row('Shards', collapsed=true)
        + row.withPanels(
          util.makeGrid([
            util.timeSeries.base('Current Shards', queries.currentShards, width=12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Max Shards', queries.maxShards, width=12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Min Shards', queries.minShards, width=12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Desired Shards', queries.desiredShards, width=12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),
          ])
        ),

        util.row('Shard Details', collapsed=true)
        + row.withPanels(
          util.makeGrid([
            util.timeSeries.base('Shard Capacity', queries.shardsCapacity, width=12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),
          ])
        ),

        util.row('Segments', collapsed=true)
        + row.withPanels(
          util.makeGrid([
            util.timeSeries.base('Remote Write Current Segment', queries.queueSegment, width=12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),
          ])
        ),

        util.row('Misc. Rates', collapsed=true)
        + row.withPanels(
          util.makeGrid([
            util.timeSeries.base('Enqueue Retries', queries.enqueueRetries, width=12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),
          ])
        ),
      ])
    )
  ),

  'agent-logs-pipeline.json': (
    util.dashboard('Agent / Logs Pipeline', tags=['generated', 'grafana-agent'])
    + util.addMultiVariable('cluster', 'agent_build_info', 'cluster')
    + util.addMultiVariable('namespace', 'agent_build_info{cluster=~"$cluster"}', 'namespace')
    + dashboard.withLinks(
      dashboard.link.dashboards.new('Grafana Agent Dashboards', ['grafana-agent'])
      + dashboard.link.dashboards.options.withAsDropdown()
      + dashboard.link.dashboards.options.withIncludeVars()
      + dashboard.link.dashboards.options.withKeepTime()
    )
    + dashboard.withPanels(
      util.makeGrid([
        util.row('Errors'),

        util.timeSeries.base('Dropped bytes rate [B/s]', queries.droppedBytes, width=12)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.withStacking(true)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('Bps'),

        util.timeSeries.base('Write requests success rate [%]', queries.requestSuccessRate, width=12)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withMax(100)
        + timeSeries.standardOptions.withUnit('percent'),

        util.row('Latencies'),

        util.timeSeries.base('Write latencies p99 [s]', queries.p99RequestDuration, width=12)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('s'),

        util.timeSeries.base('Write latencies p90 [s]', queries.p90RequestDuration, width=12)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('s'),

        util.timeSeries.base('Write latencies p50 [s]', queries.p50RequestDuration, width=12)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('s'),

        util.timeSeries.base('Write latencies average [s]', queries.averageRequestDuration, width=12)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('s'),

        util.row('Logs volume'),

        util.timeSeries.base('Bytes read rate [B/s]', queries.bytesRead, width=12)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.withStacking(true)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('Bps'),

        util.timeSeries.base('Lines read rate [lines/s]', queries.linesRead, width=12)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.withStacking(true)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('short'),

        util.timeSeries.base('Active files count', queries.activeFilesCount, width=12)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.withStacking(true)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc'),

        util.timeSeries.base('Entries sent rate [entries/s]', queries.entriesSent, width=12)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.withStacking(true)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('short'),
      ])
    )
  ),
}
