local grafana = import 'grafonnet/grafana.libsonnet';

// Allow datasource to be easily changed for testing
local datasourceToUse="${DS_PROMETHEUS}";

// Dashboard
grafana.dashboard.new(
    'UPS Status',
    uid="ups-status",
    tags=['generated'],
    schemaVersion=0
).addInput(
    name="DS_PROMETHEUS",
    label="Prometheus",
    type="datasource",
    pluginId="prometheus",
    pluginName="Prometheus"
).addPanel(
    grafana.statPanel.new(
        title="UPS State",
        colorMode="fixed",
        sparkLines=false
    ).addTarget(
        grafana.prometheus.target(
            "ups_state",
            legendFormat="{{device}}",
            datasource=datasourceToUse,
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
    ),
    gridPos={ x: 0, y: 0, w: 6, h: 5 }
).addPanel(
    grafana.gaugePanel.new(
        "Battery Capacity"
    ).addTarget(
        grafana.prometheus.target(
            "ups_battery_capacity",
            legendFormat="{{device}}",
            datasource=datasourceToUse,
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
    }),
    gridPos={ x: 6, y: 0, w: 6, h: 5 }
).addPanel(
    grafana.statPanel.new(
        "Battery Time Remaining",
        colorMode="thresholds",
        unit="m"
    ).addTarget(
        grafana.prometheus.target(
            "ups_runtime_remaining",
            legendFormat="{{device}}",
            datasource=datasourceToUse,
            intervalFactor=null,
            instant=true
        )
    ).addThreshold(
        "red"
    ).addThreshold(
        "orange",
        value=15
    ).addThreshold(
        "green",
        value=30
    ),
    gridPos={ x: 12, y: 0, w: 6, h: 5 }
).addPanel(
    grafana.statPanel.new(
        "UPS Load",
        unit="watt"
    ).addTarget(
        grafana.prometheus.target(
            "ups_load",
            legendFormat="{{device}}",
            datasource=datasourceToUse,
            intervalFactor=null,
            instant=true
        )
    ),
    gridPos={ x: 18, y: 0, w: 6, h: 5 }
).addPanel(
    grafana.timeseriesPanel.new(
        title="UPS State",
        colorMode="thresholds",
        fillOpacity=100,
        min=0,
        max=1
    ).addTarget(
        grafana.prometheus.target(
            "ups_state",
            legendFormat="{{device}}",
            datasource=datasourceToUse,
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
    ), 
    gridPos={ x: 0, y: 5, w: 6, h: 8 }
).addPanel(
    grafana.timeseriesPanel.new(
        "Battery Capacity",
        colorMode="thresholds",
        thresholdDisplay="dashed",
        min=0,
        max=100
    ).addTarget(
        grafana.prometheus.target(
            "ups_battery_capacity",
            legendFormat="{{device}}",
            datasource=datasourceToUse,
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
    ), 
    gridPos={ x: 6, y: 5, w: 6, h: 8 }
).addPanel(
    grafana.timeseriesPanel.new(
        "Battery Time Remaining",
        unit="m"
    ).addTarget(
        grafana.prometheus.target(
            "ups_runtime_remaining",
            legendFormat="{{device}}",
            datasource=datasourceToUse,
            intervalFactor=null
        )
    ),
    gridPos={ x: 12, y: 5, w: 6, h: 8 }
).addPanel(
    grafana.timeseriesPanel.new(
        "UPS Load",
        unit="watt"
    ).addTarget(
        grafana.prometheus.target(
            "ups_load",
            legendFormat="{{device}}",
            datasource=datasourceToUse,
            intervalFactor=null
        )
    ),
    gridPos={ x: 18, y: 5, w: 6, h: 8 }
).addPanel(
    grafana.timeseriesPanel.new(
        "UPS Input Voltage",
        unit="volt"
    ).addTarget(
        grafana.prometheus.target(
            "ups_in_voltage",
            legendFormat="{{device}}",
            datasource=datasourceToUse,
            intervalFactor=null
        )
    ),
    gridPos={ x: 0, y: 13, w: 24, h: 8 }
).addPanel(
    grafana.timeseriesPanel.new(
        "UPS Output Voltage",
        unit="volt"
    ).addTarget(
        grafana.prometheus.target(
            "ups_out_voltage",
            legendFormat="{{device}}",
            datasource=datasourceToUse,
            intervalFactor=null
        )
    ),
    gridPos={ x: 0, y: 21, w: 24, h: 8 }
)
