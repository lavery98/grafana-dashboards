local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local dashboard = grafonnet.dashboard;
local panel = grafonnet.panel;

{
  dashboard(title, uid='')::
    dashboard.new(title)
    + dashboard.withEditable()
    + dashboard.withSchemaVersion()
    + dashboard.withStyle()
    + dashboard.withTags($._config.tags)
    + dashboard.withTimezone()
    + dashboard.withUid(uid)
    + dashboard.withVariables([
      dashboard.variable.datasource.new('datasource', 'prometheus'),
    ])
    + dashboard.graphTooltip.withSharedCrosshair(),

  addVariable(name, metric_name, label_name, hide=0, allValue=null, includeAll=false)::
    local variable = dashboard.variable;

    dashboard.withVariables([
      variable.query.new(name)
      + variable.query.withDatasource('prometheus', '${datasource}')
      + variable.query.withSort(1)
      + variable.query.queryTypes.withLabelValues(label_name, metric_name)
      + variable.query.selectionOptions.withIncludeAll(includeAll, allValue),
    ]),

  addMultiVariable(name, metric_name, label_name, hide=0, allValue='.+')::
    local variable = dashboard.variable;

    dashboard.withVariables([
      variable.query.new(name)
      + variable.query.withDatasource('prometheus', '${datasource}')
      + variable.query.withSort(1)
      + variable.query.queryTypes.withLabelValues(label_name, metric_name)
      + variable.query.selectionOptions.withIncludeAll(true, allValue)
      + variable.query.selectionOptions.withMulti(),
    ]),

  row(title, collapsed=false)::
    local row = panel.row;

    row.new(title)
    + row.withCollapsed(collapsed),

  barGaugePanel(title, targets)::
    local barGauge = panel.barGauge;
    local options = barGauge.options;
    local standardOptions = barGauge.standardOptions;

    barGauge.new(title)
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

  statPanel(title, targets)::
    local stat = panel.stat;
    local options = stat.options;
    local standardOptions = stat.standardOptions;

    stat.new(title)
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
    + standardOptions.color.withMode('fixed'),

  tablePanel(title, targets)::
    local table = panel.table;
    local options = table.options;
    local standardOptions = table.standardOptions;

    table.new(title)
    + table.queryOptions.withTargets(targets)
    // Default values
    + options.withCellHeight('sm')
    + options.withFooter()
    + options.withShowHeader()
    + standardOptions.color.withMode('fixed')
    + table.fieldConfig.defaults.withCustom({
      align: 'auto',
      cellOptions: {
        type: 'auto',
      },
      inspect: false,
    }),

  timeseriesPanel(title, targets)::
    local timeSeries = panel.timeSeries;
    local fieldConfig = timeSeries.fieldConfig;
    local standardOptions = timeSeries.standardOptions;

    timeSeries.new(title)
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
