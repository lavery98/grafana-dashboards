local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v9.4.0/main.libsonnet';

local queries = import './queries.libsonnet';

local dashboard = grafonnet.dashboard;
local stat = grafonnet.panel.stat;
local timeSeries = grafonnet.panel.timeSeries;

(import '../dashboard-utils.libsonnet') {
  'docker-overview.json': (
    $.dashboard('Docker Overview')
    + $.addVariable('cluster', 'cadvisor_version_info', 'cluster')
    + $.addVariable('namespace', 'cadvisor_version_info{cluster=~"$cluster"}', 'namespace')
    + $.addVariable('host', 'cadvisor_version_info{cluster=~"$cluster", namespace=~"$namespace"}', 'host')
    + dashboard.withPanels(
      $.makeGrid([
        $.statPanel('Containers', queries.containers)
        + stat.options.withGraphMode('none')
        + stat.standardOptions.color.withFixedColor('text')
        + stat.gridPos.withH(4)
        + stat.gridPos.withW(4),

        $.statPanel('Total CPU Usage', queries.totalCPUUsage)
        + stat.standardOptions.withUnit('percent')
        + stat.standardOptions.color.withMode('palette-classic')
        + stat.gridPos.withH(4)
        + stat.gridPos.withW(4),

        $.statPanel('Total Memory Usage', queries.totalMemoryUsage)
        + stat.standardOptions.withUnit('bytes')
        + stat.standardOptions.color.withMode('palette-classic')
        + stat.gridPos.withH(4)
        + stat.gridPos.withW(4),

        $.statPanel('Total Swap Usage', queries.totalSwapUsage)
        + stat.standardOptions.withUnit('bytes')
        + stat.standardOptions.color.withMode('palette-classic')
        + stat.gridPos.withH(4)
        + stat.gridPos.withW(4),

        $.statPanel('Total Received Network Traffic', queries.totalReceivedNetworkTraffic)
        + stat.standardOptions.withUnit('Bps')
        + stat.standardOptions.color.withMode('palette-classic')
        + stat.gridPos.withH(4)
        + stat.gridPos.withW(4),

        $.statPanel('Total Sent Network Traffic', queries.totalSentNetworkTraffic)
        + stat.standardOptions.withUnit('Bps')
        + stat.standardOptions.color.withMode('palette-classic')
        + stat.gridPos.withH(4)
        + stat.gridPos.withW(4),

        $.timeseriesPanel('CPU Usage per Container', queries.cpuUsagePerContainer)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + timeSeries.options.legend.withPlacement('right')
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('percent')
        + timeSeries.gridPos.withH(8)
        + timeSeries.gridPos.withW(12),

        $.timeseriesPanel('Memory Usage per Container', queries.memoryUsagePerContainer)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + timeSeries.options.legend.withPlacement('right')
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('bytes')
        + timeSeries.gridPos.withH(8)
        + timeSeries.gridPos.withW(12),

        $.timeseriesPanel('Received Network Traffic per Container', queries.receivedNetworkTrafficPerContainer)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + timeSeries.options.legend.withPlacement('right')
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('Bps')
        + timeSeries.gridPos.withH(8)
        + timeSeries.gridPos.withW(12),

        $.timeseriesPanel('Sent Network Traffic per Container', queries.sentNetworkTrafficPerContainer)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + timeSeries.options.legend.withPlacement('right')
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('Bps')
        + timeSeries.gridPos.withH(8)
        + timeSeries.gridPos.withW(12),

        $.timeseriesPanel('Filesystem Reads per Container', queries.filesystemReadsPerContainer)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + timeSeries.options.legend.withPlacement('right')
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('Bps')
        + timeSeries.gridPos.withH(8)
        + timeSeries.gridPos.withW(12),

        $.timeseriesPanel('Filesystem Writes per Container', queries.filesystemWritesPerContainer)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + timeSeries.options.legend.withPlacement('right')
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('Bps')
        + timeSeries.gridPos.withH(8)
        + timeSeries.gridPos.withW(12),
      ])
    )
  )
}
