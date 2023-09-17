local util = import '../dashboard-utils.libsonnet';
local grafonnet = import '../g.libsonnet';

// This dashboard requires the node-exporter-full.json file to be placed in this directory so that it can be modified
local nodeExporterFull = import 'node-exporter-full.json';

local dashboard = grafonnet.dashboard;
local prometheus = grafonnet.query.prometheus;
local timeSeries = grafonnet.panel.timeSeries;
local variable = grafonnet.dashboard.variable;

{
  'node-exporter.json': (
    util.dashboard('Node Exporter', tags=['generated', 'node_exporter'])
    + util.addMultiVariable('cluster', 'node_exporter_build_info', 'cluster')
    + util.addMultiVariable('namespace', 'node_exporter_build_info{cluster=~"$cluster"}', 'namespace')
    + util.addVariable('host', 'node_exporter_build_info{cluster=~"$cluster", namespace=~"$namespace"}', 'host')
    + dashboard.withVariablesMixin([
      variable.custom.new('diskdevices', ['[a-z]+|nvme[0-9]+n[0-9]+|mmcblk[0-9]+'])
      + variable.custom.generalOptions.showOnDashboard.withNothing()
      + variable.custom.selectionOptions.withIncludeAll(false)
      + variable.custom.selectionOptions.withMulti(false),
    ])
    + dashboard.withPanels(
      // Modify the query targets and selectors
      local ModifyTarget(target) = target
                                   + prometheus.withDatasource('$datasource')
                                   + (
                                     if std.objectHas(target, 'expr') then {
                                       expr: std.strReplace(target.expr, 'instance="$node",job="$job"', 'cluster=~"$cluster",namespace=~"$namespace",host="$host"'),
                                     } else {}
                                   );

      // Modify each panel in the dashboard
      local ModifyPanel(panel) = [
        panel
        + timeSeries.queryOptions.withDatasource('prometheus', '$datasource')
        + timeSeries.queryOptions.withTargets([
          ModifyTarget(t)
          for t in panel.targets
        ]) + (
          if std.objectHas(panel, 'panels') then {
            panels: [
              p
              + timeSeries.queryOptions.withDatasource('prometheus', '$datasource')
              + timeSeries.queryOptions.withTargets([
                ModifyTarget(t)
                for t in p.targets
              ])
              for p in panel.panels
            ],
          } else {}
        ),
      ];

      local modifiedPanels = std.flattenArrays([
        ModifyPanel(p)
        for p in nodeExporterFull.panels
      ]);
      modifiedPanels
    )
  ),
}
