local util = import '../dashboard-utils.libsonnet';
local grafonnet = import '../g.libsonnet';

local queries = import './queries.libsonnet';

local dashboard = grafonnet.dashboard;
local grid = grafonnet.util.grid;

{
  'rspamd-overview.json': (
    util.dashboard('Rspamd Overview', tags=['generated', 'rspamd'])
    + util.addMultiVariable('cluster', 'rspamd_build_info', 'cluster')
    + util.addMultiVariable('namespace', 'rspamd_build_info{cluster=~"$cluster"}', 'namespace')
    + util.addMultiVariable('host', 'rspamd_build_info{cluster=~"$cluster", namespace=~"$namespace"}', 'host')
    + dashboard.withPanels(
      grid.wrapPanels([
        util.stat.base('Scanned', queries.scanned, height=4, width=4),

        util.stat.base('Rejected', queries.rejected, height=4, width=4),

        util.stat.base('No Action', queries.noAction, height=4, width=4),

        util.stat.base('Greylist', queries.greylist, height=4, width=4),

        util.stat.base('Add Header', queries.addHeader, height=4, width=4),

        util.stat.base('Learned', queries.learned, height=4, width=4),

        util.timeSeries.base('Scanned & Learned', [ queries.scanned, queries.learned ]),

        util.timeSeries.base('Actions', queries.actionsTotal)
      ])
    )
  )
}
