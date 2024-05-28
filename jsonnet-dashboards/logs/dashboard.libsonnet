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

local logslib = import 'github.com/grafana/jsonnet-libs/logs-lib/logs/main.libsonnet';

local grafonnet = import '../g.libsonnet';

local containerLogsFilename = 'logs-container.json';
local containerLogsFilterSelector = 'container!=""';
local containerLogsLabels = ['cluster', 'namespace', 'job', 'container'];
local containerLogsFormatParser = 'logfmt';
local containerLogs = logslib.new('Logs / Container',
                                  datasourceRegex='',
                                  filterSelector=containerLogsFilterSelector,
                                  labels=containerLogsLabels,
                                  formatParser=containerLogsFormatParser)
                      {
  dashboards+:
    {
      logs+:
        grafonnet.dashboard.withUid(std.md5(containerLogsFilename)),
    },
};

local journalLogsFilename = 'logs-journal.json';
local journalLogsFilterSelector = 'unit!=""';
local journalLogsLabels = ['cluster', 'namespace', 'host', 'unit'];
local journalLogsFormatParser = 'logfmt';
local journalLogs = logslib.new('Logs / Journal',
                                datasourceRegex='',
                                filterSelector=journalLogsFilterSelector,
                                labels=journalLogsLabels,
                                formatParser=journalLogsFormatParser,
                                showLogsVolume=true)
                    {
  dashboards+:
    {
      logs+:
        grafonnet.dashboard.withUid(std.md5(journalLogsFilename)),
    },
};

{
  [containerLogsFilename]: containerLogs.dashboards.logs,
  [journalLogsFilename]: journalLogs.dashboards.logs,
}
