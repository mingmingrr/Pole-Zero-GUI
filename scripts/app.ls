require! d3
require! 'prelude-ls': {flip, map, each, zip-with, concat-map, apply, take}

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
(flip each) (document.get-elements-by-class-name \draggable), (element) ->
	[target, x-diff, y-diff, x-lim, y-lim] = [null, 0, 0, 0, 0]

	mousemove = (event) !->
		target.style.left = (0 >? event.client-x - x-diff <? x-lim) + \px
		target.style.top  = (0 >? event.client-y - y-diff <? y-lim) + \px

	element.add-event-listener \mousedown, (event) !->
		target := if element.dragtarget?
			then element.dragtarget else element
		[target-style, parent-style] = map do
			get-computed-style
			[target, target.parent-element]
		[x-diff, y-diff] := # TODO use offset-x and offset-y
			(parse-int event.client-x) - (parse-int target-style.left)
			(parse-int event.client-y) - (parse-int target-style.top)
		[x-lim, y-lim] :=
			(parse-int parent-style.width) - (parse-int target-style.width)
			(parse-int parent-style.height) - (parse-int target-style.height)
		element.style.cursor = \move
		document.add-event-listener \mousemove, mousemove

	element.add-event-listener \mouseup, (event) !->
		element.style.cursor = \default
		document.remove-event-listener \mousemove, mousemove

/*------------------
Handling scalables
------------------*/
(flip each) (document.get-elements-by-class-name \scalable), (element) ->
	corner = document.create-element \div
	corner.class-list.add \scalable-corner
	element.append-child corner

	[x-diff, y-diff, x-lim, y-lim] = [0, 0, 0, 0]

	mousemove = (event) !->
		[x, y] =
			(0 >? event.client-x - x-diff <? x-lim)
			(0 >? event.client-y - y-diff <? y-lim)
		element.style.width  = x + \px
		element.style.height = y + \px

	corner.add-event-listener \mousedown, (event) !->
		event.stop-propagation!
		[corner-rect, element-rect, parent-rect] = map do
			(.get-bounding-client-rect!)
			[corner, element, element.parent-element]
		[x-diff, y-diff] :=
			(parse-int element-rect.left) - (parse-int parent-rect.left) - do
				(parse-int corner-rect.width) - (parse-int event.layer-x)
			(parse-int element-rect.top) - (parse-int parent-rect.top) - do
				(parse-int corner-rect.height) - (parse-int event.layer-y)
		[x-lim, y-lim] :=
			(parse-int parent-rect.width) - (parse-int element-rect.left)
			(parse-int parent-rect.height) - (parse-int element-rect.top)
		document.add-event-listener \mousemove, mousemove

	corner.add-event-listener \mouseup, (event) !->
		document.remove-event-listener \mousemove, mousemove

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

