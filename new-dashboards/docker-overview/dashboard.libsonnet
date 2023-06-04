local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v9.4.0/main.libsonnet';

local queries = import './queries.libsonnet';

(import '../dashboard-utils.libsonnet') {
  'docker-overview.json': (
    $.dashboard('Docker Overview')
    + $.addVariable('cluster', 'cadvisor_version_info', 'cluster')
    + $.addVariable('namespace', 'cadvisor_version_info{cluster=~"$cluster"}', 'namespace')
    + $.addVariable('host', 'cadvisor_version_info{cluster=~"$cluster", namespace=~"$namespace"}', 'host')
    + grafonnet.dashboard.withPanels(
      $.makeGrid([
        $.statPanel('Containers', queries.containers)
        + grafonnet.panel.stat.fieldConfig.defaults.color.withFixedColor('text')
        + grafonnet.panel.stat.options.withGraphMode('none')
        + grafonnet.panel.stat.gridPos.withH(4)
        + grafonnet.panel.stat.gridPos.withW(4),

        $.statPanel('Total CPU Usage', queries.totalCPUUsage)
        + grafonnet.panel.stat.fieldConfig.defaults.withUnit('percent')
        + grafonnet.panel.stat.fieldConfig.defaults.color.withMode('palette-classic')
        + grafonnet.panel.stat.gridPos.withH(4)
        + grafonnet.panel.stat.gridPos.withW(4),

        $.statPanel('Total Memory Usage', queries.totalMemoryUsage)
        + grafonnet.panel.stat.fieldConfig.defaults.withUnit('bytes')
        + grafonnet.panel.stat.fieldConfig.defaults.color.withMode('palette-classic')
        + grafonnet.panel.stat.gridPos.withH(4)
        + grafonnet.panel.stat.gridPos.withW(4),

        $.statPanel('Total Swap Usage', queries.totalSwapUsage)
        + grafonnet.panel.stat.fieldConfig.defaults.withUnit('bytes')
        + grafonnet.panel.stat.fieldConfig.defaults.color.withMode('palette-classic')
        + grafonnet.panel.stat.gridPos.withH(4)
        + grafonnet.panel.stat.gridPos.withW(4),

        $.statPanel('Total Received Network Traffic', queries.totalReceivedNetworkTraffic)
        + grafonnet.panel.stat.fieldConfig.defaults.withUnit('Bps')
        + grafonnet.panel.stat.fieldConfig.defaults.color.withMode('palette-classic')
        + grafonnet.panel.stat.gridPos.withH(4)
        + grafonnet.panel.stat.gridPos.withW(4),

        $.statPanel('Total Sent Network Traffic', queries.totalSentNetworkTraffic)
        + grafonnet.panel.stat.fieldConfig.defaults.withUnit('Bps')
        + grafonnet.panel.stat.fieldConfig.defaults.color.withMode('palette-classic')
        + grafonnet.panel.stat.gridPos.withH(4)
        + grafonnet.panel.stat.gridPos.withW(4),

        $.timeseriesPanel('CPU Usage per Container', queries.cpuUsagePerContainer)
        + grafonnet.panel.timeSeries.fieldConfig.defaults.withUnit('percent')
        + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + grafonnet.panel.timeSeries.options.legend.withPlacement('right')
        + grafonnet.panel.timeSeries.options.tooltip.withMode('multi')
        + grafonnet.panel.timeSeries.options.tooltip.withSort('desc')
        + grafonnet.panel.timeSeries.gridPos.withH(8)
        + grafonnet.panel.timeSeries.gridPos.withW(12),

        $.timeseriesPanel('Memory Usage per Container', queries.memoryUsagePerContainer)
        + grafonnet.panel.timeSeries.fieldConfig.defaults.withUnit('bytes')
        + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + grafonnet.panel.timeSeries.options.legend.withPlacement('right')
        + grafonnet.panel.timeSeries.options.tooltip.withMode('multi')
        + grafonnet.panel.timeSeries.options.tooltip.withSort('desc')
        + grafonnet.panel.timeSeries.gridPos.withH(8)
        + grafonnet.panel.timeSeries.gridPos.withW(12),

        $.timeseriesPanel('Received Network Traffic per Container', queries.receivedNetworkTrafficPerContainer)
        + grafonnet.panel.timeSeries.fieldConfig.defaults.withUnit('Bps')
        + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + grafonnet.panel.timeSeries.options.legend.withPlacement('right')
        + grafonnet.panel.timeSeries.options.tooltip.withMode('multi')
        + grafonnet.panel.timeSeries.options.tooltip.withSort('desc')
        + grafonnet.panel.timeSeries.gridPos.withH(8)
        + grafonnet.panel.timeSeries.gridPos.withW(12),

        $.timeseriesPanel('Sent Network Traffic per Container', queries.sentNetworkTrafficPerContainer)
        + grafonnet.panel.timeSeries.fieldConfig.defaults.withUnit('Bps')
        + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + grafonnet.panel.timeSeries.options.legend.withPlacement('right')
        + grafonnet.panel.timeSeries.options.tooltip.withMode('multi')
        + grafonnet.panel.timeSeries.options.tooltip.withSort('desc')
        + grafonnet.panel.timeSeries.gridPos.withH(8)
        + grafonnet.panel.timeSeries.gridPos.withW(12),

        $.timeseriesPanel('Filesystem Reads per Container', queries.filesystemReadsPerContainer)
        + grafonnet.panel.timeSeries.fieldConfig.defaults.withUnit('Bps')
        + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + grafonnet.panel.timeSeries.options.legend.withPlacement('right')
        + grafonnet.panel.timeSeries.options.tooltip.withMode('multi')
        + grafonnet.panel.timeSeries.options.tooltip.withSort('desc')
        + grafonnet.panel.timeSeries.gridPos.withH(8)
        + grafonnet.panel.timeSeries.gridPos.withW(12),

        $.timeseriesPanel('Filesystem Writes per Container', queries.filesystemWritesPerContainer)
        + grafonnet.panel.timeSeries.fieldConfig.defaults.withUnit('Bps')
        + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + grafonnet.panel.timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
        + grafonnet.panel.timeSeries.options.legend.withPlacement('right')
        + grafonnet.panel.timeSeries.options.tooltip.withMode('multi')
        + grafonnet.panel.timeSeries.options.tooltip.withSort('desc')
        + grafonnet.panel.timeSeries.gridPos.withH(8)
        + grafonnet.panel.timeSeries.gridPos.withW(12),
      ])
    )
  )
}
