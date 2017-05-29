require! 'prelude-ls': {map}

require! './numeric.js': {is-zero}

export Complex = (a, b = 0) ->
	if Array.isArray a
	then a else [a, b]

export const one = [1, 0]

export const zero = [0, 0]

export const i = [0, 1]

export const j = [0, 1]

export const e = [Math.E, 0]

export const pi = [Math.PI, 0]

export real = (.0)

export imag = (.1)

export is-real = imag >> is-zero

export to-string = ([x, y], prec=5) ->
	[a, b] = map is-zero, [x, y]
	[x, y] = map do
		(num) ->
			str = num.to-string!
			switch
			| 'e' in str => num.to-exponential prec
			| '.' in str => num.to-fixed prec
			| otherwise  => str
		[x, y]
	switch
	| a and b => '0'
	| b => "#{x}"
	| a => "#{y} i"
	| y < 0 => "#{x} #{y} i"
	| otherwise => "#{x} +#{y} i"

export negate = ([x, y]) ->
	[-x, -y]

export abs = ([x, y]) ->
	Math.sqrt x^2 + y^2

export abs2 = ([x, y]) ->
	x^2 + y^2

export angle = ([x, y]) ->
	Math.atan2 y, x

export conj = ([x, y]) ->
	[x, -y]

export pair = ->
	if is-real it
		then [it]
		else [it, conj it]

export top = ->
	switch
	| is-zero it.1 => it
	| it.1 > 0 => it
	| otherwise => [it.0, -it.1]

export polar = (x) ->
	[(abs x), (angle x)]

export rect = ([r, t]) ->
	[(r * Math.cos t), (r * Math.sin t)]

export add = ([x1, y1], [x2, y2]) -->
	[x1 + x2, y1 + y2]

export sub = ([x1, y1], [x2, y2]) -->
	[x1 - x2, y1 - y2]

export mul = ([x1, y1], [x2, y2]) -->
	[x1*x2 - y1*y2, x2*y1 + x1*y2]

export div = ([x1, y1], [x2, y2]) -->
	sq = x2^2 + y2^2
	[(x1*x2 + y1*y2) / sq, (x2*y1 - x1*y2) / sq]

export pow = ([x1, y1], [x2, y2]) -->
	[z1, z2] = [(is-zero y1), (is-zero y2)]
	switch
	| z1 and z2 => [x1 ^ x2, 0]
	| z1 => rect [x1 ^ x2, y2 * Math.log x1]
	| z2 => 
		[r, t] = polar [x1, y1]
		rect [r^x2, t*x2]
	| _ =>
		t = angle [x1, y1]
		mul (pow [x1*x1 + y1*y1, 0], [x2/2, y2/2]), (pow e, [-y2*t, x2*t])

export exp = pow e

export iexp = -> rect [1, it]

