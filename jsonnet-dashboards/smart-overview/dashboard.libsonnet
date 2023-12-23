local util = import '../dashboard-utils.libsonnet';
local grafonnet = import '../g.libsonnet';

local queries = import './queries.libsonnet';

local barGauge = grafonnet.panel.barGauge;
local dashboard = grafonnet.dashboard;
local row = grafonnet.panel.row;
local stat = grafonnet.panel.stat;
local table = grafonnet.panel.table;
local timeSeries = grafonnet.panel.timeSeries;

{
  'smart-overview.json': (
    util.dashboard('SMART Overview', tags=['generated', 'smart'])
    + util.addMultiVariable('cluster', 'smartmon_smartctl_version', 'cluster')
    + util.addMultiVariable('namespace', 'smartmon_smartctl_version{cluster=~"$cluster"}', 'namespace')
    + util.addMultiVariable('host', 'smartmon_smartctl_version{cluster=~"$cluster", namespace=~"$namespace"}', 'host')
    + dashboard.withPanels(
      util.makeGrid([
        util.row('Overview'),

        util.stat.base('Disks Monitored', queries.disksMonitored, height=4, width=4)
        + stat.options.withGraphMode('none')
        + stat.standardOptions.color.withFixedColor('text'),

        util.table.base('Disk Drives', queries.diskDrives, width=20)
        + util.table.withFilterable(true)
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
        ]),

        util.stat.base('Unhealthy Disks', queries.unhealthyDisks, height=4, width=4)
        + stat.options.withColorMode('background')
        + stat.options.withGraphMode('none')
        + stat.standardOptions.color.withMode('thresholds')
        + stat.standardOptions.thresholds.withMode('absolute')
        + stat.standardOptions.thresholds.withSteps([
          stat.thresholdStep.withColor('green')
          + stat.thresholdStep.withValue(null),
          stat.thresholdStep.withColor('red')
          + stat.thresholdStep.withValue(1),
        ]),

        util.row('Temperature', collapsed=true)
        + row.withPanels([
          util.timeSeries.base('Temperature History', queries.temperatureHistory, width=24)
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
          + timeSeries.standardOptions.withUnit('celsius'),
        ]),

        util.row('Wear & Tear', collapsed=true)
        + row.withPanels(
          util.makeGrid([
            util.barGauge.base('Power On Hours', queries.powerOnHours)
            + barGauge.options.withOrientation('auto')
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
            ]),

            util.barGauge.base('Start Stop Count', queries.startStopCount)
            + barGauge.options.withOrientation('auto')
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
            ]),

            util.barGauge.base('Power Cycle Count', queries.powerCycleCount)
            + barGauge.options.withOrientation('auto')
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
            ]),

            util.barGauge.base('Load Cycle Count', queries.loadCycleCount)
            + barGauge.options.withOrientation('auto')
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
            ]),

            util.barGauge.base('Total Data Written', queries.totalDataWritten)
            + barGauge.options.withOrientation('auto')
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
            ]),

            util.barGauge.base('Reallocated Sector Events', queries.reallocatedSectorEvents)
            + barGauge.options.withOrientation('auto')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(1),
            ]),
          ])
        ),

        util.row('Errors', collapsed=true)
        + row.withPanels(
          util.makeGrid([
            util.barGauge.base('Raw Read Error', queries.rawReadError)
            + barGauge.options.withOrientation('auto')
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
            ]),

            util.barGauge.base('Seek Error Rate', queries.seekErrorRate)
            + barGauge.options.withOrientation('auto')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(60),
            ]),

            util.barGauge.base('Spin Retry Count', queries.spinRetryCount)
            + barGauge.options.withOrientation('auto')
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
            ]),

            util.barGauge.base('Command Timeout Count', queries.commandTimeoutCount)
            + barGauge.options.withOrientation('auto')
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
            ]),

            util.barGauge.base('Current Pending Sector Count', queries.currentPendingSectorCount)
            + barGauge.options.withOrientation('auto')
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
            ]),

            util.barGauge.base('Offline Uncorrectable Sector Count', queries.offlineUncorrectableSectorCount)
            + barGauge.options.withOrientation('auto')
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
            ]),

            util.barGauge.base('Reported Uncorrectable Errors', queries.reportedUncorrectableErrors)
            + barGauge.options.withOrientation('auto')
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
            ]),

            util.barGauge.base('UltraDMA CRC Error', queries.ultradmaCrcError)
            + barGauge.options.withOrientation('auto')
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.color.withMode('thresholds')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.thresholdStep.withColor('green')
              + barGauge.thresholdStep.withValue(null),
              barGauge.thresholdStep.withColor('red')
              + barGauge.thresholdStep.withValue(1),
            ]),
          ])
        ),
      ])
    )
  ),
}
