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

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local prometheusQuery = grafonnet.query.prometheus;

{
  containers:
    prometheusQuery.new('$datasource', 'count(container_start_time_seconds{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"})')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  totalCPUUsage:
    prometheusQuery.new('$datasource', 'sum(rate(container_cpu_usage_seconds_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval])) * 100')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),

  totalMemoryUsage:
    prometheusQuery.new('$datasource', 'sum(container_memory_rss{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"})')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),

  totalSwapUsage:
    prometheusQuery.new('$datasource', 'sum(container_memory_swap{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"})')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),

  totalReceivedNetworkTraffic:
    prometheusQuery.new('$datasource', 'sum(rate(container_network_receive_bytes_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),

  totalSentNetworkTraffic:
    prometheusQuery.new('$datasource', 'sum(rate(container_network_transmit_bytes_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),

  cpuUsagePerContainer:
    prometheusQuery.new('$datasource', 'sum(rate(container_cpu_usage_seconds_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval])) by (name) * 100')
    + prometheusQuery.withLegendFormat('{{name}}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),

  memoryUsagePerContainer:
    prometheusQuery.new('$datasource', 'sum(container_memory_rss{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}) by (name)')
    + prometheusQuery.withLegendFormat('{{name}}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),

  receivedNetworkTrafficPerContainer:
    prometheusQuery.new('$datasource', 'sum(rate(container_network_receive_bytes_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval])) by (name)')
    + prometheusQuery.withLegendFormat('{{name}}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),

  sentNetworkTrafficPerContainer:
    prometheusQuery.new('$datasource', 'sum(rate(container_network_transmit_bytes_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval])) by (name)')
    + prometheusQuery.withLegendFormat('{{name}}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),

  filesystemReadsPerContainer:
    prometheusQuery.new('$datasource', 'sum(rate(container_fs_reads_bytes_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval])) by (name)')
    + prometheusQuery.withLegendFormat('{{name}}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),

  filesystemWritesPerContainer:
    prometheusQuery.new('$datasource', 'sum(rate(container_fs_writes_bytes_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", name=~".+"}[$__rate_interval])) by (name)')
    + prometheusQuery.withLegendFormat('{{name}}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),
}
