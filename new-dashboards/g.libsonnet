local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v9.4.0/main.libsonnet';

{
  dashboard(title, uid='', datasource='default')::
    grafonnet.dashboard.new(title)
    + grafonnet.dashboard.withEditable()
    + grafonnet.dashboard.withSchemaVersion()
    + grafonnet.dashboard.withStyle()
    + grafonnet.dashboard.withTimezone()
    + grafonnet.dashboard.withUid(uid)
    + grafonnet.dashboard.withTags([
      'generated',
    ])
    + grafonnet.dashboard.withVariables([
      grafonnet.dashboard.variable.datasource.new('datasource', 'prometheus'),
    ])
    + grafonnet.dashboard.graphTooltip.withSharedCrosshair(),

  gaugePanel(title, query)::
    grafonnet.panel.gauge.new(title)
    + grafonnet.panel.stat.withTargets([
      grafonnet.query.prometheus.new('$datasource', query)
      + grafonnet.query.prometheus.withFormat('time_series')
      + grafonnet.query.prometheus.withInstant(true)
      + grafonnet.query.prometheus.withIntervalFactor(null)
    ]),

  statPanel(title, query)::
    grafonnet.panel.stat.new(title)
    + grafonnet.panel.stat.withTargets([
      grafonnet.query.prometheus.new('$datasource', query)
      + grafonnet.query.prometheus.withFormat('time_series')
      + grafonnet.query.prometheus.withInstant(true)
      + grafonnet.query.prometheus.withIntervalFactor(null)
    ]),

  makeGrid(panels)::
    std.foldl(
      function(acc, panel) acc {
        local x = acc.nextx,
        local y = acc.nexty,

        panels+: [
          panel + {
            gridPos+: {
              x: x,
              y: y
            }
          }
        ]
      },
      panels,
      {
        nextx: 0,
        nexty: 0
      }
    ).panels
}
