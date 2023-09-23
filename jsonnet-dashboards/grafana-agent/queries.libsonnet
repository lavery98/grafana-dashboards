local grafonnet = import '../g.libsonnet';

local prometheusQuery = grafonnet.query.prometheus;

{
  agentCount:
    prometheusQuery.new('$datasource', 'count by (cluster, namespace, instance, version) (agent_build_info{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"})')
    + prometheusQuery.withFormat('table')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  agentUptime:
    prometheusQuery.new('$datasouce', 'max by (cluster, namespace, instance) (time() - process_start_time_seconds{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"})')
    + prometheusQuery.withFormat('table')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  targetSync:
    prometheusQuery.new('$datasource', 'sum(rate(prometheus_target_sync_length_seconds_sum{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[$__rate_interval])) by (instance, scrape_job) * 1e3')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ instance }}/{{ scrape_job }}'),

  targets:
    prometheusQuery.new('$datasource', 'sum by (instance) (prometheus_sd_discovered_targets{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"})')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ instance }}'),

  averageScrapeDuration:
    prometheusQuery.new('$datasource', |||
      rate(prometheus_target_interval_length_seconds_sum{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[$__rate_interval])
      /
      rate(prometheus_target_interval_length_seconds_count{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[$__rate_interval])
      * 1e3
    |||)
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ instance }} {{ interval }} configured'),

  exceededSampleLimit:
    prometheusQuery.new('$datasource', 'sum by (job) (rate(prometheus_target_scrapes_exceeded_sample_limit_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('exceeded sample limit: {{ job }}'),

  sampleDuplicateTimestamp:
    prometheusQuery.new('$datasource', 'sum by (job) (rate(prometheus_target_scrapes_sample_duplicate_timestamp_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('duplicate timestamp: {{ job }}'),

  sampleOutOfBounds:
    prometheusQuery.new('$datasource', 'sum by (job) (rate(prometheus_target_scrapes_sample_out_of_bounds_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('out of bounds: {{ job }}'),

  sampleOutOfOrder:
    prometheusQuery.new('$datasource', 'sum by (job) (rate(prometheus_target_scrapes_sample_out_of_order_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('out of order: {{ job }}'),

  appendedSamples:
    prometheusQuery.new('$datasource', 'sum by (job, instance_group_name) (rate(agent_wal_samples_appended_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{job}} {{instance_group_name}}'),
}
