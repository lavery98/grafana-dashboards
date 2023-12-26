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

local utils = (import 'github.com/grafana/jsonnet-libs/mixin-utils/utils.libsonnet');

{
  local withMultiSelectTemplate = function (t) t + (
    if t.name == 'cluster' || t.name == 'namespace' then {
      allValue: '.+',
      current: {
        selected: true,
        text: 'All',
        value: '$__all',
      },
      includeAll: true,
      multi: true
    } else {}
  ),

  // dropPanels removes unnecessary panels from the loki dashboards
  local dropPanels = function(panels, dropList)
    [
      p
      for p in panels
      if !std.member(dropList, p.title)
    ],

  // mapTemplateParameters applies a static list of transformer functions to
  // all dashboard template parameters.
  local mapTemplateParameters = function(ls)
    [
      std.foldl(function(x, fn) fn(x), [withMultiSelectTemplate], item)
      for item in ls
    ],

  loki: {
    grafanaDashboards+: {
      'loki-chunks.json'+: {
        labelsSelector:: 'cluster=~"$cluster", namespace=~"$namespace", job=~"($namespace)/loki"',

        uid: '',
        time: {
          from: 'now-6h',
          to: 'now'
        },
        refresh: '1m',
        timezone: '',

        templating+: {
          list: mapTemplateParameters(super.list),
        }
      },

      'loki-deletion.json'+: {
        local dropList = ['Compactor CPU usage', 'Compactor memory usage (MiB)'],

        uid: '',
        time: {
          from: 'now-6h',
          to: 'now'
        },
        refresh: '1m',
        timezone: '',

        rows: [
          r {
            panels: dropPanels(r.panels, dropList)
          }
          for r in super.rows
        ],

        templating+: {
          list: mapTemplateParameters(super.list),
        }

        // TODO
        // - Fix last few panels in dashboard
      },

      // TODO
      'loki-operational.json'+: {
      },

      'loki-reads.json'+: {
        local dropList = ['Frontend (query-frontend)', 'Ingester - Zone Aware', 'BoltDB Shipper'],

        matchers:: {
          cortexgateway:: [],
          queryFrontend:: [],
          querier:: [
            utils.selector.re('namespace', '$namespace'),
            utils.selector.re('job', '($namespace)/loki'),
          ],
          ingester:: [
            utils.selector.re('namespace', '$namespace'),
            utils.selector.re('job', '($namespace)/loki'),
          ],
          ingesterZoneAware:: [],
          querierOrIndexGateway:: [],
        },

        uid: '',
        time: {
          from: 'now-6h',
          to: 'now'
        },
        refresh: '1m',
        timezone: '',

        rows: dropPanels(super.rows, dropList),

        templating+: {
          list: mapTemplateParameters(super.list),
        }

        // TODO
        // - Change Per Pod Latency to per instance
      },

      'loki-retention.json'+: {
        local dropList = ['Resource Usage'],

        uid: '',
        time: {
          from: 'now-6h',
          to: 'now'
        },
        refresh: '1m',
        timezone: '',

        rows: dropPanels(super.rows, dropList),

        templating+: {
          list: mapTemplateParameters(super.list),
        }

        // TODO
        // - Work out if we should drop the retention row
      },

      'loki-writes.json'+: {
        local dropList = ['Distributor - Structured Metadata', 'Ingester - Zone Aware', 'BoltDB Shipper'],

        matchers:: {
          cortexgateway:: [],
          distributor:: [
            utils.selector.re('namespace', '$namespace'),
            utils.selector.re('job', '($namespace)/loki'),
          ],
          ingester:: [
            utils.selector.re('namespace', '$namespace'),
            utils.selector.re('job', '($namespace)/loki'),
          ],
          ingester_zone:: [],
          any_ingester:: [
            utils.selector.re('namespace', '$namespace'),
            utils.selector.re('job', '($namespace)/loki'),
          ],
        },

        uid: '',
        time: {
          from: 'now-6h',
          to: 'now'
        },
        refresh: '1m',
        timezone: '',

        rows: dropPanels(super.rows, dropList),

        templating+: {
          list: mapTemplateParameters(super.list),
        }

        // TODO
        // - Update rules to get latency working correctly
      },
    }
  }
}
