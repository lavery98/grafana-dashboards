local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v9.4.0/main.libsonnet';

{
  dashboard(title, uid='')::
    grafonnet.dashboard.new(title)
    + grafonnet.dashboard.withEditable()
    + grafonnet.dashboard.withSchemaVersion()
    + grafonnet.dashboard.withStyle()
    + grafonnet.dashboard.withTimezone()
    + grafonnet.dashboard.withUid(uid)
    + grafonnet.dashboard.withTags($._config.tags)
    + grafonnet.dashboard.withVariables(
      grafonnet.dashboard.variable.datasource.new('datasource', 'prometheus'),
    )
    + grafonnet.dashboard.graphTooltip.withSharedCrosshair(),

  addVariable(name, metric_name, label_name, hide=0, allValue=null, includeAll=false)::
    grafonnet.dashboard.withVariables(
      grafonnet.dashboard.variable.query.new(name)
      + grafonnet.dashboard.variable.query.withDatasource('prometheus', '${datasource}')
      + grafonnet.dashboard.variable.query.withSort(2)
      + grafonnet.dashboard.variable.query.queryTypes.withLabelValues(label_name, metric_name)
      + grafonnet.dashboard.variable.query.selectionOptions.withIncludeAll(includeAll, allValue)
    ),

  addMultiVariable(name, metric_name, label_name, hide=0, allValue='.+')::
    grafonnet.dashboard.withVariables(
      grafonnet.dashboard.variable.query.new(name)
      + grafonnet.dashboard.variable.query.withDatasource('prometheus', '${datasource}')
      + grafonnet.dashboard.variable.query.withSort(2)
      + grafonnet.dashboard.variable.query.queryTypes.withLabelValues(label_name, metric_name)
      + grafonnet.dashboard.variable.query.selectionOptions.withIncludeAll(true, allValue)
      + grafonnet.dashboard.variable.query.selectionOptions.withMulti()
    ),

  row(title, collapsed=false)::
    grafonnet.panel.row.new(title)
    + grafonnet.panel.row.withCollapsed(collapsed),

  barGaugePanel(title, targets)::
    local panel = grafonnet.panel.barGauge;

    panel.new(title)
    + panel.withTargets(targets)
    // Default values
    + panel.fieldConfig.defaults.color.withMode('fixed')
    + panel.options.withDisplayMode('gradient')
    + panel.options.withMinVizHeight()
    + panel.options.withMinVizWidth()
    + panel.options.withOrientation('auto')
    + panel.options.withShowUnfilled()
    + panel.options.withValueMode('color')
    + panel.options.reduceOptions.withCalcs([
      'lastNotNull',
    ])
    + panel.options.reduceOptions.withFields('')
    + panel.options.reduceOptions.withValues(false),

  statPanel(title, targets)::
    grafonnet.panel.stat.new(title)
    + grafonnet.panel.stat.withTargets(targets),

  tablePanel(title, targets)::
    grafonnet.panel.table.new(title)
    + grafonnet.panel.table.withTargets(targets),

  timeseriesPanel(title, targets)::
    grafonnet.panel.timeSeries.new(title)
    + grafonnet.panel.timeSeries.withTargets(targets),

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
