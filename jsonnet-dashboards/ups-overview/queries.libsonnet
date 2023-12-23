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
