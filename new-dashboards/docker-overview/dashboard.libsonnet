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
      ])
    )
  )
}
