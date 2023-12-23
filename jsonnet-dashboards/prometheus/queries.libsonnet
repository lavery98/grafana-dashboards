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

  timestampComparison:
    prometheusQuery.new('$datasource', |||
      (
        prometheus_remote_storage_highest_timestamp_in_seconds{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}
      -
        ignoring(remote_name, url) group_right(cluster, namespace, instance) (prometheus_remote_storage_queue_highest_sent_timestamp_seconds{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"} != 0)
      )
    |||)
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{cluster}}:{{namespace}}:{{instance}} {{remote_name}}:{{url}}'),

  timestampComparisonRate:
    prometheusQuery.new('$datasource', |||
      clamp_min(
        rate(prometheus_remote_storage_highest_timestamp_in_seconds{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}[5m])
      -
        ignoring (remote_name, url) group_right(cluster, namespace, instance) rate(prometheus_remote_storage_queue_highest_sent_timestamp_seconds{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}[5m])
      , 0)
    |||)
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{cluster}}:{{namespace}}:{{instance}} {{remote_name}}:{{url}}'),

  samplesRate:
    prometheusQuery.new('$datasource', |||
      (
        rate(prometheus_remote_storage_samples_in_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}[5m])
      -
        ignoring(remote_name, url) group_right(cluster, namespace, instance) (rate(prometheus_remote_storage_succeeded_samples_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}[5m]) or rate(prometheus_remote_storage_samples_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}[5m]))
      -
        (rate(prometheus_remote_storage_dropped_samples_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}[5m]) or rate(prometheus_remote_storage_samples_dropped_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}[5m]))
      )
    |||)
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{cluster}}:{{namespace}}:{{instance}} {{remote_name}}:{{url}}'),

  currentShards:
    prometheusQuery.new('$datasource', 'prometheus_remote_storage_shards{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{cluster}}:{{namespace}}:{{instance}} {{remote_name}}:{{url}}'),

  maxShards:
    prometheusQuery.new('$datasource', 'prometheus_remote_storage_shards_max{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{cluster}}:{{namespace}}:{{instance}} {{remote_name}}:{{url}}'),

  minShards:
    prometheusQuery.new('$datasource', 'prometheus_remote_storage_shards_min{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{cluster}}:{{namespace}}:{{instance}} {{remote_name}}:{{url}}'),

  desiredShards:
    prometheusQuery.new('$datasource', 'prometheus_remote_storage_shards_desired{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{cluster}}:{{namespace}}:{{instance}} {{remote_name}}:{{url}}'),

  shardsCapacity:
    prometheusQuery.new('$datasource', 'prometheus_remote_storage_shard_capacity{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{cluster}}:{{namespace}}:{{instance}} {{remote_name}}:{{url}}'),

  pendingSamples:
    prometheusQuery.new('$datasource', 'prometheus_remote_storage_pending_samples{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"} or prometheus_remote_storage_samples_pending{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{cluster}}:{{namespace}}:{{instance}} {{remote_name}}:{{url}}'),

  walSegment:
    prometheusQuery.new('$datasource', 'prometheus_tsdb_wal_segment_current{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{cluster}}:{{namespace}}:{{instance}}'),

  queueSegment:
    prometheusQuery.new('$datasource', 'prometheus_wal_watcher_current_segment{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{cluster}}:{{namespace}}:{{instance}} {{consumer}}'),

  droppedSamples:
    prometheusQuery.new('$datasource', 'rate(prometheus_remote_storage_dropped_samples_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}[5m]) or rate(prometheus_remote_storage_samples_dropped_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}[5m])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{cluster}}:{{namespace}}:{{instance}} {{remote_name}}:{{url}}'),

  failedSamples:
    prometheusQuery.new('$datasource', 'rate(prometheus_remote_storage_failed_samples_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}[5m]) or rate(prometheus_remote_storage_samples_failed_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}[5m])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{cluster}}:{{namespace}}:{{instance}} {{remote_name}}:{{url}}'),

  retriedSamples:
    prometheusQuery.new('$datasource', 'rate(prometheus_remote_storage_retried_samples_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}[5m]) or rate(prometheus_remote_storage_samples_retried_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}[5m])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{cluster}}:{{namespace}}:{{instance}} {{remote_name}}:{{url}}'),

  enqueueRetries:
    prometheusQuery.new('$datasource', 'rate(prometheus_remote_storage_enqueue_retries_total{cluster=~"$cluster", namespace=~"$namespace", job=~"${namespace}/prometheus", url=~"$url"}[5m])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{cluster}}:{{namespace}}:{{instance}} {{remote_name}}:{{url}}'),
}
