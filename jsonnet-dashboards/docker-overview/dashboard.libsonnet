/*
 * Copyright 2023 Ashley Lavery
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
local stat = grafonnet.panel.stat;
local timeSeries = grafonnet.panel.timeSeries;

{
  'docker-overview.json': (
    util.dashboard('Docker Overview', tags=['generated', 'docker', 'cadvisor'])
    + util.addMultiVariable('cluster', 'cadvisor_version_info', 'cluster')
    + util.addMultiVariable('namespace', 'cadvisor_version_info{cluster=~"$cluster"}', 'namespace')
    + util.addMultiVariable('host', 'cadvisor_version_info{cluster=~"$cluster", namespace=~"$namespace"}', 'host')
    + dashboard.withPanels(
      util.makeGrid([
        util.stat.base('Containers', queries.containers, height=4, width=4)
        + stat.options.withGraphMode('none')
        + stat.standardOptions.color.withFixedColor('text'),

        util.stat.base('Total CPU Usage', queries.totalCPUUsage, height=4, width=4)
        + stat.standardOptions.withUnit('percent')
        + stat.standardOptions.color.withMode('palette-classic'),

        util.stat.base('Total Memory Usage', queries.totalMemoryUsage, height=4, width=4)
        + stat.standardOptions.withUnit('bytes')
        + stat.standardOptions.color.withMode('palette-classic'),

        util.stat.base('Total Swap Usage', queries.totalSwapUsage, height=4, width=4)
        + stat.standardOptions.withUnit('bytes')
        + stat.standardOptions.color.withMode('palette-classic'),

        util.stat.base('Total Received Network Traffic', queries.totalReceivedNetworkTraffic, height=4, width=4)
        + stat.standardOptions.withUnit('Bps')
        + stat.standardOptions.color.withMode('palette-classic'),

        util.stat.base('Total Sent Network Traffic', queries.totalSentNetworkTraffic, height=4, width=4)
        + stat.standardOptions.withUnit('Bps')
        + stat.standardOptions.color.withMode('palette-classic'),

        util.timeSeries.base('CPU Usage per Container', queries.cpuUsagePerContainer)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + timeSeries.options.legend.withPlacement('right')
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('percent'),

        util.timeSeries.base('Memory Usage per Container', queries.memoryUsagePerContainer)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + timeSeries.options.legend.withPlacement('right')
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('bytes'),

        util.timeSeries.base('Received Network Traffic per Container', queries.receivedNetworkTrafficPerContainer)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + timeSeries.options.legend.withPlacement('right')
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('Bps'),

        util.timeSeries.base('Sent Network Traffic per Container', queries.sentNetworkTrafficPerContainer)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + timeSeries.options.legend.withPlacement('right')
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('Bps'),

        util.timeSeries.base('Filesystem Reads per Container', queries.filesystemReadsPerContainer)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + timeSeries.options.legend.withPlacement('right')
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('Bps'),

        util.timeSeries.base('Filesystem Writes per Container', queries.filesystemWritesPerContainer)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + timeSeries.options.legend.withPlacement('right')
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('Bps'),
      ])
    )
  ),
}
