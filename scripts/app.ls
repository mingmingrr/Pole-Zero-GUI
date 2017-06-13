require! d3
require! 'prelude-ls' : Prelude
window <<<< Prelude

require! './complex.js' : Complex
require! './numeric.js' : Numeric
require! './fft.js' : {fft}
require! './evaluate.js' : {evaluate}
require! './util.js' : {enumerate, trace, trace-json, raise, find-edit}

require! './draggable.js'
require! './scalable.js'
require! './slide-container.js'
require! './list-input.js' : ListInput
require! './onresize.js' : {attach-resize-listener}

raise \d3, d3

config =
	poles      : []
	zeros      : []
	scale      : \linear
	frequency  : Math.PI
	gain       : 1
	resolution : 256

list-inputs =
	poles : document.query-selector '#poles .list-input'
	zeros : document.query-selector '#zeros .list-input'

for let _, list of list-inputs
	ListInput.attach-validator list, (value) ->
		return if value == ''
		try
			result = evaluate value
			return
				value   : result
				content : value
		catch
			return null

sync-darts = !->
	for let type, list of list-inputs
		list.query-selector-all ':scope > li'
		|> map (.remove!)
		temp = config[type]
		config[type]
		|> map Complex.to-string
		|> each (!-> ListInput.append-item list, it)
		ListInput.append-item list
		config[type] = temp # wtf?!

get-dimensions = (node) ->
	style = window.get-computed-style node
	property = -> parse-float style.get-property-value it
	return do
		width: property \width
		height: property \height

min-index-by = (func, list) -->
	elem-index (minimum-by func, list), list

closest-index-to = (num, list) -->
	num = Complex.top num
	min-index-by do
		Complex.top
		>> Complex.polar
		>> (Complex.sub num)
		>> Complex.abs2
		list

/*-------------------
Pole zero plot config
-------------------*/
darts =
	svg : d3 .select \svg#darts
	r   : d3 .scale-linear! .domain [0, 1.2]
<<<<
	g  : darts.svg .append \g
	line : d3 .radial-line! .radius ((.0) >> darts.r)
		.angle ((.1) >> negate >> (+ (Math.PI / 2)))
<<<<
	r-axis : darts.g .append \g .classed \r-axis, true
	t-axis : (darts.g .append \g .classed \t-axis, true
		..select-all \g .data d3.range 0, 360, 30 .enter!
			.append \line .style \transform, (-> "rotate(#{it}deg)"))
	zeros : darts.g .append \g .classed \zeros, true
	poles : darts.g .append \g .classed \poles, true
	cross : '0 2.8,3 5,5 3,2.8 0,5 -3,3 -5,0 -2.8,-3 -5,-5 -3,-2.8 0,-5 3,-3 5'
<<<<
	drag : (type) ->
		d3.drag!
		.on \start, (data) !->
			idx = closest-index-to data, config[type]
			[config.[type].0, config[type][idx]] =
				[config[type][idx], config[type].0]
		.on \drag, (data) !->
			{x, y} = d3.event
			config.[type].0 =
				map darts.r.invert, [x, y]
			sync-darts!
			recalc-cascade!
	click : (type, flip=false) -> (data) !->
		d3.event.prevent-default!
		d3.event.stop-propagation!
		popped = config[type].splice do
			closest-index-to data, config[type]
			1
		if flip
			if type == \poles
				then config.zeros.push popped.0
				else config.poles.push popped.0
		sync-darts!
		recalc-cascade!
raise \darts, darts

/*------------------
Add a new zero with right click
------------------*/
darts.svg.on \contextmenu, !->
	d3.event.prevent-default!
	{width, height} = get-dimensions document.get-element-by-id \darts
	{layer-x: x, layer-y: y} = d3.event
	[x, y] = map darts.r.invert, [(x - width / 2 - 10), (y - height / 2 - 10)]
	config.zeros.push [x, y]
	sync-darts!
	recalc-cascade!

/*-------------------
Pole zero plot handling
-------------------*/
do darts.resize = !->
	{width, height} = get-dimensions document.get-element-by-id \darts
	darts.g .style \transform, "translate(#{width/2}px,#{height/2}px)"
	darts.r .range [0, (Math.min width, height)/2]

do darts.rescale = !->
	darts.r-axis .select-all \circle .remove!
	darts.r-axis .select-all \text .remove!
	darts.r-axis .select-all \g
		.data darts.r.ticks!.filter(-> &1 % 2 == 0 and &0 != 1)[1 til] .enter!
			..append \circle .classed \scale, true
			..append \text .classed \scale, true
	darts.r-axis .append \circle .classed \unit, true
	darts.r-axis .append \text .classed \unit, true .data [1]

do darts.recalc = !->
	marks =
		zeros : [\circle, id]
		poles : [\polygon, (.attr \points, darts.cross)]
	for type, shape of marks
		darts[type] .select-all shape.0 .remove!
		darts[type] .select-all \g
		.data map Complex.polar, do
			concat-map Complex.pair, config[type]
		.enter! .append shape.0
		|> shape.1 |> ->
			it.call darts.drag type
			.on \contextmenu, darts.click type, false
			.on \dblclick, darts.click type, true

do darts.reaxis = !->
	darts.r-axis .select-all \circle.scale
		.attr \r, darts.r
	darts.r-axis .select-all \text
		.attr \y, (darts.r >> (+ 1) >> negate) .text id
	darts.r-axis .select \circle.unit
		.attr \r, darts.r 1
	let radius = darts.r.range!.1
		darts.t-axis .select-all \line
			.attr \x2, radius

