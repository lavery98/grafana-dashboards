local grafana = import 'grafonnet/grafana.libsonnet';

// Allow datasource to be easily changed for testing
local datasourceToUse = '${DS_PROMETHEUS}';

grafana.dashboard.new(
  'SNMP Interface Status',
  uid='snmp-interface-status',
  tags=['generated', 'snmp-exporter'],
  schemaVersion=0
).addInput(
  name='DS_PROMETHEUS',
  label='Prometheus',
  type='datasource',
  pluginId='prometheus',
  pluginName='Prometheus'
).addTemplate(
  grafana.template.new(
    name='instance',
    label='Instance',
    datasource=datasourceToUse,
    query='label_values(ifOperStatus, instance)',
    sort=1
  )
).addTemplate(
  grafana.template.new(
    name='interface',
    label='Interface',
    datasource=datasourceToUse,
    query='label_values(ifOperStatus{instance="$instance"}, ifDescr)',
    sort=1
  )
).addPanel(
  grafana.statPanel.new(
    'Admin Status',
    colorMode='fixed',
    sparkLines=false
  ).addTarget(
    grafana.prometheus.target(
      'ifAdminStatus{instance="$instance",ifDescr="$interface"}',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ).addValueMapping(
    value='1',
    color='green',
    displayText='up'
  ).addValueMapping(
    value='2',
    color='orange',
    displayText='down'
  ).addValueMapping(
    value='3',
    color='orange',
    displayText='testing'
  ),
  gridPos={ x: 0, y: 0, w: 3, h: 3 }
).addPanel(
  grafana.statPanel.new(
    'Oper Status',
    colorMode='fixed',
    sparkLines=false
  ).addTarget(
    grafana.prometheus.target(
      'ifOperStatus{instance="$instance",ifDescr="$interface"}',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ).addValueMapping(
    value='1',
    color='green',
    displayText='up'
  ).addValueMapping(
    value='2',
    color='orange',
    displayText='down'
  ).addValueMapping(
    value='3',
    color='orange',
    displayText='testing'
  ).addValueMapping(
    value='4',
    color='orange',
    displayText='unknown'
  ).addValueMapping(
    value='5',
    color='orange',
    displayText='dormant'
  ).addValueMapping(
    value='6',
    color='orange',
    displayText='notPresent'
  ).addValueMapping(
    value='7',
    color='orange',
    displayText='lowerLayerDown'
  ),
  gridPos={ x: 3, y: 0, w: 3, h: 3 }
).addPanel(
  grafana.statPanel.new(
    'Last Change',
    colorMode='thresholds',
    sparkLines=false,
    unit='timeticks'
  ).addTarget(
    grafana.prometheus.target(
      'sysUpTime{instance="$instance"} - on(instance) ifLastChange{instance="$instance",ifDescr="$interface"}',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ).addThreshold(
    color='red',
  ).addThreshold(
    color='orange',
    value=360000
  ).addThreshold(
    color='green',
    value=8640000
  ),
  gridPos={ x: 6, y: 0, w: 3, h: 3 }
).addPanel(
  grafana.statPanel.new(
    'Connector Present',
    colorMode='fixed',
    sparkLines=false
  ).addTarget(
    grafana.prometheus.target(
      'ifConnectorPresent{instance="$instance",ifDescr="$interface"}',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ).addValueMapping(
    value='1',
    color='green',
    displayText='true'
  ).addValueMapping(
    value='2',
    color='orange',
    displayText='false'
  ),
  gridPos={ x: 9, y: 0, w: 3, h: 3 }
).addPanel(
  grafana.statPanel.new(
    'Promiscuous Mode',
    colorMode='fixed',
    sparkLines=false
  ).addTarget(
    grafana.prometheus.target(
      'ifPromiscuousMode{instance="$instance",ifDescr="$interface"}',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ).addValueMapping(
    value='1',
    color='orange',
    displayText='true'
  ).addValueMapping(
    value='2',
    color='green',
    displayText='false'
  ),
  gridPos={ x: 12, y: 0, w: 2, h: 3 }
).addPanel(
  grafana.statPanel.new(
    'Speed',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false,
    unit='bps'
  ).addTarget(
    grafana.prometheus.target(
      'ifHighSpeed{instance="$instance",ifDescr="$interface"}*1000000 or ifSpeed{instance="$instance",ifDescr="$interface"}',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ).addValueMapping(
    value='0',
    displayText='N/A'
  ),
  gridPos={ x: 14, y: 0, w: 2, h: 3 }
).addPanel(
  grafana.statPanel.new(
    'MTU',
    colorMode='fixed',
    fixedColor='text',
    sparkLines=false
  ).addTarget(
    grafana.prometheus.target(
      'ifMtu{instance="$instance",ifDescr="$interface"}',
      datasource=datasourceToUse,
      intervalFactor=null,
      instant=true
    )
  ),
  gridPos={ x: 16, y: 0, w: 2, h: 3 }
).addPanel(
  grafana.tablePanel.new(
    ''
  ).addTarget(
    grafana.prometheus.target(
      'ifType_info{instance="$instance",ifDescr="$interface"}',
      datasource=datasourceToUse,
      format='table',
      intervalFactor=null,
      instant=true
    )
  ).addTransformation(
    grafana.transformation.new(
      id='organize',
      options={
        excludeByName: {
          Time: true,
          __name__: true,
          ifIndex: true,
          ifDescr: true,
          instance: true,
          job: true,
          Value: true,
        },
        indexByName: {},
        renameByName: {},
      }
    )
  ),
  gridPos={ x: 18, y: 0, w: 6, h: 3 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Traffic',
    legendMode='hidden',
    tooltip='all',
    unit='bps'
  ).addTarget(
    grafana.prometheus.target(
      '(rate(ifHCInOctets{instance="$instance",ifDescr="$interface"}[$__rate_interval]) or rate(ifInOctets{instance="$instance",ifDescr="$interface"}[$__rate_interval]))*8',
      datasource=datasourceToUse,
      intervalFactor=1,
      legendFormat='IN: {{ifDescr}}'
    )
  ).addTarget(
    grafana.prometheus.target(
      '(rate(ifHCOutOctets{instance="$instance",ifDescr="$interface"}[$__rate_interval]) or rate(ifOutOctets{instance="$instance",ifDescr="$interface"}[$__rate_interval]))*8',
      datasource=datasourceToUse,
      intervalFactor=1,
      legendFormat='OUT: {{ifDescr}}'
    )
  ),
  gridPos={ x: 0, y: 3, w: 12, h: 9 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Broadcast Packets',
    legendMode='hidden',
    tooltip='all',
    unit='pps'
  ).addTarget(
    grafana.prometheus.target(
      '(rate(ifHCInBroadcastPkts{instance="$instance",ifDescr="$interface"}[$__rate_interval]) or rate(ifInBroadcastPkts{instance="$instance",ifDescr="$interface"}[$__rate_interval]))',
      datasource=datasourceToUse,
      intervalFactor=1,
      legendFormat='IN: {{ifDescr}}'
    )
  ).addTarget(
    grafana.prometheus.target(
      '(rate(ifHCOutBroadcastPkts{instance="$instance",ifDescr="$interface"}[$__rate_interval]) or rate(ifOutBroadcastPkts{instance="$instance",ifDescr="$interface"}[$__rate_interval]))',
      datasource=datasourceToUse,
      intervalFactor=1,
      legendFormat='OUT: {{ifDescr}}'
    )
  ),
  gridPos={ x: 12, y: 3, w: 12, h: 9 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Unicast Packets',
    legendMode='hidden',
    tooltip='all',
    unit='pps'
  ).addTarget(
    grafana.prometheus.target(
      '(rate(ifHCInUcastPkts{instance="$instance",ifDescr="$interface"}[$__rate_interval]) or rate(ifInUcastPkts{instance="$instance",ifDescr="$interface"}[$__rate_interval]))*8',
      datasource=datasourceToUse,
      intervalFactor=1,
      legendFormat='IN: {{ifDescr}}'
    )
  ).addTarget(
    grafana.prometheus.target(
      '(rate(ifHCOutUcastPkts{instance="$instance",ifDescr="$interface"}[$__rate_interval]) or rate(ifOutUcastPkts{instance="$instance",ifDescr="$interface"}[$__rate_interval]))*8',
      datasource=datasourceToUse,
      intervalFactor=1,
      legendFormat='OUT: {{ifDescr}}'
    )
  ),
  gridPos={ x: 0, y: 12, w: 12, h: 9 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Multicast Packets',
    legendMode='hidden',
    tooltip='all',
    unit='pps'
  ).addTarget(
    grafana.prometheus.target(
      '(rate(ifHCInMulticastPkts{instance="$instance",ifDescr="$interface"}[$__rate_interval]) or rate(ifInMulticastPkts{instance="$instance",ifDescr="$interface"}[$__rate_interval]))*8',
      datasource=datasourceToUse,
      intervalFactor=1,
      legendFormat='IN: {{ifDescr}}'
    )
  ).addTarget(
    grafana.prometheus.target(
      '(rate(ifHCOutMulticastPkts{instance="$instance",ifDescr="$interface"}[$__rate_interval]) or rate(ifOutMulticastPkts{instance="$instance",ifDescr="$interface"}[$__rate_interval]))*8',
      datasource=datasourceToUse,
      intervalFactor=1,
      legendFormat='OUT: {{ifDescr}}'
    )
  ),
  gridPos={ x: 12, y: 12, w: 12, h: 9 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Errors',
    legendMode='hidden',
    tooltip='all',
    unit='pps'
  ).addTarget(
    grafana.prometheus.target(
      'rate(ifInErrors{instance="$instance",ifDescr="$interface"}[$__rate_interval])',
      datasource=datasourceToUse,
      intervalFactor=1,
      legendFormat='IN: {{ifDescr}}'
    )
  ).addTarget(
    grafana.prometheus.target(
      'rate(ifOutErrors{instance="$instance",ifDescr="$interface"}[$__rate_interval])',
      datasource=datasourceToUse,
      intervalFactor=1,
      legendFormat='OUT: {{ifDescr}}'
    )
  ),
  gridPos={ x: 0, y: 21, w: 12, h: 9 }
).addPanel(
  grafana.timeseriesPanel.new(
    'Discards',
    legendMode='hidden',
    tooltip='all',
    unit='pps'
  ).addTarget(
    grafana.prometheus.target(
      'rate(ifInDiscards{instance="$instance",ifDescr="$interface"}[$__rate_interval])',
      datasource=datasourceToUse,
      intervalFactor=1,
      legendFormat='IN discards: {{ifDescr}}'
    )
  ).addTarget(
    grafana.prometheus.target(
      'rate(ifInUnknownProtos{instance="$instance",ifDescr="$interface"}[$__rate_interval])',
      datasource=datasourceToUse,
      intervalFactor=1,
      legendFormat='IN unknown protos: {{ifDescr}}'
    )
  ).addTarget(
    grafana.prometheus.target(
      'rate(ifOutDiscards{instance="$instance",ifDescr="$interface"}[$__rate_interval])',
      datasource=datasourceToUse,
      intervalFactor=1,
      legendFormat='OUT discards: {{ifDescr}}'
    )
  ),
  gridPos={ x: 12, y: 21, w: 12, h: 9 }
)
