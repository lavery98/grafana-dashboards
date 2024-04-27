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

local grafonnet = import '../g.libsonnet';

local prometheusQuery = grafonnet.query.prometheus;

{
  probesCurrentStatus:
    prometheusQuery.new('$datasource', 'probe_success{cluster=~"$cluster", job=~"$job"}')
    + prometheusQuery.withFormat('table')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  probesHistoricStatus:
    prometheusQuery.new('$datasource', 'probe_success{cluster=~"$cluster", job=~"$job"}')
    + prometheusQuery.withLegendFormat('{{instance}}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),

  sslCertificateExpiry:
    prometheusQuery.new('$datasource', 'probe_ssl_earliest_cert_expiry{cluster=~"$cluster", job=~"$job"} - time()')
    + prometheusQuery.withFormat('table')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  dnsLookup:
    prometheusQuery.new('$datasource', 'probe_dns_lookup_time_seconds{cluster=~"$cluster", job=~"$job"}')
    + prometheusQuery.withLegendFormat('{{instance}}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),

  probeDuration:
    prometheusQuery.new('$datasource', 'probe_duration_seconds{cluster=~"$cluster", job=~"$job"}')
    + prometheusQuery.withLegendFormat('{{instance}}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),
}
