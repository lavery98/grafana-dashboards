local grafana = import 'grafonnet/grafana.libsonnet';

// This dashboard requires the node-exporter-full.json file to be placed in this directory so that it can be modified
local nodeExporterFull = import 'node-exporter-full.json';

grafana.dashboard.new(
  'Node Exporter',
  uid='node-exporter',
  tags=['generated', 'node-exporter'],
  graphTooltip='shared_crosshair',
  schemaVersion=0
).addInput(
  name='DS_PROMETHEUS',
  label='Prometheus',
  type='datasource',
  pluginId='prometheus',
  pluginName='Prometheus'
).addTemplate(
  grafana.template.new(
    'job',
    '${DS_PROMETHEUS}',
    'label_values(node_uname_info, job)',
    label='Job',
    sort=1
  )
).addTemplate(
  grafana.template.new(
    'node',
    '${DS_PROMETHEUS}',
    'label_values(node_uname_info{job="$job"}, instance)',
    label='Host',
    sort=1
  )
).addTemplate(
  grafana.template.custom(
    'diskdevices',
    '[a-z]+|nvme[0-9]+n[0-9]+|mmcblk[0-9]+',
    '[a-z]+|nvme[0-9]+n[0-9]+|mmcblk[0-9]+',
    hide='all'
  )
).addPanels(
  local Modify(panel) =
    local id = panel.id;
    if id == 304 then [
      panel {
        panels: [
          panel.panels[0],
          grafana.timeseriesPanel.new(
            'Fan Speed',
            axisLabel='RPM',
            fillOpacity=20,
            legendMode='table',
            legendValues=['mean', 'lastNotNull', 'max', 'min'],
            tooltip='all',
            unit='short'
          ).addTarget(
            grafana.prometheus.target(
              'node_ipmi_speed_rpm{instance="$node", job="$job"}',
              intervalFactor=1,
              legendFormat='{{sensor}}'
            )
          ) + {
            gridPos: { x: 12, y: 43, w: 12, h: 10 },
          },
          panel.panels[1] {
            gridPos: { x: 0, y: 53, w: 12, h: 10 },
          },
          grafana.timeseriesPanel.new(
            'Hardware Voltages',
            axisLabel='voltage',
            fillOpacity=20,
            legendMode='table',
            legendValues=['mean', 'lastNotNull', 'max', 'min'],
            tooltip='all',
            unit='volt'
          ).addTarget(
            grafana.prometheus.target(
              'node_ipmi_volts{instance="$node", job="$job"}',
              intervalFactor=1,
              legendFormat='{{sensor}}'
            )
          ) + {
            gridPos: { x: 12, y: 53, w: 12, h: 10 },
          },
        ],
      },
    ] else [
      panel,
    ];
  local panels = std.flattenArrays([
    Modify(i)
    for i in nodeExporterFull.panels
  ]);
  panels
)
