local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local queries = import './queries.libsonnet';

local dashboard = grafonnet.dashboard;
local stat = grafonnet.panel.stat;
local table = grafonnet.panel.table;
local timeSeries = grafonnet.panel.timeSeries;

(import '../dashboard-utils.libsonnet') {
  'snmp-interface-status.json': (
    $.dashboard('SNMP Interface Status')
    + $.addVariable('cluster', 'ifOperStatus', 'cluster')
    + $.addVariable('instance', 'ifOperStatus{cluster=~"$cluster"}', 'instance')
    + $.addVariable('interface', 'ifOperStatus{cluster=~"$cluster", instance="$instance"}', 'ifDescr')
    + dashboard.withPanels(
      $.makeGrid([
        $.statPanel('Admin Status', queries.adminStatus)
        + stat.options.withGraphMode('none')
        + stat.standardOptions.withMappings([
          stat.valueMapping.ValueMap.withOptions({
            '1': {
              color: 'green',
              text: 'up',
            },
            '2': {
              color: 'orange',
              text: 'down',
            },
            '3': {
              color: 'orange',
              text: 'testing',
            },
          })
          + stat.valueMapping.ValueMap.withType('value'),
        ])
        + stat.standardOptions.color.withFixedColor('text')
        + stat.gridPos.withH(3)
        + stat.gridPos.withW(2),

        $.statPanel('Oper Status', queries.operStatus)
        + stat.options.withGraphMode('none')
        + stat.standardOptions.withMappings([
          stat.valueMapping.ValueMap.withOptions({
            '1': {
              color: 'green',
              text: 'up',
            },
            '2': {
              color: 'orange',
              text: 'down',
            },
            '3': {
              color: 'orange',
              text: 'testing',
            },
            '4': {
              color: 'orange',
              text: 'unknown',
            },
            '5': {
              color: 'orange',
              text: 'dormant',
            },
            '6': {
              color: 'orange',
              text: 'notPresent',
            },
            '7': {
              color: 'orange',
              text: 'lowerLayerDown',
            },
          })
          + stat.valueMapping.ValueMap.withType('value'),
        ])
        + stat.standardOptions.color.withFixedColor('text')
        + stat.gridPos.withH(3)
        + stat.gridPos.withW(2),

        $.statPanel('Last Change', queries.lastChange)
        + stat.options.withGraphMode('none')
        + stat.standardOptions.withUnit('timeticks')
        + stat.standardOptions.color.withMode('thresholds')
        + stat.standardOptions.thresholds.withMode('absolute')
        + stat.standardOptions.thresholds.withSteps([
          stat.thresholdStep.withColor('red')
          + stat.thresholdStep.withValue(null),
          stat.thresholdStep.withColor('orange')
          + stat.thresholdStep.withValue(360000),
          stat.thresholdStep.withColor('green')
          + stat.thresholdStep.withValue(8640000),
        ])
        + stat.gridPos.withH(3)
        + stat.gridPos.withW(3),

        $.statPanel('Connector Present', queries.connectorPresent)
        + stat.options.withGraphMode('none')
        + stat.standardOptions.withMappings([
          stat.valueMapping.ValueMap.withOptions({
            '1': {
              color: 'green',
              text: 'true',
            },
            '2': {
              color: 'orange',
              text: 'false',
            },
          })
          + stat.valueMapping.ValueMap.withType('value'),
        ])
        + stat.standardOptions.color.withFixedColor('text')
        + stat.gridPos.withH(3)
        + stat.gridPos.withW(2),

        $.statPanel('Promiscuous Mode', queries.promiscuousMode)
        + stat.options.withGraphMode('none')
        + stat.standardOptions.withMappings([
          stat.valueMapping.ValueMap.withOptions({
            '1': {
              color: 'orange',
              text: 'true',
            },
            '2': {
              color: 'green',
              text: 'false',
            },
          })
          + stat.valueMapping.ValueMap.withType('value'),
        ])
        + stat.standardOptions.color.withFixedColor('text')
        + stat.gridPos.withH(3)
        + stat.gridPos.withW(2),

        $.statPanel('Speed', queries.speed)
        + stat.options.withGraphMode('none')
        + stat.standardOptions.withUnit('bps')
        + stat.standardOptions.withMappings([
          stat.valueMapping.ValueMap.withOptions({
            '0': {
              text: 'N/A',
            },
          })
          + stat.valueMapping.ValueMap.withType('value'),
        ])
        + stat.standardOptions.color.withFixedColor('text')
        + stat.gridPos.withH(3)
        + stat.gridPos.withW(2),

        $.statPanel('MTU', queries.mtu)
        + stat.options.withGraphMode('none')
        + stat.standardOptions.color.withFixedColor('text')
        + stat.gridPos.withH(3)
        + stat.gridPos.withW(2),

        $.tablePanel('', queries.ifTypeInfo)
        + table.queryOptions.withTransformations([
          table.transformation.withId('organize')
          + table.transformation.withOptions({
            excludeByName: {
              Time: true,
              __name__: true,
              cluster: true,
              host: true,
              ifName: false,
              Value: true,
              namespace: true,
              job: true,
              instance: true,
              ifDescr: true,
            },
            indexByName: {
              Time: 0,
              __name__: 1,
              cluster: 2,
              host: 3,
              ifName: 4,
              ifAlias: 5,
              ifDescr: 6,
              ifIndex: 7,
              ifType: 8,
              instance: 9,
              job: 10,
              namespace: 11,
              Value: 12,
            },
            renameByName: {},
          }),
        ])
        + table.gridPos.withH(3)
        + table.gridPos.withW(9),

        $.timeseriesPanel('Traffic', queries.traffic)
        + timeSeries.options.legend.withShowLegend(false)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('bps')
        + timeSeries.gridPos.withH(9)
        + timeSeries.gridPos.withW(12),

        $.timeseriesPanel('Broadcast Packets', queries.broadcastPackets)
        + timeSeries.options.legend.withShowLegend(false)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('pps')
        + timeSeries.gridPos.withH(9)
        + timeSeries.gridPos.withW(12),

        $.timeseriesPanel('Unicast Packets', queries.unicastPackets)
        + timeSeries.options.legend.withShowLegend(false)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('pps')
        + timeSeries.gridPos.withH(9)
        + timeSeries.gridPos.withW(12),

        $.timeseriesPanel('Multicast Packets', queries.multicastPackets)
        + timeSeries.options.legend.withShowLegend(false)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('pps')
        + timeSeries.gridPos.withH(9)
        + timeSeries.gridPos.withW(12),

        $.timeseriesPanel('Errors', queries.errors)
        + timeSeries.options.legend.withShowLegend(false)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('pps')
        + timeSeries.gridPos.withH(9)
        + timeSeries.gridPos.withW(12),

        $.timeseriesPanel('Discards', queries.discards)
        + timeSeries.options.legend.withShowLegend(false)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.standardOptions.withUnit('pps')
        + timeSeries.gridPos.withH(9)
        + timeSeries.gridPos.withW(12),
      ])
    )
  ),
}
