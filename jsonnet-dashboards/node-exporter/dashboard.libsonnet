local util = import '../dashboard-utils.libsonnet';
local grafonnet = import '../g.libsonnet';

// This dashboard requires the node-exporter-full.json file to be placed in this directory so that it can be modified
local nodeExporterFull = import 'node-exporter-full.json';

local dashboard = grafonnet.dashboard;
local prometheus = grafonnet.query.prometheus;
local variable = grafonnet.dashboard.variable;

{
  'node-exporter.json': (
    {
      hiddentRows:: [],
      hiddenPanels:: [],
    }
    + nodeExporterFull + {
      __inputs: {},

      local replaceMatchers(expr) =
        std.strReplace(expr, 'instance="$node",job="$job"', 'cluster=~"$cluster",namespace=~"$namespace",host="$host"'),

      local addDiskLabel(expr) =
        expr + ' * on (device) group_left(device_label) node_disk_label_info{cluster=~"$cluster",namespace=~"$namespace",host="$host"} or on (device) label_replace(' + expr + ', "device_label", "$1", "device", "(.*)")',

      local addDiskLabelToLegend(legendFormat) =
        std.strReplace(legendFormat, '{{device}}', '{{device_label}}'),

      local selectDatasource() = {
        type: 'prometheus',
        uid: '$datasource',
      },

      local isRowHidden(row) =
        std.member(self.hiddentRows, row),

      local isPanelHidden(panelTitle) =
        std.member(self.hiddenPanels, panelTitle),

      local replaceExpression(title, expr) =
        if (
          title == 'Disk IOps Completed' ||
          title == 'Disk R/W Data' ||
          title == 'Disk Average Wait Time' ||
          title == 'Average Queue Size' ||
          title == 'Disk R/W Merged' ||
          title == 'Time Spent Doing I/Os' ||
          title == 'Instantaneous Queue Size' ||
          title == 'Disk IOps Discards completed / merged'
        ) then
          addDiskLabel(replaceMatchers(expr))
        else
          replaceMatchers(expr),

      local replaceLegendFormat(title, legendFormat) =
        if (
          title == 'Disk IOps Completed' ||
          title == 'Disk R/W Data' ||
          title == 'Disk Average Wait Time' ||
          title == 'Average Queue Size' ||
          title == 'Disk R/W Merged' ||
          title == 'Time Spent Doing I/Os' ||
          title == 'Instantaneous Queue Size' ||
          title == 'Disk IOps Discards completed / merged'
        ) then
          addDiskLabelToLegend(legendFormat)
        else
          legendFormat,

      panels: [
        p {
          datasource: selectDatasource(),
          [if std.objectHas(p, 'targets') then 'targets']: [
            e {
              datasource: selectDatasource(),
              [if std.objectHas(e, 'expr') then 'expr']: replaceExpression(p.title, e.expr),
              [if std.objectHas(e, 'legendFormat') then 'legendFormat']: replaceLegendFormat(p.title, e.legendFormat),
            }
            for e in p.targets
          ],
          [if std.objectHas(p, 'panels') then 'panels']: [
            sp {
              datasource: selectDatasource(),
              [if std.objectHas(sp, 'targets') then 'targets']: [
                e {
                  datasource: selectDatasource(),
                  [if std.objectHas(e, 'expr') then 'expr']: replaceExpression(sp.title, e.expr),
                  [if std.objectHas(e, 'legendFormat') then 'legendFormat']: replaceLegendFormat(sp.title, e.legendFormat),
                }
                for e in sp.targets
              ],
            }
            for sp in p.panels
            if !(isPanelHidden(sp.title))
          ],
        }
        for p in super.panels
        if !(p.type == 'row' && isRowHidden(p.title)) && !(isPanelHidden(p.title))
      ],
    }
    + util.dashboard('Node Exporter', tags=['generated', 'node_exporter'])
    + util.addMultiVariable('cluster', 'node_exporter_build_info', 'cluster')
    + util.addMultiVariable('namespace', 'node_exporter_build_info{cluster=~"$cluster"}', 'namespace')
    + util.addVariable('host', 'node_exporter_build_info{cluster=~"$cluster", namespace=~"$namespace"}', 'host')
    + dashboard.withVariablesMixin([
      variable.custom.new('diskdevices', ['[a-z]+|nvme[0-9]+n[0-9]+|mmcblk[0-9]+'])
      + variable.custom.generalOptions.showOnDashboard.withNothing()
      + variable.custom.selectionOptions.withIncludeAll(false)
      + variable.custom.selectionOptions.withMulti(false),
    ])
  ),
}
