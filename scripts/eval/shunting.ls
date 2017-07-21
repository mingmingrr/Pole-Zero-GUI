require! 'prelude-ls': {reverse, any}

require! './token.js': Token
require! '../util.js': {trace, list, enumerate, peek}

export multiply = (a, b) -->
	unless a?
		return false
	if a instanceof Token.Number
		[a, b] = [b, a]
	else unless b instanceof Token.Number
		return false
	if a instanceof Token.Number
		and a not instanceof Token.Constant
			return not (b instanceof Token.Number
				and b not instanceof Token.Constant)
	return a instanceof Token.Constant
		or a instanceof Token.Function

export negate = (a, b) -->
	if b != Token.operators.\-
		return false
	return (not a?)
		or a instanceof Token.LeftBracket
		or a instanceof Token.Operator

validations =
	[multiply, Token.operators.\*]
	[negate, new Token.Number 0]

export validate = (tokens) ->
	queue = []
	for [f, op] in validations
		if f null, tokens.0
			queue.push op
	queue.push tokens.0
	for [a, b] in peek 2, tokens
		for [f, op] in validations
			if f a, b
				queue.push op
		queue.push b
	return queue

export clear-stack = (stack, pop=null) ->
	queue = []
	while stack.length
		and stack[*-1] not instanceof Token.LeftBracket
			queue.push stack.pop!
	if stack.length == 0
		or (pop? and stack[*-1].val != pop.comp)
			throw new Error 'mismatched brackets'
	if pop?
		stack.pop!
		if stack.length
			and stack[*-1] instanceof Token.Function
				queue.push stack.pop!
	return queue

export compare-precedence = (a, b) ->
	if a.fix == 'l'
		then a.prec <= b.prec
		else a.prec < b.prec

export shunting = validate >> (tokens) ->
	[stack, queue] = [[], []]
	for token in tokens
		switch
		| token instanceof Token.Number =>
			queue.push token
		| token instanceof Token.Function =>
			stack.push token
		| token instanceof Token.LeftBracket =>
			stack.push token
		| token instanceof Token.Separator =>
			queue ++= clear-stack stack
		| token instanceof Token.RightBracket =>
			queue ++= clear-stack stack, token
		| token instanceof Token.Operator
			while stack.length
				and stack[*-1] instanceof Token.Operator
				and compare-precedence token, stack[*-1]
					queue.push stack.pop!
			stack.push token
	if any (instanceof Token.Bracket), stack
		throw new Error 'mismatched brackets'
	return queue ++ (reverse stack)

