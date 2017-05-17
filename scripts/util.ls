require! 'prelude-ls': {zip, zipWith}

export raise = (key, value=eval(key), log=false) !->
	window[key] = value
	console.log value if log

export trace = ->
	console.log it
	return it

export list = ->
	&[til]

export enumerate = ->
	zip [0 til it.length], it

export enumerate-with = (f, a) -->
	zip-with f, [0 til a.length], a

