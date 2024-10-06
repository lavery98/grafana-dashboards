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
local stateTimeline = grafonnet.panel.stateTimeline;
local table = grafonnet.panel.table;
local timeSeries = grafonnet.panel.timeSeries;
local variable = grafonnet.dashboard.variable;

{
  grafanaDashboards+:: {
    'blackbox-exporter-overview.json':
      dashboard.new('Blackbox Exporter Overview')
      + dashboard.withTags(['generated', 'blackbox_exporter'])
      + dashboard.withRefresh('1m')
      + dashboard.withVariables([
        variable.datasource.new('datasource', 'prometheus')
        + variable.datasource.generalOptions.withLabel('Datasource'),

        variable.query.new('cluster')
        + variable.query.withDatasource('prometheus', '${datasource}')
        + variable.query.generalOptions.withLabel('Cluster')
        + variable.query.queryTypes.withLabelValues('cluster', 'probe_success')
        + variable.query.selectionOptions.withIncludeAll(true, '.+')
        + variable.query.selectionOptions.withMulti(),

        variable.query.new('job')
        + variable.query.withDatasource('prometheus', '${datasource}')
        + variable.query.generalOptions.withLabel('Job')
        + variable.query.queryTypes.withLabelValues('job', 'probe_success{cluster=~"$cluster"}')
        + variable.query.selectionOptions.withIncludeAll(true, '.+')
        + variable.query.selectionOptions.withMulti(),
      ])
      + dashboard.withPanels(
        grid.wrapPanels([
          table.new('Probes (Up/Down) - Current Status')
          + table.gridPos.withH(8)
          + table.gridPos.withW(12)
          + table.queryOptions.withDatasource('prometheus', '${datasource}')
          + table.queryOptions.withTargets([
            prometheus.new('$datasource', 'probe_success{cluster=~"$cluster", job=~"$job"}')
            + prometheus.withFormat('table')
            + prometheus.withInstant(true),
          ])
          + table.queryOptions.withTransformations([
            table.transformation.withId('organize')
            + table.transformation.withOptions({
              excludeByName: {
                Time: true,
                __name__: true,
                host: true,
                namespace: true,
              },
              indexByName: {},
              renameByName: {
                cluster: 'Cluster',
                instance: 'Instance',
                job: 'Job',
                Value: 'Status',
              },
            }),
          ])
          + table.standardOptions.withOverrides([
            table.fieldOverride.byName.new('Status')
            + table.fieldOverride.byName.withPropertiesFromOptions(
              table.standardOptions.withMappings([
                table.valueMapping.ValueMap.withOptions({
                  '0': {
                    color: 'red',
                    text: 'Down',
                  },
                  '1': {
                    color: 'green',
                    text: 'Up',
                  },
                })
                + table.valueMapping.ValueMap.withType(),
              ])
            )
            + table.fieldOverride.byName.withProperty('custom.cellOptions', {
              type: 'color-background',
            }),
          ]),

          stateTimeline.new('Probes (Up/Down) - Historic Status')
          + stateTimeline.gridPos.withH(8)
          + stateTimeline.gridPos.withW(12)
          + stateTimeline.queryOptions.withDatasource('prometheus', '${datasource}')
          + stateTimeline.queryOptions.withTargets([
            prometheus.new('$datasource', 'probe_success{cluster=~"$cluster", job=~"$job"}')
            + prometheus.withLegendFormat('{{instance}}'),
          ])
          + stateTimeline.options.withRowHeight(0.5)
          + stateTimeline.options.withShowValue('never')
          + stateTimeline.standardOptions.withMappings([
            stateTimeline.standardOptions.mapping.ValueMap.withOptions({
              '0': {
                color: 'red',
                text: 'Down',
              },
              '1': {
                color: 'green',
                text: 'Up',
              },
            })
            + stateTimeline.standardOptions.mapping.ValueMap.withType(),
          ])
          + stateTimeline.standardOptions.color.withMode('continuous-RdYlGr'),

          table.new('SSL Certificate Expiry')
          + table.gridPos.withH(8)
          + table.gridPos.withW(12)
          + table.queryOptions.withDatasource('prometheus', '${datasource}')
          + table.queryOptions.withTargets([
            prometheus.new('$datasource', 'probe_ssl_earliest_cert_expiry{cluster=~"$cluster", job=~"$job"} - time()')
            + prometheus.withFormat('table')
            + prometheus.withInstant(true),
          ])
          + table.queryOptions.withTransformations([
            table.transformation.withId('organize')
            + table.transformation.withOptions({
              excludeByName: {
                Time: true,
                __name__: true,
                host: true,
                namespace: true,
              },
              indexByName: {},
              renameByName: {
                cluster: 'Cluster',
                instance: 'Instance',
                job: 'Job',
                Value: 'Time left',
              },
            }),
          ])
          + table.standardOptions.withOverrides([
            table.fieldOverride.byName.new('Time left')
            + table.fieldOverride.byName.withPropertiesFromOptions(
              table.standardOptions.withUnit('s')
            )
            + table.fieldOverride.byName.withProperty('custom.cellOptions', {
              type: 'color-background',
            }),
          ])
          + table.standardOptions.thresholds.withMode('absolute')
          + table.standardOptions.thresholds.withSteps([
            table.thresholdStep.withColor('red')
            + table.thresholdStep.withValue(null),
            table.thresholdStep.withColor('orange')
            + table.thresholdStep.withValue(604800),
            table.thresholdStep.withColor('green')
            + table.thresholdStep.withValue(2419200),
          ]),

          timeSeries.new('DNS Lookup')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.options.tooltip.withSort('desc')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', 'probe_dns_lookup_time_seconds{cluster=~"$cluster", job=~"$job"}')
            + prometheus.withLegendFormat('{{instance}}'),
          ])
          + timeSeries.standardOptions.withUnit('s'),

          timeSeries.new('Probe Duration')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(24)
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.options.tooltip.withSort('desc')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', 'probe_duration_seconds{cluster=~"$cluster", job=~"$job"}')
            + prometheus.withLegendFormat('{{instance}}'),
          ])
          + timeSeries.standardOptions.withUnit('s'),
        ])
      ),
  },
}
