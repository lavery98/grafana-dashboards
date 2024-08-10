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
local timeSeries = grafonnet.panel.timeSeries;
local variable = grafonnet.dashboard.variable;

{
  grafanaDashboards+:: {
    'docker-overview.json':
      dashboard.new('Docker Overview')
      + dashboard.withTags(['generated', 'docker', 'cadvisor'])
      + dashboard.withRefresh('1m')
      + dashboard.withVariables([
        variable.datasource.new('datasource', 'prometheus')
        + variable.datasource.generalOptions.withLabel('Datasource'),

        variable.query.new('cluster')
        + variable.query.withDatasource('prometheus', '${datasource}')
        + variable.query.generalOptions.withLabel('Cluster')
        + variable.query.queryTypes.withLabelValues('cluster', 'cadvisor_version_info')
        + variable.query.selectionOptions.withIncludeAll(true, '.+')
        + variable.query.selectionOptions.withMulti(),

        variable.query.new('namespace')
        + variable.query.withDatasource('prometheus', '${datasource}')
        + variable.query.generalOptions.withLabel('Namespace')
        + variable.query.queryTypes.withLabelValues('namespace', 'cadvisor_version_info{cluster=~"$cluster"}')
        + variable.query.selectionOptions.withIncludeAll(true, '.+')
        + variable.query.selectionOptions.withMulti(),

        variable.query.new('host')
        + variable.query.withDatasource('prometheus', '${datasource}')
        + variable.query.generalOptions.withLabel('Host')
        + variable.query.queryTypes.withLabelValues('host', 'cadvisor_version_info{cluster=~"$cluster", namespace=~"$namespace"}')
        + variable.query.selectionOptions.withIncludeAll(true, '.+')
        + variable.query.selectionOptions.withMulti(),
      ])
      + dashboard.withPanels(
        grid.wrapPanels([
          stat.new('Containers')
          + stat.gridPos.withH(4)
          + stat.gridPos.withW(4)
          + stat.options.withGraphMode('none')
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'count(container_start_time_seconds{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"})')
            + prometheus.withInstant(true)
          ])
          + stat.standardOptions.color.withFixedColor('text')
          + stat.standardOptions.color.withMode('fixed'),

          stat.new('Total CPU Usage')
          + stat.gridPos.withH(4)
          + stat.gridPos.withW(4)
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'sum(rate(container_cpu_usage_seconds_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval])) * 100')
          ])
          + stat.standardOptions.withMin(0)
          + stat.standardOptions.withUnit('percent')
          + stat.standardOptions.color.withMode('palette-classic'),

          stat.new('Total Memory Usage')
          + stat.gridPos.withH(4)
          + stat.gridPos.withW(4)
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'sum(container_memory_rss{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"})')
          ])
          + stat.standardOptions.withMin(0)
          + stat.standardOptions.withUnit('bytes')
          + stat.standardOptions.color.withMode('palette-classic'),

          stat.new('Total Swap Usage')
          + stat.gridPos.withH(4)
          + stat.gridPos.withW(4)
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'sum(container_memory_swap{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"})')
          ])
          + stat.standardOptions.withMin(0)
          + stat.standardOptions.withUnit('bytes')
          + stat.standardOptions.color.withMode('palette-classic'),

          stat.new('Total Received Network Traffic')
          + stat.gridPos.withH(4)
          + stat.gridPos.withW(4)
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'sum(rate(container_network_receive_bytes_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval]))')
          ])
          + stat.standardOptions.withMin(0)
          + stat.standardOptions.withUnit('Bps')
          + stat.standardOptions.color.withMode('palette-classic'),

          stat.new('Total Sent Network Traffic')
          + stat.gridPos.withH(4)
          + stat.gridPos.withW(4)
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'sum(rate(container_network_transmit_bytes_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval]))')
          ])
          + stat.standardOptions.withMin(0)
          + stat.standardOptions.withUnit('Bps')
          + stat.standardOptions.color.withMode('palette-classic'),

          timeSeries.new('CPU Usage per Container')
          + timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
          + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
          + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.legend.withPlacement('right')
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.options.tooltip.withSort('desc')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', 'sum(rate(container_cpu_usage_seconds_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval])) by (name) * 100')
            + prometheus.withLegendFormat('{{ name }}')
          ])
          + timeSeries.standardOptions.withUnit('percent'),

          timeSeries.new('Memory Usage per Container')
          + timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
          + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
          + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.legend.withPlacement('right')
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.options.tooltip.withSort('desc')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', 'sum(container_memory_rss{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}) by (name)')
            + prometheus.withLegendFormat('{{ name }}')
          ])
          + timeSeries.standardOptions.withUnit('bytes'),

          timeSeries.new('Received Network Traffic per Container')
          + timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
          + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
          + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.legend.withPlacement('right')
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.options.tooltip.withSort('desc')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', 'sum(rate(container_network_receive_bytes_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval])) by (name)')
            + prometheus.withLegendFormat('{{ name }}')
          ])
          + timeSeries.standardOptions.withUnit('Bps'),

          timeSeries.new('Sent Network Traffic per Container')
          + timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
          + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
          + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.legend.withPlacement('right')
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.options.tooltip.withSort('desc')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', 'sum(rate(container_network_transmit_bytes_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval])) by (name)')
            + prometheus.withLegendFormat('{{ name }}')
          ])
          + timeSeries.standardOptions.withUnit('Bps'),

          timeSeries.new('Filesystem Reads per Container')
          + timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
          + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
          + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.legend.withPlacement('right')
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.options.tooltip.withSort('desc')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', 'sum(rate(container_fs_reads_bytes_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval])) by (name)')
            + prometheus.withLegendFormat('{{ name }}')
          ])
          + timeSeries.standardOptions.withUnit('Bps'),

          timeSeries.new('Filesystem Writes per Container')
          + timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
          + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
          + timeSeries.fieldConfig.defaults.custom.stacking.withMode('normal')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.legend.withPlacement('right')
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.options.tooltip.withSort('desc')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', 'sum(rate(container_fs_writes_bytes_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval])) by (name)')
            + prometheus.withLegendFormat('{{ name }}')
          ])
          + timeSeries.standardOptions.withUnit('Bps')
        ])
      )
  }
}
