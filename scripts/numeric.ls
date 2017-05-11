require! 'prelude-ls': {fold, last, head, tail, zip-with, map}

require! './complex.js': Complex

const delta = 1e-10

export is-zero = (< delta) . Math.abs

export add-root = (poly, root) -->
	root = Complex.negate Complex.Complex root
	[Complex.mul (head poly), root] ++
		(zip-with (Complex.add), poly, (map (Complex.mul root), (tail poly))) ++
		[last poly]

export to-polynomial = ->
	fold add-root, [Complex.one], it

