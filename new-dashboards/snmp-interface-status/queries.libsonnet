local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v9.4.0/main.libsonnet';

local prometheusQuery = grafonnet.query.prometheus;

{
  adminStatus:
    prometheusQuery.new('$datasource', 'ifAdminStatus{cluster=~"$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  operStatus:
    prometheusQuery.new('$datasource', 'ifOperStatus{cluster=~"$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  lastChange:
    prometheusQuery.new('$datasource', 'sysUpTime{cluster=~"$cluster", instance="$instance"} - on(cluster, instance) ifLastChange{cluster=~"$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  connectorPresent:
    prometheusQuery.new('$datasource', 'ifConnectorPresent{cluster=~"$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  promiscuousMode:
    prometheusQuery.new('$datasource', 'ifPromiscuousMode{cluster=~"$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  speed:
    prometheusQuery.new('$datasource', 'ifHighSpeed{cluster=~"$cluster", instance="$instance", ifDescr="$interface"} * 1000000 or ifSpeed{cluster=~"$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  mtu:
    prometheusQuery.new('$datasource', 'ifMtu{cluster=~"$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  ifTypeInfo:
    prometheusQuery.new('$datasource', 'ifType_info{cluster=~"$cluster", instance="$instance", ifDescr="$interface"}')
    + prometheusQuery.withFormat('table')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),
}
