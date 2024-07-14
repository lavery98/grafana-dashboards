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

(import 'jsonnet-dashboards/bind-overview/main.libsonnet') +
(import 'jsonnet-dashboards/blackbox-exporter-overview/main.libsonnet') +
(import 'jsonnet-dashboards/dnsmasq-overview/main.libsonnet') +
(import 'jsonnet-dashboards/docker-overview/main.libsonnet') +
(import 'jsonnet-dashboards/grafana-agent/main.libsonnet') +
(import 'jsonnet-dashboards/prometheus/main.libsonnet') +
#(import 'jsonnet-dashboards/node-exporter/main.libsonnet') +
(import 'jsonnet-dashboards/smart-overview/main.libsonnet') +
(import 'jsonnet-dashboards/snmp-interface-status/main.libsonnet') +
(import 'jsonnet-dashboards/ups-overview/main.libsonnet')
