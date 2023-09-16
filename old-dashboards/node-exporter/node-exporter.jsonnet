local grafana = import 'grafonnet/grafana.libsonnet';

// This dashboard requires the node-exporter-full.json file to be placed in this directory so that it can be modified
local nodeExporterFull = import 'node-exporter-full.json';

grafana.dashboard.new(
  'Node Exporter',
  uid='node-exporter',
  tags=['generated', 'node-exporter'],
  graphTooltip='shared_crosshair',
  schemaVersion=0
).addTemplate(
  grafana.template.datasource(
    'datasource',
    'prometheus',
    'Mimir'
  )
).addTemplate(
  grafana.template.new(
    'cluster',
    '$datasource',
    'label_values(node_exporter_build_info, cluster)',
    allValues='.+',
    includeAll=true,
    multi=true,
    sort=2
  )
).addTemplate(
  grafana.template.new(
    'namespace',
    '$datasource',
    'label_values(node_exporter_build_info{cluster=~"$cluster"}, namespace)',
    allValues='.+',
    includeAll=true,
    multi=true,
    sort=2
  )
).addTemplate(
  grafana.template.new(
    'host',
    '$datasource',
    'label_values(node_exporter_build_info{cluster=~"$cluster", namespace=~"$namespace"}, host)',
    sort=2
  )
).addTemplate(
  grafana.template.custom(
    'diskdevices',
    '[a-z]+|nvme[0-9]+n[0-9]+|mmcblk[0-9]+',
    '[a-z]+|nvme[0-9]+n[0-9]+|mmcblk[0-9]+',
    hide='all'
  )
).addPanels(
  /*local Modify(panel) =
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
              datasource='${DS_PROMETHEUS}',
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
              datasource='${DS_PROMETHEUS}',
              intervalFactor=1,
              legendFormat='{{sensor}}'
            )
          ) + {
            gridPos: { x: 12, y: 53, w: 12, h: 10 },
          },
        ],
      },
    ] else if id == 270 then [
      panel {
        panels: [
          x {
            targets: [
              t {
                expr: t.expr + ' * on (device) group_left(device_label) node_disk_label_info{instance="$node",job="$job"} or on (device) label_replace(' + t.expr + ', "device_label", "$1", "device", "(.*)")',
                legendFormat: std.strReplace(t.legendFormat, '{{device}}', '{{device_label}}'),
              }
              for t in x.targets
            ],
          }
          for x in panel.panels
        ],
      },
    ] else if id == 271 then [
      panel,
      grafana.row.new(
        'Storage LVM',
        collapse=true
      ).addPanel(
        grafana.timeseriesPanel.new(
          'Physical Disk Space Used',
          fillOpacity=20,
          tooltip='all',
          unit='percent'
        ).addTarget(
          grafana.prometheus.target(
            '100 - ((node_physical_volume_free{instance="$node",job="$job"} * 100) / node_physical_volume_size{instance="$node",job="$job"})',
            datasource='${DS_PROMETHEUS}',
            intervalFactor=1,
            legendFormat='{{name}}'
          )
        ),
        gridPos={ x: 0, y: 30, w: 12, h: 10 }
      ).addPanel(
        grafana.timeseriesPanel.new(
          'Logical Volume Usage for $volume_group',
          fillOpacity=20,
          legendMode='table',
          legendValues=['mean', 'lastNotNull', 'max', 'min'],
          repeat='volume_group',
          stackSeries='normal',
          tooltip='all',
          unit='bytes'
        ).addTarget(
          grafana.prometheus.target(
            'node_volume_group_free{instance="$node", job="$job", name="$volume_group"}',
            datasource='${DS_PROMETHEUS}',
            intervalFactor=1,
            legendFormat='free'
          )
        ).addTarget(
          grafana.prometheus.target(
            'node_logical_volume_size{instance="$node", job="$job", vgroup="$volume_group"}',
            datasource='${DS_PROMETHEUS}',
            intervalFactor=1,
            legendFormat='{{name}}'
          )
        ),
        gridPos={ x: 12, y: 30, w: 12, h: 10 }
      ) + {
        gridPos: { x: 0, y: 29, h: 1, w: 24 },
      },
    ] else [
      panel,
    ];
  local panels = std.flattenArrays([
    Modify(i)
    for i in nodeExporterFull.panels
  ]);*/
  local ModifyTarget(target) = target {
    datasource: {
      type: 'prometheus',
      uid: '${datasource}',
    },
  } + (
    if std.objectHas(target, 'expr') then {
      expr: std.strReplace(target.expr, 'instance="$node",job="$job"', 'cluster=~"$cluster",namespace=~"$namespace",host="$host"'),
    } else {}
  );
  local ModifyPanel(panel) = [
    panel {
      datasource: {
        type: 'prometheus',
        uid: '${datasource}',
      },
      targets: [
        ModifyTarget(t)
        for t in panel.targets
      ],
    } + (
      local id = panel.id;
      if id == 304 then {
        panels: [
          panel.panels[0] {
            datasource: {
              type: 'prometheus',
              uid: '${datasource}',
            },
            targets: [
              ModifyTarget(t)
              for t in panel.panels[0].targets
            ],
          },
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
              'node_ipmi_speed_rpm{cluster=~"$cluster",namespace=~"$namespace",host="$host"}',
              datasource='${datasource}',
              intervalFactor=1,
              legendFormat='{{sensor}}'
            )
          ) + {
            gridPos: { x: 12, y: 43, w: 12, h: 10 },
          },
          panel.panels[1] {
            datasource: {
              type: 'prometheus',
              uid: '${datasource}',
            },
            targets: [
              ModifyTarget(t)
              for t in panel.panels[1].targets
            ],
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
              'node_ipmi_volts{cluster=~"$cluster",namespace=~"$namespace",host="$host"}',
              datasource='${datasource}',
              intervalFactor=1,
              legendFormat='{{sensor}}'
            )
          ) + {
            gridPos: { x: 12, y: 53, w: 12, h: 10 },
          },
        ],
      } else if id == 270 then {
        panels: [
          p {
            datasource: {
              type: 'prometheus',
              uid: '${datasource}',
            },
            targets: [
              ModifyTarget(t {
                expr: t.expr + ' * on (device) group_left(device_label) node_disk_label_info{cluster=~"$cluster",namespace=~"$namespace",host="$host"} or on (device) label_replace(' + t.expr + ', "device_label", "$1", "device", "(.*)")',
                legendFormat: std.strReplace(t.legendFormat, '{{device}}', '{{device_label}}'),
              })
              for t in p.targets
            ],
          }
          for p in panel.panels
        ],
      } else if std.objectHas(panel, 'panels') then {
        panels: [
          p {
            datasource: {
              type: 'prometheus',
              uid: '${datasource}',
            },
            targets: [
              ModifyTarget(t)
              for t in p.targets
            ],
          }
          for p in panel.panels
        ],
      } else {}
    ),
  ];
  local modifiedPanels = std.flattenArrays([
    ModifyPanel(p)
    for p in nodeExporterFull.panels
  ]);
  modifiedPanels
)
