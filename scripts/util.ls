require! 'prelude-ls': {zip, zipWith}

export raise = (n, log=false) ->
	window[n] = eval(n)
	console.log eval(n) if log

export trace = ->
	console.log it
	return it

export enumerate = ->
	zip [0 til it.length], it

export enumerate-with = (f, a) -->
	zip-with f, [0 til a.length], a

