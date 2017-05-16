require! d3
require! 'prelude-ls': {id, negate, map, zip-with, concat-map, apply, take}

require! './complex.js': Complex
require! './numeric.js': Numeric
require! './fft.js': {fft}
require! './util.js': {enumerate, trace, raise}

require! './draggable.js'
require! './scalable.js'
require! './slide-container.js'
require! './onresize.js': {attach-resize-listener}

raise \d3, d3

config =
	poles      : [[0, 0.5]]
	zeros      : [[1, 0], [-3/5, 4/5]]
	scale      : 'linear'
	frequency  : Math.PI
	resolution : 128

/*-------------------
Pole zero plot config
-------------------*/
darts =
	svg : d3 .select \svg#darts
	r   : d3 .scaleLinear! .domain [0, 1.2]
let @ = darts
	@g  = @svg .append \g
let @ = darts
	@r-axis = @g .append \g .classed \r-axis, true
	@t-axis = @g .append \g .classed \t-axis, true
		..select-all \g .data d3.range 0, 360, 30 .enter!
			.append \line .style \transform, (-> "rotate(#{it}deg)")

/*-------------------
Pole zero plot handling
-------------------*/
do darts.resize = !->
	{width, height} = window.get-computed-style darts.svg.node!
	[width, height] = map parse-int, [width, height]
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

# do darts.recalc = !=>


do darts.redraw = !->
	darts.r-axis
		..select-all \circle.scale .attr \r, darts.r
		..select-all \text .attr \y, (darts.r >> (+ 1) >> negate) .text id
	darts.r-axis.select \circle.unit .attr \r, darts.r 1
	darts.t-axis .select-all \line .attr \x2, darts.r.range!.1

let darts-parent = darts.svg.node!.parent-element
	attach-resize-listener darts-parent
	darts-parent.add-event-listener \resize, !->
		darts.resize!
		darts.redraw!

/*------------------
Frequency response config
------------------*/
scales =
	linear      : d3.scale-linear
	logarithmic : d3.scale-log

score =
	svg : d3 .select \svg#score
	x   : d3 .scale-linear!
	xi  : (* (2 * Math.PI / config.resolution))
	y   : null
let @ = score
	@g  = @svg .append \g
let @ = score
	@x-axis = @g .append \g .classed \x-axis, true
	@y-axis = @g .append \g .classed \y-axis, true
	@path   = @g .append \path .classed \line, true

/*------------------
Frequency response handling
------------------*/
do score.rescale = !->
	score.x .domain [0, config.frequency]
	score.y = scales[config.scale]!

do score.resize = !->
	{width, height} = window.get-computed-style score.svg.node!
	[width, height] = map parse-int, [width, height]
	score.x .range [0, width]
	score.y .range [height, 0]
	score.x-axis .style \transform, "translateY(#{height}px)"

poly-fft = (concat-map Complex.pair)
	>> (Numeric.to-polynomial)
	>> (fft config.resolution)
	>> (-> take (it.length / 2 + 1), it)

do score.recalc = !->
	score.data = [config.zeros, config.poles]
		|> map poly-fft
		|> apply (zip-with Complex.div)
		|> map Complex.abs
		|> enumerate

do score.redraw = !->
	score.y .domain [0, d3.max score.data, (.1)]
	score.x-axis .call d3.axis-bottom score.x
	score.y-axis .call d3.axis-left score.y
	score.path .datum score.data .attr do
		\d
		d3 .line!
			.x ((.0) >> score.xi >> score.x)
			.y ((.1) >> score.y)

window.add-event-listener 'resize', !->
	score.resize!
	score.redraw!

