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
        intervalFactor=null,
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

local batteryCapacityPanel = grafana.gaugePanel.new(
    "Battery Capacity"
).addTarget(
    grafana.prometheus.target(
        "ups_battery_capacity",
        legendFormat="{{device}}",
        datasource="Prometheus-Internal",
        intervalFactor=null,
        instant=true
    )
).addThreshold({
    "color": "red",
    "value": null
}).addThreshold({
    "color": "orange",
    "value": 50
}).addThreshold({
    "color": "green",
    "value": 80
});

local batteryCapacityTimelinePanel = grafana.timeseriesPanel.new(
    "Battery Capacity",
    colorMode="thresholds",
    thresholdDisplay="dashed",
    min=0,
    max=100
).addTarget(
    grafana.prometheus.target(
        "ups_battery_capacity",
        legendFormat="{{device}}",
        datasource="Prometheus-Internal",
        intervalFactor=null
    )
).addThreshold(
    "red"
).addThreshold(
    "orange",
    value=50
).addThreshold(
    "green",
    value=80
);

// Dashboard

grafana.dashboard.new(
    'UPS Status',
    uid="ups-status-test",
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
}).addPanel(batteryCapacityPanel, gridPos={
    x: 0,
    y: 8,
    w: 5,
    h: 8
}).addPanel(batteryCapacityTimelinePanel, gridPos={
    x: 5,
    y: 8,
    w: 5,
    h: 8
})
