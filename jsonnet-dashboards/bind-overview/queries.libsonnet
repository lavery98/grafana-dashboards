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

local grafonnet = import '../g.libsonnet';

local prometheusQuery = grafonnet.query.prometheus;

{
  lastRestarted:
    prometheusQuery.new('$datasource', 'bind_boot_time_seconds{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"} * 1000')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  lastReconfigured:
    prometheusQuery.new('$datasource', 'bind_config_time_seconds{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"} * 1000')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  sumOfIncomingDNSQueries:
    prometheusQuery.new('$datasource', 'sum(irate(bind_incoming_queries_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('Incoming'),

  incomingDNSQueries:
    prometheusQuery.new('$datasource', 'irate(bind_incoming_queries_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ type }}'),

  sumOfOutgoingDNSQueries:
    prometheusQuery.new('$datasource', 'sum(irate(bind_resolver_queries_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('Outgoing'),

  outgoingDNSQueries:
    prometheusQuery.new('$datasource', 'irate(bind_resolver_queries_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ type }}'),

  incomingRequests:
    prometheusQuery.new('$datasource', 'irate(bind_incoming_requests_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ opcode }}'),

  responsesSent:
    prometheusQuery.new('$datasource', 'irate(bind_responses_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ result }}'),

  queryRetries:
    prometheusQuery.new('$datasource', 'irate(bind_resolver_query_retries_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('queries retried {{ view }}'),

  queryDuplicates:
    prometheusQuery.new('$datasource', 'irate(bind_query_duplicates_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('Duplicated queries received'),

  queryErrors:
    prometheusQuery.new('$datasource', 'irate(bind_query_errors_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ error }} queries'),

  queryRecursions:
    prometheusQuery.new('$datasource', 'irate(bind_query_recursions_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('Queries causing recursionries received'),

  responseErrors:
    prometheusQuery.new('$datasource', 'irate(bind_resolver_response_errors_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ error }} {{ view }}'),

  resolverQueryErrors:
    prometheusQuery.new('$datasource', 'irate(bind_resolver_query_errors_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ error }} {{ view }}'),

  resolverQueryEdnsErrors:
    prometheusQuery.new('$datasource', 'irate(bind_resolver_query_edns0_errors_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('EDNS(0) error {{ view }}'),

  zoneSerials:
    prometheusQuery.new('$datasource', 'bind_zone_serial{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}')
    + prometheusQuery.withFormat('table')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  zoneSerialChanges:
    prometheusQuery.new('$datasource', 'rate(bind_zone_serial{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ zone_name }}'),

  failedZoneTransfers:
    prometheusQuery.new('$datasource', 'rate(bind_zone_transfer_failure_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat(' '),

  rejectedZoneTransfers:
    prometheusQuery.new('$datasource', 'rate(bind_zone_transfer_rejected_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat(' '),
}
