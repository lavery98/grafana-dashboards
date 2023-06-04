local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v9.4.0/main.libsonnet';

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
}
