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
local row = grafonnet.panel.row;
local stat = grafonnet.panel.stat;
local timeSeries = grafonnet.panel.timeSeries;
local variable = grafonnet.dashboard.variable;

{
  grafanaDashboards+:: {
    'bind-overview.json':
      dashboard.new('Bind Overview')
      + dashboard.withTags(['generated', 'bind_exporter'])
      + dashboard.withRefresh('1m')
      + dashboard.withVariables([
        variable.datasource.new('datasource', 'prometheus')
        + variable.datasource.generalOptions.withLabel('Datasource'),

        variable.query.new('cluster')
        + variable.query.withDatasource('prometheus', '${datasource}')
        + variable.query.generalOptions.withLabel('Cluster')
        + variable.query.queryTypes.withLabelValues('cluster', 'bind_exporter_build_info')
        + variable.query.selectionOptions.withIncludeAll(true, '.+')
        + variable.query.selectionOptions.withMulti(),

        variable.query.new('namespace')
        + variable.query.withDatasource('prometheus', '${datasource}')
        + variable.query.generalOptions.withLabel('Namespace')
        + variable.query.queryTypes.withLabelValues('namespace', 'bind_exporter_build_info{cluster=~"$cluster"}')
        + variable.query.selectionOptions.withIncludeAll(true, '.+')
        + variable.query.selectionOptions.withMulti(),

        variable.query.new('host')
        + variable.query.withDatasource('prometheus', '${datasource}')
        + variable.query.generalOptions.withLabel('Host')
        + variable.query.queryTypes.withLabelValues('host', 'bind_exporter_build_info{cluster=~"$cluster", namespace=~"$namespace"}')
        + variable.query.selectionOptions.withIncludeAll(true, '.+')
        + variable.query.selectionOptions.withMulti(),
      ])
      + dashboard.withPanels(
        grid.wrapPanels([
          row.new('General'),

          timeSeries.new('All DNS Queries')
          + timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
          + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(24)
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', 'sum(irate(bind_incoming_queries_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval]))')
            + prometheus.withLegendFormat('Incoming'),

            prometheus.new('$datasource', 'sum(irate(bind_resolver_queries_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval]))')
            + prometheus.withLegendFormat('Outgoing'),
          ]),

          timeSeries.new('Incoming DNS Queries')
          + timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
          + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', 'irate(bind_incoming_queries_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
            + prometheus.withLegendFormat('{{ type }}'),
          ]),

          timeSeries.new('Outgoing DNS Queries')
          + timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
          + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', 'irate(bind_resolver_queries_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
            + prometheus.withLegendFormat('{{ type }}'),
          ]),

          timeSeries.new('Incoming Requests')
          + timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
          + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', 'irate(bind_incoming_requests_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
            + prometheus.withLegendFormat('{{ opcode }}'),
          ]),

          timeSeries.new('Responses Sent')
          + timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
          + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
          + timeSeries.gridPos.withH(8)
          + timeSeries.gridPos.withW(12)
          + timeSeries.options.tooltip.withMode('multi')
          + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
          + timeSeries.queryOptions.withTargets([
            prometheus.new('$datasource', 'irate(bind_responses_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
            + prometheus.withLegendFormat('{{ result }}'),
          ]),

          stat.new('Last Restarted')
          + stat.gridPos.withH(3)
          + stat.gridPos.withW(12)
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'bind_boot_time_seconds{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"} * 1000')
            + prometheus.withInstant(true),
          ])
          + stat.standardOptions.color.withFixedColor('text')
          + stat.standardOptions.color.withMode('fixed')
          + stat.standardOptions.withUnit('dateTimeAsIso'),

          stat.new('Last Reconfigured')
          + stat.gridPos.withH(3)
          + stat.gridPos.withW(12)
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'bind_config_time_seconds{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"} * 1000')
            + prometheus.withInstant(true),
          ])
          + stat.standardOptions.color.withFixedColor('text')
          + stat.standardOptions.color.withMode('fixed')
          + stat.standardOptions.withUnit('dateTimeAsIso'),

          row.new('Issues')
          + row.withCollapsed(true)
          + row.withPanels([
            timeSeries.new('Resolver Query Retries')
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
            + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
            + timeSeries.gridPos.withH(8)
            + timeSeries.gridPos.withW(12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
            + timeSeries.queryOptions.withTargets([
              prometheus.new('$datasource', 'irate(bind_resolver_query_retries_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
              + prometheus.withLegendFormat('queries retried {{ view }}'),
            ]),

            timeSeries.new('Query Issues')
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
            + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
            + timeSeries.gridPos.withH(8)
            + timeSeries.gridPos.withW(12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
            + timeSeries.queryOptions.withTargets([
              prometheus.new('$datasource', 'irate(bind_query_duplicates_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
              + prometheus.withLegendFormat('Duplicated queries received'),

              prometheus.new('$datasource', 'irate(bind_query_errors_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
              + prometheus.withLegendFormat('{{ error }} queries'),

              prometheus.new('$datasource', 'irate(bind_query_recursions_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
              + prometheus.withLegendFormat('Queries causing recursionries received'),
            ]),

            timeSeries.new('Resolver Response Errors Received')
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
            + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
            + timeSeries.gridPos.withH(8)
            + timeSeries.gridPos.withW(12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
            + timeSeries.queryOptions.withTargets([
              prometheus.new('$datasource', 'irate(bind_resolver_response_errors_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
              + prometheus.withLegendFormat('{{ error }} {{ view }}'),
            ]),

            timeSeries.new('Resolver Queries Failed')
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(10)
            + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
            + timeSeries.gridPos.withH(8)
            + timeSeries.gridPos.withW(12)
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
            + timeSeries.queryOptions.withTargets([
              prometheus.new('$datasource', 'irate(bind_resolver_query_errors_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
              + prometheus.withLegendFormat('{{ error }} {{ view }}'),

              prometheus.new('$datasource', 'irate(bind_resolver_query_edns0_errors_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
              + prometheus.withLegendFormat('EDNS(0) error {{ view }}'),
            ]),
          ]),

          row.new('Zones')
          + row.withCollapsed(true)
          + row.withPanels([

          ]),
        ])
      ),
  },
}
