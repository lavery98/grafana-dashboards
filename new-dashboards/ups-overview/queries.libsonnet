local grafonnet = import '../g.libsonnet';

local prometheusQuery = grafonnet.query.prometheus;

{
  upsStateNow:
    prometheusQuery.new('$datasource', 'ups_state{cluster="$cluster", host="$host"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  batteryCapacityNow:
    prometheusQuery.new('$datasource', 'ups_battery_capacity{cluster="$cluster", host="$host"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  batteryRemainingNow:
    prometheusQuery.new('$datasource', 'ups_runtime_remaining{cluster="$cluster", host="$host"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  upsLoadNow:
    prometheusQuery.new('$datasource', 'ups_load{cluster="$cluster", host="$host"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  upsState:
    prometheusQuery.new('$datasource', 'ups_state{cluster="$cluster", host="$host"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('State'),

  batteryCapacity:
    prometheusQuery.new('$datasource', 'ups_battery_capacity{cluster="$cluster", host="$host"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{device}}'),

  batteryRemaining:
    prometheusQuery.new('$datasource', 'ups_runtime_remaining{cluster="$cluster", host="$host"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{device}}'),

  upsLoad:
    prometheusQuery.new('$datasource', 'ups_load{cluster="$cluster", host="$host"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{device}}'),

  inputVoltage:
    prometheusQuery.new('$datasource', 'ups_in_voltage{cluster="$cluster", host="$host"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{device}}'),

  outputVoltage:
    prometheusQuery.new('$datasource', 'ups_out_voltage{cluster="$cluster", host="$host"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('{{device}}'),
}
