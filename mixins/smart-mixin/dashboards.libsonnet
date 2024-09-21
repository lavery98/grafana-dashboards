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

local barGauge = grafonnet.panel.barGauge;
local dashboard = grafonnet.dashboard;
local grid = grafonnet.util.grid;
local prometheus = grafonnet.query.prometheus;
local row = grafonnet.panel.row;
local stat = grafonnet.panel.stat;
local table = grafonnet.panel.table;
local timeSeries = grafonnet.panel.timeSeries;
local variable = grafonnet.dashboard.variable;

{
  grafanaDashboards+:: {
    'smart-overview.json':
      dashboard.new('SMART Overview')
      + dashboard.withTags(['generated', 'smart'])
      + dashboard.withRefresh('1m')
      + dashboard.withVariables([
        variable.datasource.new('datasource', 'prometheus')
        + variable.datasource.generalOptions.withLabel('Datasource'),

        variable.query.new('cluster')
        + variable.query.withDatasource('prometheus', '${datasource}')
        + variable.query.generalOptions.withLabel('Cluster')
        + variable.query.queryTypes.withLabelValues('cluster', 'smartmon_smartctl_version'),

        variable.query.new('namespace')
        + variable.query.withDatasource('prometheus', '${datasource}')
        + variable.query.generalOptions.withLabel('Namespace')
        + variable.query.queryTypes.withLabelValues('namespace', 'smartmon_smartctl_version{cluster=~"$cluster"}'),

        variable.query.new('host')
        + variable.query.withDatasource('prometheus', '${datasource}')
        + variable.query.generalOptions.withLabel('Host')
        + variable.query.queryTypes.withLabelValues('host', 'smartmon_smartctl_version{cluster=~"$cluster", namespace=~"$namespace"}'),
      ])
      + dashboard.withPanels(
        grid.wrapPanels([
          row.new('Overview'),

          stat.new('Disks Monitored')
          + stat.gridPos.withH(4)
          + stat.gridPos.withW(4)
          + stat.options.withGraphMode('none')
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'sum(smartmon_device_active{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"})')
            + prometheus.withInstant(true),
          ])
          + stat.standardOptions.color.withFixedColor('text')
          + stat.standardOptions.color.withMode('fixed'),

          table.new('Disk Drives')
          + table.gridPos.withH(8)
          + table.gridPos.withW(20)
          + table.queryOptions.withDatasource('prometheus', '${datasource}')
          + table.queryOptions.withTargets([
            prometheus.new('$datasource', 'smartmon_device_info{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}')
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
                instance: true,
                job: true,
                namespace: true,
                lun_id: true,
                product: true,
                revision: true,
                vendor: true,
                Value: true,
              },
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

          stat.new('Unhealthy Disks')
          + stat.gridPos.withH(4)
          + stat.gridPos.withW(4)
          + stat.options.withColorMode('background')
          + stat.options.withGraphMode('none')
          + stat.queryOptions.withDatasource('prometheus', '${datasource}')
          + stat.queryOptions.withTargets([
            prometheus.new('$datasource', 'sum(smartmon_device_smart_enabled{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"})-sum(smartmon_device_smart_healthy{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"})')
            + prometheus.withInstant(true),
          ])
          + stat.standardOptions.thresholds.withMode('absolute')
          + stat.standardOptions.thresholds.withSteps([
            stat.standardOptions.threshold.step.withColor('green')
            + stat.standardOptions.threshold.step.withValue(null),

            stat.standardOptions.threshold.step.withColor('red')
            + stat.standardOptions.threshold.step.withValue(1),
          ]),

          row.new('Temperature')
          + row.withCollapsed(true)
          + row.withPanels([
            timeSeries.new('Temperature History')
            + timeSeries.gridPos.withH(8)
            + timeSeries.gridPos.withW(24)
            + timeSeries.options.legend.withCalcs([
              'mean',
              'min',
              'max',
              'lastNotNull',
            ])
            + timeSeries.options.legend.withDisplayMode('table')
            + timeSeries.options.legend.withPlacement('right')
            + timeSeries.options.tooltip.withMode('multi')
            + timeSeries.options.tooltip.withSort('none')
            + timeSeries.queryOptions.withDatasource('prometheus', '${datasource}')
            + timeSeries.queryOptions.withTargets([
              prometheus.new('$datasource', 'smartmon_attr_raw_value{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name="temperature_celsius"}')
              + prometheus.withLegendFormat('{{device}} {{disk}}'),
            ])
            + timeSeries.standardOptions.withUnit('celsius'),
          ]),

          row.new('Wear & Tear')
          + row.withCollapsed(true)
          + row.withPanels([
            barGauge.new('Power On Hours')
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12)
            + barGauge.queryOptions.withDatasource('prometheus', '${datasource}')
            + barGauge.queryOptions.withTargets([
              prometheus.new('$datasource', 'smartmon_attr_raw_value{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name="power_on_hours"}')
              + prometheus.withLegendFormat('{{device}} {{disk}}')
              + prometheus.withInstant(true),
            ])
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.withUnit('h')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.standardOptions.threshold.step.withColor('green')
              + barGauge.standardOptions.threshold.step.withValue(null),
              barGauge.standardOptions.threshold.step.withColor('orange')
              + barGauge.standardOptions.threshold.step.withValue(17520),
              barGauge.standardOptions.threshold.step.withColor('red')
              + barGauge.standardOptions.threshold.step.withValue(35040),
            ]),

            barGauge.new('Start Stop Count')
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12)
            + barGauge.queryOptions.withDatasource('prometheus', '${datasource}')
            + barGauge.queryOptions.withTargets([
              prometheus.new('$datasource', 'smartmon_attr_raw_value{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name="start_stop_count"}')
              + prometheus.withLegendFormat('{{device}} {{disk}}')
              + prometheus.withInstant(true),
            ])
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.standardOptions.threshold.step.withColor('green')
              + barGauge.standardOptions.threshold.step.withValue(null),
              barGauge.standardOptions.threshold.step.withColor('orange')
              + barGauge.standardOptions.threshold.step.withValue(750),
              barGauge.standardOptions.threshold.step.withColor('red')
              + barGauge.standardOptions.threshold.step.withValue(1500),
            ]),

            barGauge.new('Power Cycle Count')
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12)
            + barGauge.queryOptions.withDatasource('prometheus', '${datasource}')
            + barGauge.queryOptions.withTargets([
              prometheus.new('$datasource', 'smartmon_attr_raw_value{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name="power_cycle_count"}')
              + prometheus.withLegendFormat('{{device}} {{disk}}')
              + prometheus.withInstant(true),
            ])
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.standardOptions.threshold.step.withColor('green')
              + barGauge.standardOptions.threshold.step.withValue(null),
              barGauge.standardOptions.threshold.step.withColor('orange')
              + barGauge.standardOptions.threshold.step.withValue(1000),
              barGauge.standardOptions.threshold.step.withColor('red')
              + barGauge.standardOptions.threshold.step.withValue(2000),
            ]),

            barGauge.new('Load Cycle Count')
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12)
            + barGauge.queryOptions.withDatasource('prometheus', '${datasource}')
            + barGauge.queryOptions.withTargets([
              prometheus.new('$datasource', 'smartmon_attr_raw_value{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name="load_cycle_count"}')
              + prometheus.withLegendFormat('{{device}} {{disk}}')
              + prometheus.withInstant(true),
            ])
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.standardOptions.threshold.step.withColor('green')
              + barGauge.standardOptions.threshold.step.withValue(null),
              barGauge.standardOptions.threshold.step.withColor('orange')
              + barGauge.standardOptions.threshold.step.withValue(5000),
              barGauge.standardOptions.threshold.step.withColor('red')
              + barGauge.standardOptions.threshold.step.withValue(10000),
            ]),

            barGauge.new('Total Data Written')
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12)
            + barGauge.panelOptions.withDescription('Please note: This may be slightly inaccurate')
            + barGauge.queryOptions.withDatasource('prometheus', '${datasource}')
            + barGauge.queryOptions.withTargets([
              prometheus.new('$datasource', 'smartmon_attr_raw_value{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name="total_lbas_written"} * 512')
              + prometheus.withLegendFormat('{{device}} {{disk}}')
              + prometheus.withInstant(true),
            ])
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.withUnit('decbytes')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.standardOptions.threshold.step.withColor('green')
              + barGauge.standardOptions.threshold.step.withValue(null),
              barGauge.standardOptions.threshold.step.withColor('orange')
              + barGauge.standardOptions.threshold.step.withValue(40000000000000),
              barGauge.standardOptions.threshold.step.withColor('red')
              + barGauge.standardOptions.threshold.step.withValue(60000000000000),
            ]),

            barGauge.new('Reallocated Sector Events')
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12)
            + barGauge.queryOptions.withDatasource('prometheus', '${datasource}')
            + barGauge.queryOptions.withTargets([
              prometheus.new('$datasource', 'smartmon_attr_raw_value{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name="reallocated_event_count"}')
              + prometheus.withLegendFormat('{{device}} {{disk}}')
              + prometheus.withInstant(true),
            ])
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.standardOptions.threshold.step.withColor('green')
              + barGauge.standardOptions.threshold.step.withValue(null),
              barGauge.standardOptions.threshold.step.withColor('red')
              + barGauge.standardOptions.threshold.step.withValue(1),
            ]),
          ]),

          row.new('Errors')
          + row.withCollapsed(true)
          + row.withPanels([
            barGauge.new('Raw Read Error')
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12)
            + barGauge.queryOptions.withDatasource('prometheus', '${datasource}')
            + barGauge.queryOptions.withTargets([
              prometheus.new('$datasource', 'smartmon_attr_value{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name="raw_read_error_rate"}')
              + prometheus.withLegendFormat('{{device}} {{disk}}')
              + prometheus.withInstant(true),
            ])
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.withUnit('percent')
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.standardOptions.threshold.step.withColor('red')
              + barGauge.standardOptions.threshold.step.withValue(null),
              barGauge.standardOptions.threshold.step.withColor('green')
              + barGauge.standardOptions.threshold.step.withValue(100),
            ]),

            barGauge.new('Seek Error Rate')
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12)
            + barGauge.queryOptions.withDatasource('prometheus', '${datasource}')
            + barGauge.queryOptions.withTargets([
              prometheus.new('$datasource', 'smartmon_attr_value{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name="seek_error_rate"}')
              + prometheus.withLegendFormat('{{device}} {{disk}}')
              + prometheus.withInstant(true),
            ])
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.standardOptions.threshold.step.withColor('red')
              + barGauge.standardOptions.threshold.step.withValue(null),
              barGauge.standardOptions.threshold.step.withColor('green')
              + barGauge.standardOptions.threshold.step.withValue(60),
            ]),

            barGauge.new('Spin Retry Count')
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12)
            + barGauge.queryOptions.withDatasource('prometheus', '${datasource}')
            + barGauge.queryOptions.withTargets([
              prometheus.new('$datasource', 'smartmon_attr_raw_value{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name="spin_retry_count"}')
              + prometheus.withLegendFormat('{{device}} {{disk}}')
              + prometheus.withInstant(true),
            ])
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.standardOptions.threshold.step.withColor('green')
              + barGauge.standardOptions.threshold.step.withValue(null),
              barGauge.standardOptions.threshold.step.withColor('orange')
              + barGauge.standardOptions.threshold.step.withValue(1),
              barGauge.standardOptions.threshold.step.withColor('red')
              + barGauge.standardOptions.threshold.step.withValue(10),
            ]),

            barGauge.new('Command Timeout Count')
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12)
            + barGauge.queryOptions.withDatasource('prometheus', '${datasource}')
            + barGauge.queryOptions.withTargets([
              prometheus.new('$datasource', 'smartmon_attr_raw_value{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name="command_timeout"}')
              + prometheus.withLegendFormat('{{device}} {{disk}}')
              + prometheus.withInstant(true),
            ])
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.standardOptions.threshold.step.withColor('green')
              + barGauge.standardOptions.threshold.step.withValue(null),
              barGauge.standardOptions.threshold.step.withColor('orange')
              + barGauge.standardOptions.threshold.step.withValue(1),
              barGauge.standardOptions.threshold.step.withColor('red')
              + barGauge.standardOptions.threshold.step.withValue(10),
            ]),

            barGauge.new('Current Pending Sector Count')
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12)
            + barGauge.queryOptions.withDatasource('prometheus', '${datasource}')
            + barGauge.queryOptions.withTargets([
              prometheus.new('$datasource', 'smartmon_attr_raw_value{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name="current_pending_sector"}')
              + prometheus.withLegendFormat('{{device}} {{disk}}')
              + prometheus.withInstant(true),
            ])
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.standardOptions.threshold.step.withColor('green')
              + barGauge.standardOptions.threshold.step.withValue(null),
              barGauge.standardOptions.threshold.step.withColor('orange')
              + barGauge.standardOptions.threshold.step.withValue(1),
              barGauge.standardOptions.threshold.step.withColor('red')
              + barGauge.standardOptions.threshold.step.withValue(10),
            ]),

            barGauge.new('Offline Uncorrectable Sector Count')
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12)
            + barGauge.queryOptions.withDatasource('prometheus', '${datasource}')
            + barGauge.queryOptions.withTargets([
              prometheus.new('$datasource', 'smartmon_attr_raw_value{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name="offline_uncorrectable"}')
              + prometheus.withLegendFormat('{{device}} {{disk}}')
              + prometheus.withInstant(true),
            ])
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.standardOptions.threshold.step.withColor('green')
              + barGauge.standardOptions.threshold.step.withValue(null),
              barGauge.standardOptions.threshold.step.withColor('orange')
              + barGauge.standardOptions.threshold.step.withValue(1),
              barGauge.standardOptions.threshold.step.withColor('red')
              + barGauge.standardOptions.threshold.step.withValue(10),
            ]),

            barGauge.new('Reported Uncorrectable Errors')
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12)
            + barGauge.queryOptions.withDatasource('prometheus', '${datasource}')
            + barGauge.queryOptions.withTargets([
              prometheus.new('$datasource', 'smartmon_attr_raw_value{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name="reported_uncorrect"}')
              + prometheus.withLegendFormat('{{device}} {{disk}}')
              + prometheus.withInstant(true),
            ])
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.standardOptions.threshold.step.withColor('green')
              + barGauge.standardOptions.threshold.step.withValue(null),
              barGauge.standardOptions.threshold.step.withColor('orange')
              + barGauge.standardOptions.threshold.step.withValue(1),
              barGauge.standardOptions.threshold.step.withColor('red')
              + barGauge.standardOptions.threshold.step.withValue(10),
            ]),

            barGauge.new('UltraDMA CRC Error')
            + barGauge.gridPos.withH(8)
            + barGauge.gridPos.withW(12)
            + barGauge.queryOptions.withDatasource('prometheus', '${datasource}')
            + barGauge.queryOptions.withTargets([
              prometheus.new('$datasource', 'smartmon_attr_raw_value{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name="udma_crc_error_count"}')
              + prometheus.withLegendFormat('{{device}} {{disk}}')
              + prometheus.withInstant(true),
            ])
            + barGauge.standardOptions.withMin(0)
            + barGauge.standardOptions.thresholds.withMode('absolute')
            + barGauge.standardOptions.thresholds.withSteps([
              barGauge.standardOptions.threshold.step.withColor('green')
              + barGauge.standardOptions.threshold.step.withValue(null),
              barGauge.standardOptions.threshold.step.withColor('red')
              + barGauge.standardOptions.threshold.step.withValue(1),
            ]),
          ]),
        ])
      ),
  },
}
