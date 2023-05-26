local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v9.4.0/main.libsonnet';

local queries = import './queries.libsonnet';

(import '../dashboard-utils.libsonnet') {
  "smart-status.json": (
    $.dashboard('S.M.A.R.T Status')
    + $.addVariable('cluster', 'smartmon_smartctl_version', 'cluster')
    + $.addVariable('namespace', 'smartmon_smartctl_version{cluster=~"$cluster"}', 'namespace')
    + $.addVariable('host', 'smartmon_smartctl_version{cluster=~"$cluster", namespace=~"$namespace"}', 'host')
    + grafonnet.dashboard.withPanels([
      /*$.makeGrid([
        $.statPanel('Disks Monitored', queries.disksMonitored)
        + grafonnet.panel.stat.gridPos.withH(4)
        + grafonnet.panel.stat.gridPos.withW(4),

        $.tablePanel('Disk Drives', queries.diskDrives)
        + grafonnet.panel.table.gridPos.withH(8)
        + grafonnet.panel.table.gridPos.withW(20),

        $.statPanel('Unhealthy Disks', queries.unhealthyDisks)
        + grafonnet.panel.stat.gridPos.withH(4)
        + grafonnet.panel.stat.gridPos.withW(4)
      ])*/
      $.row('Overview')
      + grafonnet.panel.row.gridPos.withH(1)
      + grafonnet.panel.row.gridPos.withW(24),

      $.statPanel('Disks Monitored', queries.disksMonitored)
      + grafonnet.panel.stat.gridPos.withH(4)
      + grafonnet.panel.stat.gridPos.withW(4),

      $.tablePanel('Disk Drives', queries.diskDrives)
      + grafonnet.panel.table.gridPos.withH(8)
      + grafonnet.panel.table.gridPos.withW(20),

      $.statPanel('Unhealthy Disks', queries.unhealthyDisks)
      + grafonnet.panel.stat.gridPos.withH(4)
      + grafonnet.panel.stat.gridPos.withW(4)
    ])
  )
}
