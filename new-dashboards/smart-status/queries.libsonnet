local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v9.4.0/main.libsonnet';

{
  disksMonitored:
    grafonnet.query.prometheus.new('$datasource', 'sum(smartmon_device_active{cluster=~"$cluster", namespace=~"$namespace", host="$host"})')
    + grafonnet.query.prometheus.withFormat('time_series')
    + grafonnet.query.prometheus.withInstant(true)
    + grafonnet.query.prometheus.withIntervalFactor(null),

  unhealthyDisks:
    grafonnet.query.prometheus.new('$datasource', 'sum(smartmon_device_smart_enabled{cluster=~"$cluster", namespace=~"$namespace", host="$host"})-sum(smartmon_device_smart_healthy{cluster=~"$cluster", namespace=~"$namespace", host="$host"})')
    + grafonnet.query.prometheus.withFormat('time_series')
    + grafonnet.query.prometheus.withInstant(true)
    + grafonnet.query.prometheus.withIntervalFactor(null),

  diskDrives:
    grafonnet.query.prometheus.new('$datasource', 'smartmon_device_info{cluster=~"$cluster", namespace=~"$namespace", host="$host"}')
    + grafonnet.query.prometheus.withFormat('table')
    + grafonnet.query.prometheus.withInstant(true)
    + grafonnet.query.prometheus.withIntervalFactor(null),

  temperatureHistory:
    grafonnet.query.prometheus.new('$datasource', 'smartmon_attr_raw_value{cluster=~"$cluster", namespace=~"$namespace", host="$host", name="temperature_celsius"}')
    + grafonnet.query.prometheus.withFormat('time_series')
    + grafonnet.query.prometheus.withLegendFormat('{{device}} {{disk}}')
}
