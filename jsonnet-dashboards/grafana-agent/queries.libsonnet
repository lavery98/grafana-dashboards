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

  timestampComparison:
    prometheusQuery.new('$datasource', |||
      (
        prometheus_remote_storage_highest_timestamp_in_seconds{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}
        -
        ignoring(url, remote_name) group_right(instance)
        prometheus_remote_storage_queue_highest_sent_timestamp_seconds{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}
      )
    |||)
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ cluster }}:{{ instance }}-{{ instance_group_name }}-{{ url }}'),

  meanRemoteSendLatency:
    prometheusQuery.new('$datasource', 'rate(prometheus_remote_storage_sent_batch_duration_seconds_sum{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[1m]) / rate(prometheus_remote_storage_sent_batch_duration_seconds_count{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[1m])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('mean {{ cluster }}:{{ instance }}-{{ instance_group_name }}-{{ url }}'),

  p99RemoteSendLatency:
    prometheusQuery.new('$datasource', 'histogram_quantile(0.99, rate(prometheus_remote_storage_sent_batch_duration_seconds_bucket{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[1m]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('p99 {{ cluster }}:{{ instance }}-{{ instance_group_name }}-{{ url }}'),

  samplesInRate:
    prometheusQuery.new('$datasource', 'rate(agent_wal_samples_appended_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[5m])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ cluster }}:{{ instance }}-{{ instance_group_name }}-{{ url }}'),

  samplesOutRate:
    prometheusQuery.new('$datasource', 'rate(prometheus_remote_storage_succeeded_samples_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[5m]) or rate(prometheus_remote_storage_samples_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[5m])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ cluster }}:{{ instance }}-{{ instance_group_name }}-{{ url }}'),

  pendingSamples:
    prometheusQuery.new('$datasource', 'prometheus_remote_storage_samples_pending{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ cluster }}:{{ instance }}-{{ instance_group_name }}-{{ url }}'),

  droppedSamples:
    prometheusQuery.new('$datasource', 'rate(prometheus_remote_storage_samples_dropped_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[5m])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ cluster }}:{{ instance }}-{{ instance_group_name }}-{{ url }}'),

  failedSamples:
    prometheusQuery.new('$datasource', 'rate(prometheus_remote_storage_samples_failed_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[5m])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ cluster }}:{{ instance }}-{{ instance_group_name }}-{{ url }}'),

  retriedSamples:
    prometheusQuery.new('$datasource', 'rate(prometheus_remote_storage_samples_retried_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[5m])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ cluster }}:{{ instance }}-{{ instance_group_name }}-{{ url }}'),

  currentShards:
    prometheusQuery.new('$datasource', 'prometheus_remote_storage_shards{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ cluster }}:{{ instance }}-{{ instance_group_name }}-{{ url }}'),

  maxShards:
    prometheusQuery.new('$datasource', 'prometheus_remote_storage_shards_max{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ cluster }}:{{ instance }}-{{ instance_group_name }}-{{ url }}'),

  minShards:
    prometheusQuery.new('$datasource', 'prometheus_remote_storage_shards_min{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ cluster }}:{{ instance }}-{{ instance_group_name }}-{{ url }}'),

  desiredShards:
    prometheusQuery.new('$datasource', 'prometheus_remote_storage_shards_desired{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ cluster }}:{{ instance }}-{{ instance_group_name }}-{{ url }}'),

  shardsCapacity:
    prometheusQuery.new('$datasource', 'prometheus_remote_storage_shard_capacity{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ cluster }}:{{ instance }}-{{ instance_group_name }}-{{ url }}'),

  queueSegment:
    prometheusQuery.new('$datasource', 'prometheus_wal_watcher_current_segment{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ cluster }}:{{ instance }}-{{ instance_group_name }}'),

  enqueueRetries:
    prometheusQuery.new('$datasource', 'rate(prometheus_remote_storage_enqueue_retries_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/agent"}[5m])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{ cluster }}:{{ instance }}-{{ instance_group_name }}'),

}
