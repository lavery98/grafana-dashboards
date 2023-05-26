local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v9.4.0/main.libsonnet';

{
  dashboard(title, uid='', datasource='default')::
    grafonnet.dashboard.new(title)
    + grafonnet.dashboard.withEditable()
    + grafonnet.dashboard.withSchemaVersion()
    + grafonnet.dashboard.withStyle()
    + grafonnet.dashboard.withTimezone()
    + grafonnet.dashboard.withUid(uid)
    + grafonnet.dashboard.withTags($._config.tags)
    + grafonnet.dashboard.withVariables([
      grafonnet.dashboard.variable.datasource.new('datasource', 'prometheus'),
    ])
    + grafonnet.dashboard.graphTooltip.withSharedCrosshair(),

  gaugePanel(title, query)::
    grafonnet.panel.gauge.new(title)
    + grafonnet.panel.stat.withTargets([
      self.prometheusQuery(query)
      + grafonnet.query.prometheus.withInstant(true),
    ]),

  statPanel(title, query)::
    grafonnet.panel.stat.new(title)
    + grafonnet.panel.stat.withTargets([
      self.prometheusQuery(query)
      + grafonnet.query.prometheus.withInstant(true),
    ]),

  timeseriesPanel(title, query='')::
    grafonnet.panel.timeSeries.new(title)
    + (
      if query == '' then {} else
        grafonnet.panel.timeSeries.withTargets([
          self.prometheusQuery(query),
        ])
    ),

  prometheusQuery(query)::
    grafonnet.query.prometheus.new('$datasource', query)
    + grafonnet.query.prometheus.withFormat('time_series')
    + grafonnet.query.prometheus.withIntervalFactor(null),

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
