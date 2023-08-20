local util = import '../dashboard-utils.libsonnet';
local grafonnet = import '../g.libsonnet';

local queries = import './queries.libsonnet';

local dashboard = grafonnet.dashboard;
local row = grafonnet.panel.row;
local stat = grafonnet.panel.stat;
local timeSeries = grafonnet.panel.timeSeries;

{
  'bind-overview.json': (
    util.dashboard('Bind Overview', tags=['generated', 'bind'])
    + util.addMultiVariable('cluster', 'bind_up', 'cluster')
    + util.addMultiVariable('namespace', 'bind_up{cluster=~"$cluster"}', 'namespace')
    + util.addMultiVariable('host', 'bind_up{cluster=~"$cluster", namespace=~"$namespace"}', 'host')
    + dashboard.withPanels(
      util.makeGrid([
        util.row('General'),

        util.timeSeries.base('All DNS Queries', [queries.sumOfIncomingDNSQueries, queries.sumOfOutgoingDNSQueries], width=24)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.options.tooltip.withMode('multi'),

        util.timeSeries.base('Incoming DNS Queries', queries.incomingDNSQueries)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.options.tooltip.withMode('multi'),

        util.timeSeries.base('Outgoing DNS Queries', queries.outgoingDNSQueries)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.options.tooltip.withMode('multi'),

        util.timeSeries.base('Incoming Requests', queries.incomingRequests)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.options.tooltip.withMode('multi'),

        util.timeSeries.base('Responses Sent', queries.responsesSent)
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.options.tooltip.withMode('multi'),

        util.stat.base('Last Restarted', queries.lastRestarted, width=12)
        + stat.standardOptions.withUnit('dateTimeAsIso'),

        util.stat.base('Last Reconfigured', queries.lastReconfigured, width=12)
        + stat.standardOptions.withUnit('dateTimeAsIso'),

        util.row('Issues', collapsed=true)
        + row.withPanels(
          util.makeGrid([
            util.timeSeries.base('Resolver Query Retries', queries.queryRetries)
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
            + timeSeries.options.tooltip.withMode('multi'),

            util.timeSeries.base('Query Issues', [queries.queryDuplicates, queries.queryErrors, queries.queryRecursions])
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
            + timeSeries.options.tooltip.withMode('multi'),

            util.timeSeries.base('Resolver Response Errors Received', queries.responseErrors)
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
            + timeSeries.options.tooltip.withMode('multi'),

            util.timeSeries.base('Resolver Queries Failed', [queries.resolverQueryErrors, queries.resolverQueryEdnsErrors])
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
            + timeSeries.options.tooltip.withMode('multi'),
          ])
        ),


      ]),
    )
  ),
}
