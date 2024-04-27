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
  upstreamQueriesIncrease:
    prometheusQuery.new('$datasource', 'sum(increase(dnsmasq_servers_queries{cluster=~"$cluster", namespace=~"$namespace", job=~"($namespace)/dnsmasq_exporter"}[$__range]))')
    + prometheusQuery.withFormat('time_series'),

  upstreamQueriesRate:
    prometheusQuery.new('$datasource', 'sum(rate(dnsmasq_servers_queries{cluster=~"$cluster", namespace=~"$namespace", job=~"($namespace)/dnsmasq_exporter"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series'),

  failedUpstreamQueriesIncrease:
    prometheusQuery.new('$datasource', 'sum(increase(dnsmasq_servers_queries_failed{cluster=~"$cluster", namespace=~"$namespace", job=~"($namespace)/dnsmasq_exporter"}[$__range]))')
    + prometheusQuery.withFormat('time_series'),

  failedUpstreamQueriesRate:
    prometheusQuery.new('$datasource', 'sum(rate(dnsmasq_servers_queries_failed{cluster=~"$cluster", namespace=~"$namespace", job=~"($namespace)/dnsmasq_exporter"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series'),

  failedUpstreamQueriesPercent:
    prometheusQuery.new('$datasource', 'sum(dnsmasq_servers_queries_failed{cluster=~"$cluster", namespace=~"$namespace", job=~"($namespace)/dnsmasq_exporter"}) / sum(dnsmasq_servers_queries{cluster=~"$cluster", namespace=~"$namespace", job=~"($namespace)/dnsmasq_exporter"})')
    + prometheusQuery.withFormat('time_series'),

  cacheHits:
    prometheusQuery.new('$datasource', 'rate(dnsmasq_hits{cluster=~"$cluster", namespace=~"$namespace", job=~"($namespace)/dnsmasq_exporter"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series'),

  cacheMisses:
    prometheusQuery.new('$datasource', 'rate(dnsmasq_misses{cluster=~"$cluster", namespace=~"$namespace", job=~"($namespace)/dnsmasq_exporter"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series'),
}
