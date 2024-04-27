/*
 * Copyright 2024 Ashley Lavery
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

local util = import '../dashboard-utils.libsonnet';
local grafonnet = import '../g.libsonnet';

local queries = import './queries.libsonnet';

local dashboard = grafonnet.dashboard;
local gauge = grafonnet.panel.gauge;
local stat = grafonnet.panel.stat;
local stateTimeline = grafonnet.panel.stateTimeline;
local timeSeries = grafonnet.panel.timeSeries;

{
  'ups-overview.json': (
    util.dashboard('UPS Overview', tags=['generated', 'ups'])
    + util.addVariable('cluster', 'ups_state', 'cluster')
    + util.addVariable('host', 'ups_state{cluster="$cluster"}', 'host')
    + dashboard.withPanels(
      util.makeGrid([
        util.stat.base('UPS State', queries.upsStateNow, height=5)
        + stat.options.withGraphMode('none')
        + stat.standardOptions.withMappings([
          stat.valueMapping.ValueMap.withOptions({
            '0': {
              color: 'red',
              text: 'Not Normal',
            },
            '1': {
              color: 'green',
              text: 'Normal',
            },
          })
          + stat.valueMapping.ValueMap.withType('value'),
        ])
        + stat.standardOptions.color.withFixedColor('text'),

        util.gauge.base('Battery Capacity', queries.batteryCapacityNow, height=5, width=6)
        + gauge.standardOptions.withUnit('percent')
        + gauge.standardOptions.color.withMode('thresholds')
        + gauge.standardOptions.thresholds.withMode('absolute')
        + gauge.standardOptions.thresholds.withSteps([
          gauge.thresholdStep.withColor('red')
          + gauge.thresholdStep.withValue(null),
          gauge.thresholdStep.withColor('orange')
          + gauge.thresholdStep.withValue(50),
          gauge.thresholdStep.withColor('green')
          + gauge.thresholdStep.withValue(80),
        ]),

        util.stat.base('Battery Time Remaining', queries.batteryRemainingNow, height=5)
        + stat.standardOptions.withUnit('m')
        + stat.standardOptions.color.withMode('thresholds')
        + stat.standardOptions.thresholds.withMode('absolute')
        + stat.standardOptions.thresholds.withSteps([
          stat.thresholdStep.withColor('red')
          + stat.thresholdStep.withValue(null),
          stat.thresholdStep.withColor('orange')
          + stat.thresholdStep.withValue(15),
          stat.thresholdStep.withColor('green')
          + stat.thresholdStep.withValue(30),
        ]),

        util.stat.base('UPS Load', queries.upsLoadNow, height=5)
        + stat.standardOptions.withUnit('watt'),

        util.stateTimeline.base('UPS State', queries.upsState, width=6)
        + stateTimeline.options.withShowValue('never')
        + stateTimeline.options.legend.withShowLegend(false)
        + stateTimeline.options.tooltip.withMode('none')
        + stateTimeline.standardOptions.thresholds.withMode('absolute')
        + stateTimeline.standardOptions.thresholds.withSteps([
          stateTimeline.thresholdStep.withColor('red')
          + stateTimeline.thresholdStep.withValue(null),
          stateTimeline.thresholdStep.withColor('green')
          + stateTimeline.thresholdStep.withValue(1),
        ]),

        util.timeSeries.base('Battery Capacity', queries.batteryCapacity, width=6)
        + timeSeries.fieldConfig.defaults.custom.thresholdsStyle.withMode('dashed')
        + timeSeries.standardOptions.withMax(100)
        + timeSeries.standardOptions.withMin(0)
        + timeSeries.standardOptions.withUnit('percent')
        + timeSeries.standardOptions.color.withMode('thresholds')
        + timeSeries.standardOptions.thresholds.withMode('absolute')
        + timeSeries.standardOptions.thresholds.withSteps([
          timeSeries.thresholdStep.withColor('red')
          + timeSeries.thresholdStep.withValue(null),
          timeSeries.thresholdStep.withColor('orange')
          + timeSeries.thresholdStep.withValue(50),
          timeSeries.thresholdStep.withColor('green')
          + timeSeries.thresholdStep.withValue(80),
        ]),

        util.timeSeries.base('Battery Time Remaining', queries.batteryRemaining, width=6)
        + timeSeries.standardOptions.withUnit('m'),

        util.timeSeries.base('UPS Load', queries.upsLoad, width=6)
        + timeSeries.standardOptions.withUnit('watt'),

        util.timeSeries.base('UPS Input Voltage', queries.inputVoltage, width=24)
        + timeSeries.standardOptions.withUnit('volt'),

        util.timeSeries.base('UPS Output Voltage', queries.outputVoltage, width=24)
        + timeSeries.standardOptions.withUnit('volt'),
      ])
    )
  ),
}
