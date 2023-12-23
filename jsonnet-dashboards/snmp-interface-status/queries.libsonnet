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

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local prometheusQuery = grafonnet.query.prometheus;

{
  adminStatus:
    prometheusQuery.new('$datasource', 'ifAdminStatus{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  operStatus:
    prometheusQuery.new('$datasource', 'ifOperStatus{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  lastChange:
    prometheusQuery.new('$datasource', 'sysUpTime{cluster="$cluster", instance="$instance"} - on(cluster, instance) ifLastChange{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  connectorPresent:
    prometheusQuery.new('$datasource', 'ifConnectorPresent{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  promiscuousMode:
    prometheusQuery.new('$datasource', 'ifPromiscuousMode{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  speed:
    prometheusQuery.new('$datasource', 'ifHighSpeed{cluster="$cluster", instance="$instance", ifDescr="$interface"} * 1000000 or ifSpeed{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  mtu:
    prometheusQuery.new('$datasource', 'ifMtu{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  ifTypeInfo:
    prometheusQuery.new('$datasource', 'ifType_info{cluster="$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('table')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  traffic: [
    prometheusQuery.new('$datasource', '(rate(ifHCInOctets{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifInOctets{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval])) * 8')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('IN: {{ifDescr}}'),

    prometheusQuery.new('$datasource', '(rate(ifHCOutOctets{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifOutOctets{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval])) * 8')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('OUT: {{ifDescr}}'),
  ],

  broadcastPackets: [
    prometheusQuery.new('$datasource', '(rate(ifHCInBroadcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifInBroadcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('IN: {{ifDescr}}'),

    prometheusQuery.new('$datasource', '(rate(ifHCOutBroadcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifOutBroadcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('OUT: {{ifDescr}}'),
  ],

  unicastPackets: [
    prometheusQuery.new('$datasource', '(rate(ifHCInUcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifInUcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('IN: {{ifDescr}}'),

    prometheusQuery.new('$datasource', '(rate(ifHCOutUcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifOutUcastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('OUT: {{ifDescr}}'),
  ],

  multicastPackets: [
    prometheusQuery.new('$datasource', '(rate(ifHCInMulticastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifInMulticastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('IN: {{ifDescr}}'),

    prometheusQuery.new('$datasource', '(rate(ifHCOutMulticastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]) or rate(ifOutMulticastPkts{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval]))')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('OUT: {{ifDescr}}'),
  ],

  errors: [
    prometheusQuery.new('$datasource', 'rate(ifInErrors{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('IN: {{ifDescr}}'),

    prometheusQuery.new('$datasource', 'rate(ifOutErrors{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('OUT: {{ifDescr}}'),
  ],

  discards: [
    prometheusQuery.new('$datasource', 'rate(ifInDiscards{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('IN discards: {{ifDescr}}'),

    prometheusQuery.new('$datasource', 'rate(ifInUnknownProtos{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('IN unknown protos: {{ifDescr}}'),

    prometheusQuery.new('$datasource', 'rate(ifOutDiscards{cluster="$cluster", instance="$instance", ifDescr="$interface"}[$__rate_interval])')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withLegendFormat('OUT discards: {{ifDescr}}'),
  ],
}
