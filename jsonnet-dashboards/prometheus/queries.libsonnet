local grafonnet = import '../g.libsonnet';

local prometheusQuery = grafonnet.query.prometheus;

{
  prometheusCount:
    prometheusQuery.new('$datasource', 'count by (cluster, namespace, instance, version) (prometheus_build_info{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"})')
    + prometheusQuery.withFormat('table')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  prometheusUptime:
    prometheusQuery.new('$datasource', 'max by (cluster, namespace, instance) (time() - process_start_time_seconds{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"})')
    + prometheusQuery.withFormat('table')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  targetSync:
    prometheusQuery.new('$datasource', 'sum(rate(prometheus_target_sync_length_seconds_sum{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}[$__rate_interval])) by (scrape_job) * 1e3')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ scrape_job }}'),

  targets:
    prometheusQuery.new('$datasource', 'sum(prometheus_sd_discovered_targets{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"})')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('Targets'),

  averageScrapeDuration:
    prometheusQuery.new('$datasource', |||
      rate(prometheus_target_interval_length_seconds_sum{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}[$__rate_interval])
      /
      rate(prometheus_target_interval_length_seconds_count{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}[$__rate_interval])
      * 1e3
    |||)
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{interval}} configured'),

  exceededBodySizeLimit:
    prometheusQuery.new('$datasource', 'sum by (job) (rate(prometheus_target_scrapes_exceeded_body_size_limit_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('exceeded body size limit: {{ job }}'),

  exceededSampleLimit:
    prometheusQuery.new('$datasource', 'sum by (job) (rate(prometheus_target_scrapes_exceeded_sample_limit_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('exceeded sample limit: {{ job }}'),

  sampleDuplicateTimestamp:
    prometheusQuery.new('$datasource', 'sum by (job) (rate(prometheus_target_scrapes_sample_duplicate_timestamp_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('duplicate timestamp: {{ job }}'),

  sampleOutOfBounds:
    prometheusQuery.new('$datasource', 'sum by (job) (rate(prometheus_target_scrapes_sample_out_of_bounds_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('out of bounds: {{ job }}'),

  sampleOutOfOrder:
    prometheusQuery.new('$datasource', 'sum by (job) (rate(prometheus_target_scrapes_sample_out_of_order_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('out of order: {{ job }}'),

  appendedSamples:
    prometheusQuery.new('$datasource', 'rate(prometheus_tsdb_head_samples_appended_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{job}} {{instance}}'),

  headSeries:
    prometheusQuery.new('$datasource', 'prometheus_tsdb_head_series{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{job}} {{instance}} head series'),

  headChunks:
    prometheusQuery.new('$datasource', 'prometheus_tsdb_head_chunks{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{job}} {{instance}} head chunks'),

  queryRate:
    prometheusQuery.new('$datasource', 'rate(prometheus_engine_query_duration_seconds_count{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", slice="inner_eval"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{job}} {{instance}}'),

  stageDuration:
    prometheusQuery.new('$datasource', 'max by (slice) (prometheus_engine_query_duration_seconds{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", quantile="0.9"}) * 1e3')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{slice}}'),
}
