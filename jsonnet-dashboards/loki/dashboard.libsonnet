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

local config = (import 'config.libsonnet');
local loki = (import 'github.com/grafana/loki/production/loki-mixin/mixin.libsonnet') + config.loki;

{
  'loki-chunks.json': loki.grafanaDashboards['loki-chunks.json'],
  'loki-deletion.json': loki.grafanaDashboards['loki-deletion.json'],
  'loki-operational.json': loki.grafanaDashboards['loki-operational.json'],
  'loki-reads.json': loki.grafanaDashboards['loki-reads.json'],
  'loki-retention.json': loki.grafanaDashboards['loki-retention.json'],
  'loki-writes.json': loki.grafanaDashboards['loki-writes.json'],
}
