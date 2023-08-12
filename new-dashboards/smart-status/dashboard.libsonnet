local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local queries = import './queries.libsonnet';

local dashboard = grafonnet.dashboard;
local barGauge = grafonnet.panel.barGauge;
local row = grafonnet.panel.row;
local stat = grafonnet.panel.stat;
local table = grafonnet.panel.table;
local timeSeries = grafonnet.panel.timeSeries;

(import '../dashboard-utils.libsonnet') {
  'smart-status.json': (
    $.dashboard('S.M.A.R.T Status')
    + $.addVariable('cluster', 'smartmon_smartctl_version', 'cluster')
    + $.addVariable('namespace', 'smartmon_smartctl_version{cluster=~"$cluster"}', 'namespace')
    + $.addVariable('host', 'smartmon_smartctl_version{cluster=~"$cluster", namespace=~"$namespace"}', 'host')
    + grafonnet.dashboard.withPanels(
      $.makeGrid([
        $.row('Overview')
        + row.gridPos.withH(1)
        + row.gridPos.withW(24),

        $.statPanel('Disks Monitored', queries.disksMonitored)
        + stat.options.withGraphMode('none')
        + stat.standardOptions.color.withFixedColor('text')
        + stat.gridPos.withH(4)
        + stat.gridPos.withW(4),

        $.tablePanel('Disk Drives', queries.diskDrives)
        + table.fieldConfig.defaults.withCustom({
          filterable: true,
        })
        + table.options.footer.TableFooterOptions.withEnablePagination(true)
        + table.queryOptions.withTransformations([
          table.transformation.withId('organize')
          + table.transformation.withOptions({
            excludeByName: {
              Time: true,
              __name__: true,
              agent_hostname: true,
              cluster: true,
              host: true,
              instance: true,
              job: true,
              namespace: true,
              lun_id: true,
              product: true,
              revision: true,
              vendor: true,
              Value: true,
            },
            indexByName: {},
            renameByName: {
              device: 'Device',
              device_model: 'Device Model',
              disk: 'Disk',
              firmware_version: 'Firmware',
              model_family: 'Model Family',
              serial_number: 'Serial Number',
            },
          }),
        ])
        + table.gridPos.withH(8)
        + table.gridPos.withW(20),

        $.statPanel('Unhealthy Disks', queries.unhealthyDisks)
        + stat.options.withColorMode('background')
        + stat.options.withGraphMode('none')
        + stat.standardOptions.color.withMode('thresholds')
        + stat.standardOptions.thresholds.withMode('absolute')
        + stat.standardOptions.thresholds.withSteps([
          stat.thresholdStep.withColor('green')
          + stat.thresholdStep.withValue(null),
          stat.thresholdStep.withColor('red')
          + stat.thresholdStep.withValue(1),
        ])
        + stat.gridPos.withH(4)
        + stat.gridPos.withW(4),

        $.row('Temperature', collapsed=true)
        + row.withPanels([
          $.timeseriesPanel('Temperature History', queries.temperatureHistory)
          + timeSeries.options.legend.withCalcs([
            'mean',
            'min',
            'max',
            'lastNotNull',
          ])
          + timeSeries.options.legend.withDisplayMode('table')
          + timeSeries.options.legend.withPlacement('right')
          + timeSeries.options.legend.withShowLegend(true)
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.options.tooltip.withSort('none')
          + timeSeries.standardOptions.withUnit('celsius')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(24),
        ])
        + row.gridPos.withH(1)
        + row.gridPos.withW(24),

        $.row('Wear & Tear', collapsed=true)
        + row.withPanels(
          $.makeGrid([
            $.barGaugePanel('Power On Hours', queries.powerOnHours)
            + barGauge.options.withOrientation('horizontal')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.withUnit('h')
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('orange')
              + barGauge.thresholdStep.withValue(17520),
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(35040),
            ])
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12),

            $.barGaugePanel('Start Stop Count', queries.startStopCount)
            + barGauge.options.withOrientation('horizontal')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('orange')
              + barGauge.thresholdStep.withValue(750),
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(1500),
            ])
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12),

            $.barGaugePanel('Power Cycle Count', queries.powerCycleCount)
            + barGauge.options.withOrientation('horizontal')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('orange')
              + barGauge.thresholdStep.withValue(1000),
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(2000),
            ])
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12),

            $.barGaugePanel('Load Cycle Count', queries.loadCycleCount)
            + barGauge.options.withOrientation('horizontal')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('orange')
              + barGauge.thresholdStep.withValue(5000),
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(10000),
            ])
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12),

            $.barGaugePanel('Total Data Written', queries.totalDataWritten)
            + barGauge.options.withOrientation('horizontal')
            + barGauge.panelOptions.withDescription('Please note: This may be slightly incorrect')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.withUnit('decbytes')
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('orange')
              + barGauge.thresholdStep.withValue(40000000000000),
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(60000000000000),
            ])
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12),

            $.barGaugePanel('Reallocated Sector Events', queries.reallocatedSectorEvents)
            + barGauge.options.withOrientation('horizontal')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(1),
            ])
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12),
          ])
        )
        + row.gridPos.withH(1)
        + row.gridPos.withW(24),

        $.row('Errors', collapsed=true)
        + row.withPanels(
          $.makeGrid([
            $.barGaugePanel('Raw Read Error', queries.rawReadError)
            + barGauge.options.withOrientation('horizontal')
            + barGauge.standardOptions.withMax(100)
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.withUnit('percent')
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(100),
            ])
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12),

            $.barGaugePanel('Seek Error Rate', queries.seekErrorRate)
            + barGauge.options.withOrientation('horizontal')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(60),
            ])
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12),

            $.barGaugePanel('Spin Retry Count', queries.spinRetryCount)
            + barGauge.options.withOrientation('horizontal')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('orange')
              + barGauge.thresholdStep.withValue(1),
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(10),
            ])
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12),

            $.barGaugePanel('Command Timeout Count', queries.commandTimeoutCount)
            + barGauge.options.withOrientation('horizontal')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('orange')
              + barGauge.thresholdStep.withValue(1),
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(10),
            ])
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12),

            $.barGaugePanel('Current Pending Sector Count', queries.currentPendingSectorCount)
            + barGauge.options.withOrientation('horizontal')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('orange')
              + barGauge.thresholdStep.withValue(1),
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(10),
            ])
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12),

            $.barGaugePanel('Offline Uncorrectable Sector Count', queries.offlineUncorrectableSectorCount)
            + barGauge.options.withOrientation('horizontal')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('orange')
              + barGauge.thresholdStep.withValue(1),
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(10),
            ])
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12),

            $.barGaugePanel('Reported Uncorrectable Errors', queries.reportedUncorrectableErrors)
            + barGauge.options.withOrientation('horizontal')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('orange')
              + barGauge.thresholdStep.withValue(1),
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(10),
            ])
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12),

            $.barGaugePanel('UltraDMA CRC Error', queries.ultradmaCrcError)
            + barGauge.options.withOrientation('horizontal')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(1),
            ])
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12),
          ])
        )
        + row.gridPos.withH(1)
        + row.gridPos.withW(24),
      ])
    )
  ),
}
