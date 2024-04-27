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
local stat = grafonnet.panel.stat;
local table = grafonnet.panel.table;
local timeSeries = grafonnet.panel.timeSeries;

{
  'snmp-interface-status.json': (
    util.dashboard('SNMP Interface Status', tags=['generated', 'snmp'])
    + util.addVariable('cluster', 'ifOperStatus', 'cluster')
    + util.addVariable('instance', 'ifOperStatus{cluster="$cluster"}', 'instance')
    + util.addVariable('interface', 'ifOperStatus{cluster="$cluster", instance="$instance"}', 'ifDescr')
    + dashboard.withPanels(
      util.makeGrid([
        util.stat.base('Admin Status', queries.adminStatus, height=3, width=2)
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
        + stat.standardOptions.color.withFixedColor('text'),

        util.stat.base('Oper Status', queries.operStatus, height=3, width=2)
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
        + stat.standardOptions.color.withFixedColor('text'),

        util.stat.base('Last Change', queries.lastChange, height=3, width=3)
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
        ]),

        util.stat.base('Connector Present', queries.connectorPresent, height=3, width=2)
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
        + stat.standardOptions.color.withFixedColor('text'),

        util.stat.base('Promiscuous Mode', queries.promiscuousMode, height=3, width=2)
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
        + stat.standardOptions.color.withFixedColor('text'),

        util.stat.base('Speed', queries.speed, height=3, width=2)
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
        + stat.standardOptions.color.withFixedColor('text'),

        util.stat.base('MTU', queries.mtu, height=3, width=2)
        + stat.options.withGraphMode('none')
        + stat.standardOptions.color.withFixedColor('text'),

        util.table.base('', queries.ifTypeInfo, height=3, width=9)
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
        ]),

        util.timeSeries.base('Traffic', queries.traffic)
        + timeSeries.options.legend.withShowLegend(false)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.queryOptions.withInterval('2m')
        + timeSeries.standardOptions.withUnit('bps'),

        util.timeSeries.base('Broadcast Packets', queries.broadcastPackets)
        + timeSeries.options.legend.withShowLegend(false)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.queryOptions.withInterval('2m')
        + timeSeries.standardOptions.withUnit('pps'),

        util.timeSeries.base('Unicast Packets', queries.unicastPackets)
        + timeSeries.options.legend.withShowLegend(false)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.queryOptions.withInterval('2m')
        + timeSeries.standardOptions.withUnit('pps'),

        util.timeSeries.base('Multicast Packets', queries.multicastPackets)
        + timeSeries.options.legend.withShowLegend(false)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.queryOptions.withInterval('2m')
        + timeSeries.standardOptions.withUnit('pps'),

        util.timeSeries.base('Errors', queries.errors)
        + timeSeries.options.legend.withShowLegend(false)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.queryOptions.withInterval('2m')
        + timeSeries.standardOptions.withUnit('pps'),

        util.timeSeries.base('Discards', queries.discards)
        + timeSeries.options.legend.withShowLegend(false)
        + timeSeries.options.tooltip.withMode('multi')
        + timeSeries.options.tooltip.withSort('desc')
        + timeSeries.queryOptions.withInterval('2m')
        + timeSeries.standardOptions.withUnit('pps'),
      ])
    )
  ),
}
