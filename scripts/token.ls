require! 'prelude-ls': {map, concat-map, pairs-to-obj, obj-to-pairs, apply}

require! './complex.js': Complex
require! './util.js': {trace}

export class Token

export class Number extends Token
	(value) ->
		@value = Complex.Complex value

export class Constant extends Number
	-> super ...

export constants =
	pi : new Constant Complex.pi
	e  : new Constant Complex.e
	j  : new Constant Complex.i
	i  : new Constant Complex.j

export class Bracket extends Token
	(@val, @comp) ->

export class LeftBracket extends Bracket
	-> super ...

export class RightBracket extends Bracket
	-> super ...

export brackets = do
	<[() [] {}]>
	|> concat-map (-> [it, it .split '' .reverse! .join ''])
	|> map (-> [it.0, new Bracket it.0, it.1])
	|> pairs-to-obj

export left-brackets = do
	<[( [ {]>
	|> map (-> [it, new LeftBracket it, brackets[it].comp])
	|> pairs-to-obj

export right-brackets = do
	<[) ] }]>
	|> map (-> [it, new RightBracket it, brackets[it].comp])
	|> pairs-to-obj

export class Operator extends Token
	(@op, @prec, @fix) ->

export operators =
	'+' : new Operator Complex.add, 1, 'l'
	'-' : new Operator Complex.sub, 1, 'l'
	'*' : new Operator Complex.mul, 2, 'l'
	'/' : new Operator Complex.div, 2, 'l'
	'^' : new Operator Complex.pow, 3, 'r'

export class Separator extends Token
	(@type) ->

export separators =
	',' : new Separator ','

export class Function extends Token
	(@func) ->

export class RealFunction extends Function
	(func) ->
		@func = (...args) ->
			for arg in args
				unless Complex.is-real arg
					throw new Error 'complex argument to real function'
			apply func, map Complex.real, args

export functions =
	sin  : new RealFunction Math.sin
	cos  : new RealFunction Math.cos
	tan  : new RealFunction Math.tan
	asin : new RealFunction Math.asin
	acos : new RealFunction Math.acos
	atan : new RealFunction Math.atan
	log  : new RealFunction Math.log10
	ln   : new RealFunction Math.log
	sqrt : new Function (Complex.pow _, [0.5, 0])
	exp  : new Function Complex.exp

