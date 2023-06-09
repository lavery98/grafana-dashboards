local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v9.4.0/main.libsonnet';

local prometheusQuery = grafonnet.query.prometheus;

{
  probesCurrentStatus:
    prometheusQuery.new('$datasource', 'probe_success{cluster=~"$cluster"}')
    + prometheusQuery.withFormat('table')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  probesHistoricStatus:
    prometheusQuery.new('$datasource', 'probe_success{cluster=~"$cluster"}')
    + prometheusQuery.withLegendFormat('{{instance}}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),

  sslCertificateExpiry:
    prometheusQuery.new('$datasource', 'probe_ssl_earliest_cert_expiry{cluster=~"$cluster"} - time()')
    + prometheusQuery.withFormat('table')
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withIntervalFactor(null),

  dnsLookup:
    prometheusQuery.new('$datasource', 'probe_dns_lookup_time_seconds{cluster=~"$cluster"}')
    + prometheusQuery.withLegendFormat('{{instance}}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),

  probeDuration:
    prometheusQuery.new('$datasource', 'probe_duration_seconds{cluster=~"$cluster"}')
    + prometheusQuery.withLegendFormat('{{instance}}')
    + prometheusQuery.withFormat('time_series')
    + prometheusQuery.withIntervalFactor(2),
}
