local grafana = import 'grafonnet/grafana.libsonnet';

// Panels

local upsStatePanel = grafana.statPanel.new(
    title="UPS State",
    colorMode="fixed",
    sparkLines=false
).addTarget(
    grafana.prometheus.target(
        "ups_state",
        legendFormat="{{device}}",
        datasource="Prometheus-Internal",
        instant=true
    )
).addValueMapping(
    value="0",
    color="red",
    displayText="Not Normal"
).addValueMapping(
    value="1",
    color="green",
    displayText="Normal"
);

local upsStateTimelinePanel = grafana.timeseriesPanel.new(
    title="UPS State",
    colorMode="thresholds",
    fillOpacity=100,
    min=0,
    max=1
).addTarget(
    grafana.prometheus.target(
        "ups_state",
        legendFormat="{{device}}",
        datasource="Prometheus-Internal",
        intervalFactor=null
    )
).addValueMapping(
    value="0",
    color="red",
    displayText="Not Normal"
).addValueMapping(
    value="1",
    color="green",
    displayText="Normal"
).addThreshold(
    "red"
).addThreshold(
    "green",
    value="1"
);

local batteryCapacity = grafana.gaugePanel.new(
    "Battery Capacity"
).addTarget(
    grafana.prometheus.target(
        "ups_battery_capacity",
        legendFormat="{{device}}",
        datasource="Prometheus-Internal",
        intervalFactor=null
    )
);

// Dashboard

grafana.dashboard.new(
    'UPS Status',
    tags=['generated'],
    schemaVersion=0
).addPanel(upsStatePanel, gridPos={
    x: 0,
    y: 0,
    w: 5,
    h: 8
}).addPanel(upsStateTimelinePanel, gridPos={
    x: 5,
    y: 0,
    w: 5,
    h: 8
}).addPanel(batteryCapacity, gridPos={
    x: 0,
    y: 8,
    w: 5,
    h: 8
})
