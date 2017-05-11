require! d3
require! 'prelude-ls': {map, each, zip-with, concat-map, apply, take}

require! './complex.js': Complex
require! './numeric.js': Numeric
require! './fft.js': {fft: fft}
require! './util.js': {enumerate, trace}

raise = (n, log=false) ->
	window[n] = eval(n)
	console.log eval(n) if log
raise \d3

/*------------------
Handling draggables
------------------*/
each do
	(element) ->
		[x-diff, y-diff, x-lim, y-lim] = [0, 0, 0, 0]
		mousemove = (event) !->
			element.style.left = (0 >? event.client-x - x-diff <? x-lim) + \px
			element.style.top  = (0 >? event.client-y - y-diff <? y-lim) + \px

		element.add-event-listener \mousedown, (event) !->
			[element-style, parent-style] = map do
				get-computed-style
				[element, element.parent-element]
			[x-diff, y-diff] :=
				(parse-int event.client-x) - (parse-int element-style.left)
				(parse-int event.client-y) - (parse-int element-style.top)
			[x-lim, y-lim] :=
				(parse-int parent-style.width) - (parse-int element-style.width)
				(parse-int parent-style.height) - (parse-int element-style.height)
			element.style.cursor = \move
			document.add-event-listener \mousemove, mousemove

		element.add-event-listener \mouseup, (event) !->
			element.style.cursor = \default
			document.remove-event-listener \mousemove, mousemove

	document.get-elements-by-class-name \draggable

/*------------------
Frequency response config
------------------*/
config =
	poles      : []
	zeros      : []
	scale      : 'linear'
	resolution : 64

scales =
	linear      : d3.scale-linear
	logarithmic : d3.scale-log

graph =
	svg : d3 .select \svg
	x   : d3 .scale-linear! .domain [0, Math.PI / 2]
	xi  : (* (Math.PI / config.resolution))
	y   : null
Object.assign graph, do
	g : graph.svg .append \g .classed \plot, true
Object.assign graph, do
	x-axis : graph.g .append \g .classed \x-axis, true
	y-axis : graph.g .append \g .classed \y-axis, true
	path   : graph.g .append \path .classed \line, true

/*------------------
Frequency response handling
------------------*/
do rescale = !->
	graph.y = scales[config.scale]!

do resize = !->
	style = get-computed-style graph.svg.node!
	px = -> parse-int style[it]
	graph.x .range [0, (px \width)]
	graph.y .range [(px \height), 0]

poly-fft = (concat-map Complex.pair)
	>> (Numeric.to-polynomial)
	>> (fft config.resolution)
	>> (-> take (it.length / 2 + 1), it)

do recalc = !->
	graph.data = [config.zeros, config.poles]
		|> map poly-fft
		|> apply (zip-with Complex.div)
		|> map Complex.abs
		|> enumerate

do redraw = !->
	graph.y .domain [0, d3.max graph.data, (.1)]
	graph.x-axis .call d3.axis-bottom graph.x
	graph.y-axis .call d3.axis-left graph.y
	graph.line = d3 .line!
		.x ((.0) >> graph.xi >> graph.x)
		.y ((.1) >> graph.y)
	graph.path .datum graph.data .attr \d, graph.line

add-event-listener 'resize', !->
	resize!
	redraw!

