/*
 * Copyright 2023 Ashley Lavery
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

local grafonnet = import 'g.libsonnet';

local dashboard = grafonnet.dashboard;
local panel = grafonnet.panel;

{
  dashboard(title, tags=['generated'], uid='')::
    dashboard.new(title)
    + dashboard.withEditable()
    + dashboard.withSchemaVersion()
    + dashboard.withTags(tags)
    + dashboard.withTimezone()
    + dashboard.withUid(uid)
    + dashboard.withVariables([
      dashboard.variable.datasource.new('datasource', 'prometheus')
      + dashboard.variable.datasource.generalOptions.withLabel('Data source'),
    ])
    + dashboard.graphTooltip.withSharedCrosshair(),

  addVariable(name, metric_name, label_name, hide=0, allValue=null, includeAll=false)::
    local variable = dashboard.variable;

    dashboard.withVariablesMixin([
      variable.query.new(name)
      + variable.query.withDatasource('prometheus', '${datasource}')
      + variable.query.withSort(1)
      + variable.query.queryTypes.withLabelValues(label_name, metric_name)
      + variable.query.refresh.onTime()
      + variable.query.selectionOptions.withIncludeAll(includeAll, allValue),
    ]),

  addMultiVariable(name, metric_name, label_name, hide=0, allValue='.+')::
    local variable = dashboard.variable;

    dashboard.withVariablesMixin([
      variable.query.new(name)
      + variable.query.withDatasource('prometheus', '${datasource}')
      + variable.query.withSort(1)
      + variable.query.queryTypes.withLabelValues(label_name, metric_name)
      + variable.query.refresh.onTime()
      + variable.query.selectionOptions.withIncludeAll(true, allValue)
      + variable.query.selectionOptions.withMulti(),
    ]),

  row(title, collapsed=false)::
    local row = panel.row;

    row.new(title)
    + row.withCollapsed(collapsed)
    + row.gridPos.withH(1)
    + row.gridPos.withW(24),

  barGauge: {
    local barGauge = panel.barGauge,
    local options = barGauge.options,
    local standardOptions = barGauge.standardOptions,

    base(title, targets, height=8, width=12):
      barGauge.new(title)
      + barGauge.gridPos.withH(height)
      + barGauge.gridPos.withW(width)
      + barGauge.queryOptions.withDatasource('prometheus', '$datasource')
      + barGauge.queryOptions.withTargets(targets)
      // Default values
      + options.withDisplayMode('gradient')
      + options.withMinVizHeight()
      + options.withMinVizWidth()
      + options.withOrientation('auto')
      + options.withShowUnfilled()
      + options.withValueMode('color')
      + options.reduceOptions.withCalcs([
        'lastNotNull',
      ])
      + options.reduceOptions.withFields('')
      + options.reduceOptions.withValues(false)
      + standardOptions.color.withMode('fixed'),
  },

  gauge: {
    local gauge = panel.gauge,
    local options = gauge.options,
    local standardOptions = gauge.standardOptions,

    base(title, targets, height=8, width=12):
      gauge.new(title)
      + gauge.gridPos.withH(height)
      + gauge.gridPos.withW(width)
      + gauge.queryOptions.withDatasource('prometheus', '$datasource')
      + gauge.queryOptions.withTargets(targets)
      // Default values
      + options.withOrientation('auto')
      + options.withShowThresholdLabels(false)
      + options.withShowThresholdMarkers()
      + options.reduceOptions.withCalcs([
        'lastNotNull',
      ])
      + options.reduceOptions.withFields('')
      + options.reduceOptions.withValues(false)
      + standardOptions.color.withMode('fixed'),
  },

  stat: {
    local stat = panel.stat,
    local options = stat.options,
    local standardOptions = stat.standardOptions,

    base(title, targets, height=3, width=6):
      stat.new(title)
      + stat.gridPos.withH(height)
      + stat.gridPos.withW(width)
      + stat.queryOptions.withDatasource('prometheus', '$datasource')
      + stat.queryOptions.withTargets(targets)
      // Default values
      + options.withColorMode('value')
      + options.withGraphMode('area')
      + options.withJustifyMode('auto')
      + options.withOrientation('auto')
      + options.withTextMode('auto')
      + options.reduceOptions.withCalcs([
        'lastNotNull',
      ])
      + options.reduceOptions.withFields('')
      + options.reduceOptions.withValues(false)
      + standardOptions.withUnit('none')
      + standardOptions.color.withFixedColor('text')
      + standardOptions.color.withMode('fixed'),

    short(title, targets, height=3, width=6):
      self.base(title, targets, height, width)
      + standardOptions.withDecimals(0)
      + standardOptions.withUnit('short'),
  },

  stateTimeline: {
    local stateTimeline = panel.stateTimeline,
    local fieldConfig = stateTimeline.fieldConfig,
    local options = stateTimeline.options,
    local standardOptions = stateTimeline.standardOptions,

    base(title, targets, height=8, width=12):
      stateTimeline.new(title)
      + stateTimeline.gridPos.withH(height)
      + stateTimeline.gridPos.withW(width)
      + stateTimeline.queryOptions.withDatasource('prometheus', '$datasource')
      + stateTimeline.queryOptions.withTargets(targets)
      // Default values
      + fieldConfig.defaults.custom.withFillOpacity(70)
      + fieldConfig.defaults.custom.withLineWidth(0)
      + options.withAlignValue('left')
      + options.withMergeValues(true)
      + options.withRowHeight(0.9)
      + options.withShowValue(true)
      + options.legend.withDisplayMode('list')
      + options.legend.withPlacement('bottom')
      + options.legend.withShowLegend(true)
      + options.tooltip.withMode('single')
      + options.tooltip.withSort('none')
      + standardOptions.color.withMode('thresholds'),
  },

  table: {
    local table = panel.table,
    local options = table.options,
    local standardOptions = table.standardOptions,

    base(title, targets, height=8, width=12):
      table.new(title)
      + table.gridPos.withH(height)
      + table.gridPos.withW(width)
      + table.queryOptions.withDatasource('prometheus', '$datasource')
      + table.queryOptions.withTargets(targets)
      // Default values
      + options.withCellHeight('sm')
      + options.withFooter()
      + options.withShowHeader()
      + standardOptions.color.withMode('fixed'),

    withFilterable(filterable=false): {
      fieldConfig+: {
        defaults+: {
          custom+: {
            filterable: filterable,
          },
        },
      },
    },
  },

  timeSeries: {
    local timeSeries = panel.timeSeries,
    local fieldConfig = timeSeries.fieldConfig,
    local standardOptions = timeSeries.standardOptions,

    base(title, targets, height=8, width=12):
      timeSeries.new(title)
      + timeSeries.gridPos.withH(height)
      + timeSeries.gridPos.withW(width)
      + timeSeries.queryOptions.withDatasource('prometheus', '$datasource')
      + timeSeries.queryOptions.withTargets(targets)
      // Default values
      + fieldConfig.defaults.custom.withAxisCenteredZero(false)
      + fieldConfig.defaults.custom.withAxisColorMode('text')
      + fieldConfig.defaults.custom.withAxisLabel('')
      + fieldConfig.defaults.custom.withAxisPlacement('auto')
      + fieldConfig.defaults.custom.withBarAlignment(0)
      + fieldConfig.defaults.custom.withDrawStyle('line')
      + fieldConfig.defaults.custom.withFillOpacity(0)
      + fieldConfig.defaults.custom.withGradientMode('none')
      + fieldConfig.defaults.custom.withLineInterpolation('linear')
      + fieldConfig.defaults.custom.withLineWidth(1)
      + fieldConfig.defaults.custom.withPointSize(5)
      + fieldConfig.defaults.custom.withShowPoints('auto')
      + fieldConfig.defaults.custom.withSpanNulls(false)
      + fieldConfig.defaults.custom.hideFrom.withLegend(false)
      + fieldConfig.defaults.custom.hideFrom.withTooltip(false)
      + fieldConfig.defaults.custom.hideFrom.withViz(false)
      + fieldConfig.defaults.custom.scaleDistribution.withType('linear')
      + fieldConfig.defaults.custom.stacking.withMode('none')
      + fieldConfig.defaults.custom.thresholdsStyle.withMode('off')
      + standardOptions.color.withMode('palette-classic'),
  },

  makeGrid(panels)::
    std.foldl(
      function(acc, panel) acc {
        local x = acc.nextx,
        local y = acc.nexty,
        local w = panel.gridPos.w,
        local h = panel.gridPos.h,

        // Keep the height of the largest panel
        local rowHeight = (if h > acc.rowHeight then h else acc.rowHeight),
        rowHeight: (if x + w >= 24 then 0 else rowHeight),

        // Work out the next x value. If the next x value is more then 24 then wrap
        nextx: (if x + w >= 24 then 0 else x + w),

        // Work out the next y value. If we are wrapping then increase y by the row height
        nexty: (if x + w >= 24 then y + rowHeight else y),

        panels+: [
          panel {
            gridPos+: {
              x: x,
              y: y,
            },
          },
        ],
      },
      panels,
      {
        nextx: 0,
        nexty: 0,
        rowHeight: 0,
      }
    ).panels,
}
