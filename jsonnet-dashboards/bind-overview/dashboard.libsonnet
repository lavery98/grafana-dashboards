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

local util = import '../dashboard-utils.libsonnet';
local grafonnet = import '../g.libsonnet';

local queries = import './queries.libsonnet';

local dashboard = grafonnet.dashboard;
local row = grafonnet.panel.row;
local stat = grafonnet.panel.stat;
local stateTimeline = grafonnet.panel.stateTimeline;
local table = grafonnet.panel.table;
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

        util.row('Zones', collapsed=true)
        + row.withPanels(
          util.makeGrid([
            util.table.base('Zone Serials', queries.zoneSerials)
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
                  view: true,
                },
                indexByName: {},
                renameByName: {
                  zone_name: 'Zone',
                  Value: 'SOA Serial',
                },
              }),

              table.transformation.withId('filterByValue')
              + table.transformation.withOptions({
                filters: [
                  {
                    config: {
                      id: 'greater',
                      options: {
                        value: 1000,
                      },
                    },
                    fieldName: 'SOA Serial',
                  },
                ],
                match: 'any',
                type: 'include',
              }),
            ]),

            util.timeSeries.base('Zone Serial Changes', queries.zoneSerialChanges)
            + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
            + timeSeries.options.tooltip.withMode('multi'),

            util.stateTimeline.base('Failed Zone Transfers', queries.failedZoneTransfers)
            + stateTimeline.options.withShowValue('never')
            + stateTimeline.options.legend.withShowLegend(false)
            + stateTimeline.options.tooltip.withMode('none')
            + stateTimeline.standardOptions.thresholds.withMode('absolute')
            + stateTimeline.standardOptions.thresholds.withSteps([
              stateTimeline.thresholdStep.withColor('green')
              + stateTimeline.thresholdStep.withValue(null),
              stateTimeline.thresholdStep.withColor('red')
              + stateTimeline.thresholdStep.withValue(0.0001),
            ]),

            util.stateTimeline.base('Rejected Zone Transfers', queries.rejectedZoneTransfers)
            + stateTimeline.options.withShowValue('never')
            + stateTimeline.options.legend.withShowLegend(false)
            + stateTimeline.options.tooltip.withMode('none')
            + stateTimeline.standardOptions.thresholds.withMode('absolute')
            + stateTimeline.standardOptions.thresholds.withSteps([
              stateTimeline.thresholdStep.withColor('green')
              + stateTimeline.thresholdStep.withValue(null),
              stateTimeline.thresholdStep.withColor('red')
              + stateTimeline.thresholdStep.withValue(0.0001),
            ]),
          ])
        ),
      ]),
    )
  ),
}
