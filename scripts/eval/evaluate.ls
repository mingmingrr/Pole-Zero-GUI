require! 'prelude-ls': {apply, reverse}

require! './token.js': Token
require! './tokenize.js': {tokenize}
require! './shunting.js': {shunting}
require! '../util.js': Util

pop-stack = (stack) -> ->
	unless stack.length
		throw new Error 'not enough numbers'
	return stack.pop!

export calc-rpn = (tokens) ->
	stack = []
	pop = pop-stack stack
	for token in tokens
		switch
		| token instanceof Token.Number =>
			stack.push token
		| token instanceof Token.Function =>
			stack.push new Token.Number do
				apply token.func, reverse [pop!.value for til 1]
		| token instanceof Token.Operator =>
			stack.push new Token.Number do
				apply token.op, reverse [pop!.value, pop!.value]
		| otherwise =>
			throw new Error 'invalid token'
	unless stack.length == 1
		throw 'too many numbers'
	return stack.0

export evaluate = tokenize >> shunting >> calc-rpn >> (.value)

