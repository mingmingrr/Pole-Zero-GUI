require! 'prelude-ls': {map, zip, zip-with, zip-all, drop, apply, and-list, find-index, elem-index}

export trace = ->
	console.log ...
	return &[*-1]

export trace-json = ->
	console.log ...(map JSON.stringify, &)
	return &[*-1]

export find-edit = (eq, a, b) -->
	return null if 1 < Math.abs a.length - b.length
	idx = elem-index false, zip-with eq, a, b
	return undefined unless a.length != b.length or idx?
	idx ?= Math.min a.length, b.length
	mode = switch a.length - b.length
	| 1  => \deletion
	| 0  => \substitution
	| -1 => \insertion
	diff = (Math.min a.length, b.length) - idx - (a.length == b.length)
	return null unless and-list zip-with eq,
		a[a.length - diff til], b[b.length - diff til]
	return [idx, mode]

export raise = (key, value=eval(key), log=false) !->
	window[key] = value
	console.log value if log

export list = ->
	&[til]

export enumerate = ->
	zip [0 til it.length], it

export enumerate-with = (f, a) -->
	zip-with f, [0 til a.length], a

export peek = (n, a) -->
	[a] * n
	|> enumerate-with do
		-> drop &0, &1
	|> apply zip-all

