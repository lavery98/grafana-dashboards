local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v9.4.0/main.libsonnet';

local queries = import './queries.libsonnet';

(import '../dashboard-utils.libsonnet') {
  "smart-status.json": (
    $.dashboard('S.M.A.R.T Status')
    + $.addVariable('cluster', 'smartmon_smartctl_version', 'cluster')
    + $.addVariable('namespace', 'smartmon_smartctl_version{cluster=~"$cluster"}', 'namespace')
    + $.addVariable('host', 'smartmon_smartctl_version{cluster=~"$cluster", namespace=~"$namespace"}', 'host')
    + grafonnet.dashboard.withPanels([
      $.row('Overview')
      + grafonnet.panel.row.gridPos.withH(1)
      + grafonnet.panel.row.gridPos.withW(24),

      $.statPanel('Disks Monitored', queries.disksMonitored)
      + grafonnet.panel.stat.gridPos.withH(4)
      + grafonnet.panel.stat.gridPos.withW(4),

      $.tablePanel('Disk Drives', queries.diskDrives)
      + grafonnet.panel.table.fieldConfig.defaults.withCustom({
        "filterable": true
      })
      + grafonnet.panel.table.options.withCellHeight('sm')
      + grafonnet.panel.table.options.withFooter()
      + grafonnet.panel.table.options.footer.TableFooterOptions.withEnablePagination(true)
      + grafonnet.panel.table.options.withShowHeader()
      + grafonnet.panel.table.withTransformations([
        grafonnet.panel.table.transformations.withId('organize')
        + grafonnet.panel.table.transformations.withOptions({
          "excludeByName": {
            "Time": true,
            "__name__": true,
            "agent_hostname": true,
            "cluster": true,
            "host": true,
            "instance": true,
            "job": true,
            "namespace": true,
            "Value": true
          },
          "indexByName": {},
          "renameByName": {
            "device": "Device",
            "device_model": "Device Model",
            "firmware_version": "Firmware",
            "model_family": "Model Family",
            "serial_number": "Serial Number"
          }
        })
      ])
      + grafonnet.panel.table.gridPos.withH(8)
      + grafonnet.panel.table.gridPos.withW(20),

      $.statPanel('Unhealthy Disks', queries.unhealthyDisks)
      + grafonnet.panel.stat.gridPos.withH(4)
      + grafonnet.panel.stat.gridPos.withW(4),

      $.row('Temperature', collapsed=true)
      + grafonnet.panel.row.withPanels([
        $.timeseriesPanel('Temperature History', queries.temperatureHistory)
        + grafonnet.panel.timeSeries.fieldConfig.defaults.withUnit('celsius')
        + grafonnet.panel.timeSeries.options.legend.withCalcs([
          "mean",
          "min",
          "max",
          "lastNotNull"
        ])
        + grafonnet.panel.timeSeries.options.legend.withDisplayMode('table')
        + grafonnet.panel.timeSeries.options.legend.withPlacement('right')
        + grafonnet.panel.timeSeries.options.legend.withShowLegend(true)
        + grafonnet.panel.timeSeries.options.tooltip.withMode('multi')
        + grafonnet.panel.timeSeries.options.tooltip.withSort('none')
        + grafonnet.panel.timeSeries.gridPos.withH(8)
        + grafonnet.panel.timeSeries.gridPos.withW(24)
      ])
      + grafonnet.panel.row.gridPos.withH(1)
      + grafonnet.panel.row.gridPos.withW(24),

      $.row('Wear & Tear', collapsed=true)
      + grafonnet.panel.row.withPanels([
        $.barGaugePanel('Power On Hours', queries.powerOnHours)
        + grafonnet.panel.barGauge.fieldConfig.defaults.withMin(0)
        + grafonnet.panel.barGauge.fieldConfig.defaults.withUnit('h')
        + grafonnet.panel.barGauge.fieldConfig.defaults.color.withMode('thresholds')
        + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.withMode('absolute')
        + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.withSteps([
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('green')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(null),
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('orange')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(17520),
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('red')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(35040)
        ])
        + grafonnet.panel.barGauge.options.withOrientation('horizontal')
        + grafonnet.panel.barGauge.gridPos.withH(8)
        + grafonnet.panel.barGauge.gridPos.withW(12),

        $.barGaugePanel('Start Stop Count', queries.startStopCount)
        + grafonnet.panel.barGauge.fieldConfig.defaults.withMin(0)
        + grafonnet.panel.barGauge.fieldConfig.defaults.color.withMode('thresholds')
        + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.withMode('absolute')
        + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.withSteps([
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('green')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(null),
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('orange')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(750),
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('red')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(1500)
        ])
        + grafonnet.panel.barGauge.options.withOrientation('horizontal')
        + grafonnet.panel.barGauge.gridPos.withH(8)
        + grafonnet.panel.barGauge.gridPos.withW(12),

        $.barGaugePanel('Power Cycle Count', queries.powerCycleCount)
        + grafonnet.panel.barGauge.fieldConfig.defaults.withMin(0)
        + grafonnet.panel.barGauge.fieldConfig.defaults.color.withMode('thresholds')
        + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.withMode('absolute')
        + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.withSteps([
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('green')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(null),
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('orange')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(1000),
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('red')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(2000)
        ])
        + grafonnet.panel.barGauge.options.withOrientation('horizontal')
        + grafonnet.panel.barGauge.gridPos.withH(8)
        + grafonnet.panel.barGauge.gridPos.withW(12),

        $.barGaugePanel('Load Cycle Count', queries.loadCycleCount)
        + grafonnet.panel.barGauge.fieldConfig.defaults.withMin(0)
        + grafonnet.panel.barGauge.fieldConfig.defaults.color.withMode('thresholds')
        + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.withMode('absolute')
        + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.withSteps([
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('green')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(null),
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('orange')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(5000),
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('red')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(10000)
        ])
        + grafonnet.panel.barGauge.options.withOrientation('horizontal')
        + grafonnet.panel.barGauge.gridPos.withH(8)
        + grafonnet.panel.barGauge.gridPos.withW(12),

        $.barGaugePanel('Total Data Written', queries.totalDataWritten)
        + grafonnet.panel.barGauge.withDescription('Please note: This may be slightly incorrect')
        + grafonnet.panel.barGauge.fieldConfig.defaults.withMin(0)
        + grafonnet.panel.barGauge.fieldConfig.defaults.withUnit('decbytes')
        + grafonnet.panel.barGauge.fieldConfig.defaults.color.withMode('thresholds')
        + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.withMode('absolute')
        + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.withSteps([
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('green')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(null),
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('orange')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(40000000000000),
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('red')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(60000000000000)
        ])
        + grafonnet.panel.barGauge.options.withOrientation('horizontal')
        + grafonnet.panel.barGauge.gridPos.withH(8)
        + grafonnet.panel.barGauge.gridPos.withW(12),

        $.barGaugePanel('Reallocated Sector Events', queries.reallocatedSectorEvents)
        + grafonnet.panel.barGauge.fieldConfig.defaults.withMin(0)
        + grafonnet.panel.barGauge.fieldConfig.defaults.color.withMode('thresholds')
        + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.withMode('absolute')
        + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.withSteps([
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('green')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(null),
          grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withColor('red')
          + grafonnet.panel.barGauge.fieldConfig.defaults.thresholds.steps.withValue(1)
        ])
        + grafonnet.panel.barGauge.options.withOrientation('horizontal')
        + grafonnet.panel.barGauge.gridPos.withH(8)
        + grafonnet.panel.barGauge.gridPos.withW(12)
      ])
      + grafonnet.panel.row.gridPos.withH(1)
      + grafonnet.panel.row.gridPos.withW(24),

      $.row('Errors', collapsed=true)
      + grafonnet.panel.row.gridPos.withH(1)
      + grafonnet.panel.row.gridPos.withW(24),
    ])
  )
}
