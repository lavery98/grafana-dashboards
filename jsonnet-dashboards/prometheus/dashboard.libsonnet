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
    + dashboard.withPanels(
      grid.wrapPanels([
        util.row('Timestamps'),

        util.timeSeries.base('Highest Timestamp In vs. Highest Timestamp Sent', queries.timestampComparison)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc'),

        util.timeSeries.base('Rate[5m]', queries.timestampComparisonRate)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc'),

        util.row('Samples', collapsed=true)
        + row.withPanels(
          grid.wrapPanels([
            util.timeSeries.base('Rate, in vs. succeeded or dropped [5m]', queries.samplesRate, width=24)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),
          ])
        ),

        util.row('Shards', collapsed=true)
        + row.withPanels(
          grid.wrapPanels([
            util.timeSeries.base('Current Shards', queries.currentShards, width=24)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Max Shards', queries.maxShards, width=8)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Min Shards', queries.minShards, width=8)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Desired Shards', queries.desiredShards, width=8)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),
          ])
        ),

        util.row('Shard Details', collapsed=true)
        + row.withPanels(
          grid.wrapPanels([
            util.timeSeries.base('Shard Capacity', queries.shardsCapacity)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Pending Samples', queries.pendingSamples)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),
          ])
        ),

        util.row('Segments', collapsed=true)
        + row.withPanels(
          grid.wrapPanels([
            util.timeSeries.base('TSDB Current Segment', queries.walSegment)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Remote Write Current Segment', queries.queueSegment)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),
          ])
        ),

        util.row('Misc. Rates', collapsed=true)
        + row.withPanels(
          grid.wrapPanels([
            util.timeSeries.base('Dropped Samples', queries.droppedSamples)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Failed Samples', queries.failedSamples)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Retried Samples', queries.retriedSamples)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),

            util.timeSeries.base('Enqueue Retries', queries.enqueueRetries)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('desc'),
          ])
        ),
      ])
    )
  ),
}
