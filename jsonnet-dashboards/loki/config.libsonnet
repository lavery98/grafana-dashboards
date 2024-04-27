/*
 * Copyright 2024 Ashley Lavery
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

  local replaceTitle = function(title, replacement)
    function (p) p + (
      if p.title == title then {
        title: replacement
      } else {}
    ),

  local replaceMatchers = function(title, replacements)
    function(p) p + (
      if p.title == title then {
        targets: [
          t {
            expr: std.foldl(function(x, rp) std.strReplace(x, rp.from, rp.to), replacements, t.expr),
          }
          for t in p.targets
          if std.objectHas(p, 'targets')
        ],
      } else {}
    ),

  // dropPanels removes unnecessary panels from the loki dashboards
  local dropPanels = function(panels, dropList)
    [
      p
      for p in panels
      if !std.member(dropList, p.title)
    ],

  // mapPanels applies recursively a set of functions over all panels.
  // Note: A Grafana dashboard panel can include other panels.
  local mapPanels = function(funcs, panels)
    [
      // Transform the current panel by applying all transformer funcs.
      // Keep the last version after foldl ends.
      std.foldl(function(agg, fn) fn(agg), funcs, p) + (
        // Recursively apply all transformer functions to any
        // children panels.
        if std.objectHas(p, 'panels') then {
          panels: mapPanels(funcs, p.panels),
        } else {}
      )
      for p in panels
    ],

  // mapTemplateParameters applies a static list of transformer functions to
  // all dashboard template parameters.
  local mapTemplateParameters = function(ls)
    [
      std.foldl(function(x, fn) fn(x), [withMultiSelectTemplate], item)
      for item in ls
    ],

  loki: {
    _config+:: {
      promtail: {
        enabled: false,
      }
    },

    grafanaDashboards+: {
      'loki-chunks.json'+: {
        labelsSelector:: 'cluster=~"$cluster", job=~"($namespace)/loki"',

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
        local dropList = ['Compactor CPU usage', 'Compactor memory usage (MiB)', 'List of deletion requests'],

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
          for r in dropPanels(super.rows, dropList)
        ],

        templating+: {
          list: mapTemplateParameters(super.list),
        }
      },

      // TODO: Fix this to work. We may need to create our own dashboard based on theirs as it isn't very easy to modify
      /*'loki-operational.json'+: {
        hiddenRows:: [
          'Cassandra',
          'GCS',
          'Memcached',
          'Consul',
          'Big Table',
          'Dynamo',
          'Azure Blob',
          'BoltDB Shipper',
        ],

        jobMatchers:: {
          cortexgateway:: [utils.selector.re('job', '($namespace)/loki')],
          distributor:: [utils.selector.re('job', '($namespace)/loki')],
          ingester:: [utils.selector.re('job', '($namespace)/loki')],
          querier:: [utils.selector.re('job', '($namespace)/loki')],
          queryFrontend:: [utils.selector.re('job', '($namespace)/loki')],
        },

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
      },*/

      'loki-reads.json'+: {
        local dropList = ['Frontend (query-frontend)', 'Ingester - Zone Aware', 'BoltDB Shipper'],
        local replacements = [
          { from: 'pod', to: 'instance' },
        ],

        matchers:: {
          cortexgateway:: [],
          queryFrontend:: [],
          querier:: [utils.selector.re('job', '($namespace)/loki')],
          ingester:: [utils.selector.re('job', '($namespace)/loki')],
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

        rows: [
          r {
            panels: mapPanels([replaceMatchers('Per Pod Latency (p99)', replacements), replaceTitle('Per Pod Latency (p99)', 'Per Instance Latency (p99)')], r.panels)
          }
          for r in dropPanels(super.rows, dropList)
        ],

        templating+: {
          list: mapTemplateParameters(super.list),
        }
      },

      'loki-retention.json'+: {
        local dropList = ['Resource Usage', 'Logs'],

        uid: '',
        time: {
          from: 'now-6h',
          to: 'now'
        },
        refresh: '1m',
        timezone: '',

        rows: dropPanels(super.rows, dropList),

        // TODO: remove loki datasource variable
        templating+: {
          list: mapTemplateParameters(super.list),
        }
      },

      'loki-writes.json'+: {
        local dropList = ['Distributor - Structured Metadata', 'Ingester - Zone Aware', 'BoltDB Shipper'],

        matchers:: {
          cortexgateway:: [],
          distributor:: [utils.selector.re('job', '($namespace)/loki')],
          ingester:: [utils.selector.re('job', '($namespace)/loki')],
          ingester_zone:: [],
          any_ingester:: [utils.selector.re('job', '($namespace)/loki')],
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
      },
    }
  }
}