do darts.redraw = !->
	translate = (data) ->
		p = darts.line [data] .slice 1, -1 .split ','
		"translate(#{p.0}px,#{p.1}px)"
	darts.zeros .select-all \circle
		.style \transform, translate
	darts.poles .select-all \polygon
		.style \transform, translate

let darts-parent = darts.svg.node!.parent-element
	attach-resize-listener darts-parent
	darts-parent.add-event-listener \resize, !->
		darts.resize!
		darts.reaxis!
		darts.redraw!

/*------------------
Frequency response config
------------------*/
score =
	svg : d3 .select \svg#score
	x   : d3 .scale-linear!
	xi  : (* (2 * config.frequency / config.resolution))
	y   : null
<<<<
	g : score.svg .append \g
<<<<
	x-axis : score.g .append \g .classed \x-axis, true
	y-axis : score.g .append \g .classed \y-axis, true
	path   : score.g .append \path .classed \line, true
raise \score, score

/*------------------
Frequency response handling
------------------*/
do score.rescale = !->
	scales =
		linear      : -> d3.scale-linear!
		logarithmic : -> d3.scale-log!.base 10
	score.x .domain [0, config.frequency]
	score.y = scales[config.scale]!

do score.resize = !->
	{width, height} = get-dimensions score.svg.node!
	score.x .range [0, width]
	score.y .range [height, 0]
	score.x-axis .style \transform, "translateY(#{height}px)"

do score.recalc = !->
	score.data = [config.zeros, config.poles]
		|> map (concat-map Complex.pair)
			>> (Numeric.to-polynomial)
			>> (fft config.resolution)
			>> (-> take (it.length / 2 + 1), it)
		|> apply (zip-with Complex.div)
		|> map (Complex.abs >> (* config.gain))
		|> enumerate
		|> filter (-> it.1? and not is-it-NaN it.1)
	if config.scale == \logarithmic
		score.data = score.data
			|> filter (-> it.1 > 1e-5)

do score.redraw = !->
	{width, height} = get-dimensions score.svg.node!
	[min, max] = d3.extent score.data, (.1)
	min := 0 unless config.scale == \logarithmic
	score.y .domain [min, max]
	score.x-axis .call <| d3.axis-bottom score.x .tick-size-inner (-height)
	score.y-axis .call <| d3.axis-left score.y   .tick-size-inner (-width)

do score.replot = !->
	score.path .datum score.data .attr \d, do
		d3 .line!
			.x ((.0) >> score.xi >> score.x)
			.y ((.1) >> score.y)

let score-parent = score.svg.node!.parent-element
	attach-resize-listener score-parent
	score-parent.add-event-listener 'resize', !->
		score.resize!
		score.redraw!
		score.replot!

/*------------------
P/Z list change handling
------------------*/
recalc-cascade = !->
	darts
		..recalc!
		..reaxis!
		..redraw!
	score
		..recalc!
		..redraw!
		..replot!

rescale-cascade = !->
	darts
		..resize!
		..recalc!
	score
		..rescale!
		..resize!
		..recalc!
		..redraw!
		..replot!

for let type, list of list-inputs
	list.add-event-listener \change, (event) !->
		config[type] := list.get-elements-by-tag-name \li
			|> map (JSON.parse << (.get-attribute \value))
			|> compact
		recalc-cascade!

/*------------------
Options handling
------------------*/
options = document.get-element-by-id \options

let input = options.query-selector "input[name='resolution']"
	input.value = config.resolution
	listener = (event) !->
		value = input.value |> parse-int
		round = value |> Math.log2 |> Math.round
		diff = round |> (2 ^) |> (value -)
		input.value = Math.min 4096, (round |> (+ (signum diff)) |> (2 ^))
		config.resolution := input.value
		recalc-cascade!
	input.add-event-listener \change, listener
	input.add-event-listener \click, listener

let input = options.query-selector "input[name='gain']"
	input.value = config.gain
	input.add-event-listener \change, (event) !->
		config.gain := parse-float input.value
		recalc-cascade!

let input = options.query-selector "input[name='frequency']"
	input.value = config.frequency
	input.add-event-listener \change, (event) !->
		config.frequency := parse-float input.value
		rescale-cascade!

options.query-selector-all "input[name='axis']"
|> each (input) !->
	input.add-event-listener \click, (event) !->
		config.scale := input.value
		rescale-cascade!

/*------------------
Import export handling
------------------*/
let textarea = options.query-selector "textarea[name='export']"
	textarea.add-event-listener \click, (event) ->
		[a, b] = [config.poles, config.zeros]
			|> map do
				(concat-map Complex.pair)
				>> Numeric.to-polynomial
				>> reverse
				>> (map Complex.to-string)
				>> (.join ', ')
		[poles, zeros] = [config.poles, config.zeros]
			|> map do
				(concat-map Complex.pair)
				>> (map Complex.to-string)
				>> (.join ', ')
		textarea.value =
			"B = [#b]\nA = [#a]\nzeros = [#zeros]\npoles = [#poles]"

let textarea = options.query-selector "textarea[name='import']"
	textarea.add-event-listener \change, (event) !->
		[poles, zeros] = [null, null]
		try
			[poles, zeros] :=
				[/poles?\s*=\s*\[(.*?)\]/mi,
				/zeros?\s*=\s*\[(.*?)\]/mi]
				|> map do
					(.exec textarea.value)
					>> (.1) >> (/ ',')
					>> (filter (!= ''))
					>> (map evaluate)
		catch
			alert e
			return
		[config.poles, config.zeros] = [poles, zeros]
		sync-darts!
		recalc-cascade!

