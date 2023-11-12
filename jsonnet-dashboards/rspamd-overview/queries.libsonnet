local grafonnet = import '../g.libsonnet';

local prometheusQuery = grafonnet.query.prometheus;

{
  scanned:
    prometheusQuery.new('$datasource', 'rspamd_scanned_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}')
    + prometheusQuery.withFormat('time_series'),

  rejected:
    prometheusQuery.new('$datasource', 'rspamd_actions_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", type="reject"}')
    + prometheusQuery.withFormat('time_series'),

  noAction:
    prometheusQuery.new('$datasource', 'rspamd_actions_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", type="no action"}')
    + prometheusQuery.withFormat('time_series'),

  greylist:
    prometheusQuery.new('$datasource', 'rspamd_actions_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", type="greylist"}')
    + prometheusQuery.withFormat('time_series'),

  addHeader:
    prometheusQuery.new('$datasource', 'rspamd_actions_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host", type="add header"}')
    + prometheusQuery.withFormat('time_series'),

  learned:
    prometheusQuery.new('$datasource', 'rspamd_learned_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}')
    + prometheusQuery.withFormat('time_series'),

  actionsTotal:
    prometheusQuery.new('$datasource', 'rspamd_actions_total{cluster=~"$cluster", namespace=~"$namespace", host=~"$host"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),
}
