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

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local dashboard = grafonnet.dashboard;
local grid = grafonnet.util.grid;
local prometheus = grafonnet.query.prometheus;
local stat = grafonnet.panel.stat;
local table = grafonnet.panel.table;
local timeSeries = grafonnet.panel.timeSeries;
local variable = grafonnet.dashboard.variable;

{
  grafanaDashboards+:: {
    'snmp-interface-status.json':
      dashboard.new('SNMP Interface Status')
      + dashboard.withTags(['generated', 'snmp_exporter'])
      + dashboard.withRefresh('1m')
      + dashboard.withVariables([
        variable.datasource.new('datasource', 'prometheus')
        + variable.datasource.generalOptions.withLabel('Datasource'),

        variable.query.new('cluster')
        + variable.query.withDatasource('prometheus', '${datasource}')
        + variable.query.generalOptions.withLabel('Cluster')
        + variable.query.queryTypes.withLabelValues('cluster', 'ifOperStatus'),

        variable.query.new('instance')
        + variable.query.withDatasource('prometheus', '${datasource}')
        + variable.query.generalOptions.withLabel('Instance')
        + variable.query.queryTypes.withLabelValues('instance', 'ifOperStatus{cluster=~"$cluster"}'),

        variable.query.new('interface')
        + variable.query.withDatasource('prometheus', '${datasource}')
        + variable.query.generalOptions.withLabel('Interface')
        + variable.query.queryTypes.withLabelValues('ifDescr', 'ifOperStatus{cluster=~"$cluster", instance=~"$instance"}'),
      ])
      + dashboard.withPanels(
        grid.wrapPanels([
          stat.new('Admin Status')
          + stat.gridPos.withH(3)
          + stat.gridPos.withW(2)
          + stat.options.withGraphMode('none')
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'ifAdminStatus{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
            + prometheus.withInstant(true),
          ])
          + stat.standardOptions.withMappings([
            stat.standardOptions.mapping.ValueMap.withOptions({
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
            + stat.standardOptions.mapping.ValueMap.withType(),
          ])
          + stat.standardOptions.color.withFixedColor('text')
          + stat.standardOptions.color.withMode('fixed'),

          stat.new('Oper Status')
          + stat.gridPos.withH(3)
          + stat.gridPos.withW(2)
          + stat.options.withGraphMode('none')
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'ifOperStatus{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
            + prometheus.withInstant(true),
          ])
          + stat.standardOptions.withMappings([
            stat.standardOptions.mapping.ValueMap.withOptions({
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
            + stat.standardOptions.mapping.ValueMap.withType(),
          ])
          + stat.standardOptions.color.withFixedColor('text')
          + stat.standardOptions.color.withMode('fixed'),

          stat.new('Last Change')
          + stat.gridPos.withH(3)
          + stat.gridPos.withW(3)
          + stat.options.withGraphMode('none')
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'sysUpTime{cluster="$cluster", instance="$instance"} - on(cluster, instance) ifLastChange{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
            + prometheus.withInstant(true),
          ])
          + stat.standardOptions.withUnit('timeticks')
          + stat.standardOptions.thresholds.withSteps([
            stat.standardOptions.threshold.step.withColor('red')
            + stat.standardOptions.threshold.step.withValue(null),
            stat.standardOptions.threshold.step.withColor('orange')
            + stat.standardOptions.threshold.step.withValue(360000),
            stat.standardOptions.threshold.step.withColor('green')
            + stat.standardOptions.threshold.step.withValue(8640000),
          ]),

          stat.new('Connector Present')
          + stat.gridPos.withH(3)
          + stat.gridPos.withW(2)
          + stat.options.withGraphMode('none')
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'ifConnectorPresent{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
            + prometheus.withInstant(true),
          ])
          + stat.standardOptions.withMappings([
            stat.standardOptions.mapping.ValueMap.withOptions({
              '1': {
                color: 'green',
                text: 'true',
              },
              '2': {
                color: 'orange',
                text: 'false',
              },
            })
            + stat.standardOptions.mapping.ValueMap.withType(),
          ])
          + stat.standardOptions.color.withFixedColor('text')
          + stat.standardOptions.color.withMode('fixed'),

          stat.new('Promiscuous Mode')
          + stat.gridPos.withH(3)
          + stat.gridPos.withW(2)
          + stat.options.withGraphMode('none')
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'ifPromiscuousMode{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
            + prometheus.withInstant(true),
          ])
          + stat.standardOptions.withMappings([
            stat.standardOptions.mapping.ValueMap.withOptions({
              '1': {
                color: 'orange',
                text: 'true',
              },
              '2': {
                color: 'green',
                text: 'false',
              },
            })
            + stat.standardOptions.mapping.ValueMap.withType(),
          ])
          + stat.standardOptions.color.withFixedColor('text')
          + stat.standardOptions.color.withMode('fixed'),

          stat.new('Speed')
          + stat.gridPos.withH(3)
          + stat.gridPos.withW(2)
          + stat.options.withGraphMode('none')
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'ifHighSpeed{cluster="$cluster", instance="$instance", ifDescr="$interface"} * 1000000 or ifSpeed{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
            + prometheus.withInstant(true),
          ])
          + stat.standardOptions.withMappings([
            stat.standardOptions.mapping.ValueMap.withOptions({
              '0': {
                text: 'N/A',
              },
            })
            + stat.standardOptions.mapping.ValueMap.withType(),
          ])
          + stat.standardOptions.withUnit('bps')
          + stat.standardOptions.color.withFixedColor('text')
          + stat.standardOptions.color.withMode('fixed'),

          stat.new('MTU')
          + stat.gridPos.withH(3)
          + stat.gridPos.withW(2)
          + stat.options.withGraphMode('none')
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'ifMtu{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
            + prometheus.withInstant(true),
          ])
          + stat.standardOptions.withMappings([
            stat.standardOptions.mapping.ValueMap.withOptions({
              '0': {
                text: 'N/A',
              },
            })
            + stat.standardOptions.mapping.ValueMap.withType(),
          ])
          + stat.standardOptions.color.withFixedColor('text')
          + stat.standardOptions.color.withMode('fixed'),

          table.new('')
          + table.gridPos.withH(3)
          + table.gridPos.withW(9)
          + table.queryOptions.withDatasource('prometheus', '${datasource}')
          + table.queryOptions.withTargets([
            prometheus.new('$datasource', 'ifType_info{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
            + prometheus.withFormat('table')
            + prometheus.withInstant(true),
          ])
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

          timeSeries.new('Traffic')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.legend.withShowLegend(false)
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.options.tooltip.withSort('desc')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', '(rate(ifHCInOctets{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifInOctets{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval])) * 8')
            + prometheus.withInterval('30s')
            + prometheus.withLegendFormat('IN: {{ifDescr}}'),

            prometheus.new('$datasource', '(rate(ifHCOutOctets{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifOutOctets{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval])) * 8')
            + prometheus.withInterval('30s')
            + prometheus.withLegendFormat('OUT: {{ifDescr}}'),
          ])
          + timeSeries.standardOptions.withUnit('bps'),

          timeSeries.new('Broadcast Packets')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.legend.withShowLegend(false)
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.options.tooltip.withSort('desc')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', '(rate(ifHCInBroadcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifInBroadcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]))')
            + prometheus.withInterval('30s')
            + prometheus.withLegendFormat('IN: {{ifDescr}}'),

            prometheus.new('$datasource', '(rate(ifHCOutBroadcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifOutBroadcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]))')
            + prometheus.withInterval('30s')
            + prometheus.withLegendFormat('OUT: {{ifDescr}}'),
          ])
          + timeSeries.standardOptions.withUnit('pps'),

          timeSeries.new('Unicast Packets')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.legend.withShowLegend(false)
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.options.tooltip.withSort('desc')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', '(rate(ifHCInUcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifInUcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]))')
            + prometheus.withInterval('30s')
            + prometheus.withLegendFormat('IN: {{ifDescr}}'),

            prometheus.new('$datasource', '(rate(ifHCOutUcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifOutUcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]))')
            + prometheus.withInterval('30s')
            + prometheus.withLegendFormat('OUT: {{ifDescr}}'),
          ])
          + timeSeries.standardOptions.withUnit('pps'),

          timeSeries.new('Multicast Packets')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.legend.withShowLegend(false)
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.options.tooltip.withSort('desc')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', '(rate(ifHCInMulticastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifInMulticastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]))')
            + prometheus.withInterval('30s')
            + prometheus.withLegendFormat('IN: {{ifDescr}}'),

            prometheus.new('$datasource', '(rate(ifHCOutMulticastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifOutMulticastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]))')
            + prometheus.withInterval('30s')
            + prometheus.withLegendFormat('OUT: {{ifDescr}}'),
          ])
          + timeSeries.standardOptions.withUnit('pps'),

          timeSeries.new('Errors')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.legend.withShowLegend(false)
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.options.tooltip.withSort('desc')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', 'rate(ifInErrors{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval])')
            + prometheus.withInterval('30s')
            + prometheus.withLegendFormat('IN: {{ifDescr}}'),

            prometheus.new('$datasource', 'rate(ifOutErrors{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval])')
            + prometheus.withInterval('30s')
            + prometheus.withLegendFormat('OUT: {{ifDescr}}'),
          ])
          + timeSeries.standardOptions.withUnit('pps'),

          timeSeries.new('Discards')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.legend.withShowLegend(false)
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.options.tooltip.withSort('desc')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', 'rate(ifInDiscards{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval])')
            + prometheus.withInterval('30s')
            + prometheus.withLegendFormat('IN discards: {{ifDescr}}'),

            prometheus.new('$datasource', 'rate(ifInUnknownProtos{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval])')
            + prometheus.withInterval('30s')
            + prometheus.withLegendFormat('IN unknown protos: {{ifDescr}}'),

            prometheus.new('$datasource', 'rate(ifOutDiscards{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval])')
            + prometheus.withInterval('30s')
            + prometheus.withLegendFormat('OUT discards: {{ifDescr}}'),
          ])
          + timeSeries.standardOptions.withUnit('pps'),
        ])
      ),
  },
}
