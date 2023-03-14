{
  /**
   * Creates a [state timeline panel](https://grafana.com/docs/grafana/next/visualizations/state-timeline/).
   * It requires the state timeline panel plugin in grafana, which is build-in.
   *
   * @name stateTimelinePanel.new
   *
   * @param title The title of the graph panel.
   * @param description (optional) The description of the panel.
   * @param transparent (default `false`) Whether to display the panel without a background.
   * @param displayName (optional) Override the series or field name.
   * @param colorMode (default `'palette-classic'`) The color mode to use.
   * @param colorBy (default `'last'`) How to determine the color to use. `'last'`, `'min'`, or `'max'`.
   * @param fixedColor (optional) The color to use when `colorMode` is `'fixed'`.
   * @param thresholdMode (default `'absolute'`) Whether thresholds are absolute or a percentage. `'absolute'` or `'percentage'`.
   * @param legendMode (default `list`) How to display (or not) the legend. `'list`', `'table'`, or `'hidden`'.
   * @param legendPlacement (default `bottom`) Where to display the legend. `'bottom`' or `'right'`.
   * @param legendValues (default `[]`) A list of values to calculate and display in the legend. Options are: `'lastNotNull'`, `'last'`, `'firstNotNull'`, `'first'`, `'min'`, `'max'`, `'mean'`, `'sum'`, `'count'`, `'range'`, `'delta'`, `'step'`, `'diff'`, `'logmin'`, `'allIsZero'`, `'allIsNull'`, `'changeCount'`, `'distinctCount'`, `'diffperc'`, `'allValues'`, `'uniqueValues'`.
   * @param lineWidth (default `1`) The thickness of the line to draw when `graphStyle` is `'line'` or `'bars'`.
   * @param connectNullValues (default `false`) When graphStyle` is `'line'`, whether to connect null values or not. Can also specify a number of seconds beyond which points will not be connected. `true`, `false`, `<number of seconds>`.
   * @param fillOpacity (default `0`) The opacity to fill the area beneath the graph when `graphStyle` is `'line'` or `'bars'`.
   * @param tooltip (default `'single'`) The tooltip mode, `'single'`, `'all'`, or `'hidden'`.
   * @param tooltipSort (default `'none'`) Value sort order when tooltip mode is `'all'`. `'none'`, `'ascending'`, or `'descending'`.
   * @param links (optional) Array of links for the panel.
   * @param showValue (default `'auto'`) Should the values be shown. Options are: `'auto'`, `'never'`, `'always'`
   *
   * @method addTarget(target) Adds a target object.
   * @method addTargets(targets) Adds an array of targets.
   * @method addLink(link) Add a link to the panel.
   * @method addLinks(links) Adds an array of links to the panel.
   * @method addThreshold(color, value=null) Adds a threshold.
   */
  new(
    title,
    description=null,
    transparent=false,
    displayName=null,
    colorMode='palette-classic',
    fixedColor=null,
    colorBy='last',
    thresholdMode='absolute',
    legendMode='list',
    legendPlacement='bottom',
    legendValues=[],
    lineWidth=1,
    connectNullValues=false,
    fillOpacity=0,
    tooltip='single',
    tooltipSort=null,
    links=[],
    showValue='auto'
  ):: {
    type: 'state-timeline',
    title: title,
    [if description != null then 'description']: description,
    [if transparent then 'transparent']: transparent,
    fieldConfig: {
      defaults: {
        custom: {
          fillOpacity: fillOpacity,
          lineWidth: lineWidth,
          spanNulls: connectNullValues,
        },
        mappings: [],
        thresholds: {
          mode: thresholdMode,
          steps: [],
        },
        color: {
          mode: colorMode,
          [if colorMode == 'fixed' && fixedColor != null then 'fixedColor']: fixedColor,
          [if colorBy != 'last' then 'seriesBy']: colorBy,
        },
        [if displayName != null then 'displayName']: displayName,
      },
      overrides: [],
    },
    links: links,
    options: {
      legend: {
        calcs: legendValues,
        displayMode: legendMode,
        placement: legendPlacement,
      },
      tooltip: {
        mode: { single: 'single', all: 'multi', hidden: 'none' }[tooltip],
        sort: if tooltip == 'all' && tooltipSort != null
        then { ascending: 'asc', descending: 'desc' }[tooltipSort]
        else 'none',
      },
      showValue: showValue,
    },
    targets: [],
    _nextTarget:: 0,
    addThreshold(color, value=null):: self {
      fieldConfig+: { defaults+: { thresholds+: { steps+: [{ color: color, value: value }] } } },
    },
    addLink(link):: self {
      links+: [link],
    },
    addLinks(links):: std.foldl(function(p, t) p.addLink(t), links, self),
    addTarget(target):: self {
      // automatically ref id in added targets.
      // https://github.com/kausalco/public/blob/master/klumps/grafana.libsonnet
      local nextTarget = super._nextTarget,
      _nextTarget: nextTarget + 1,
      targets+: [target { refId: std.char(std.codepoint('A') + nextTarget) }],
    },
    addTargets(targets):: std.foldl(function(p, t) p.addTarget(t), targets, self),
  },
}
