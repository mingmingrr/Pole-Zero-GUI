require! 'prelude-ls': {compact}

require! './token.js': Token
require! './util.js': {list, trace}

regex =
	space:
		/^(\s+)(.*)/
		1, 2
		[]
	number:
		/^(\d+(\.\d*)?(e[+-]?\d+)?)(.*)/i
		1, 4
		[]
	word:
		/^(\w+)(.*)/i
		1, 2
		list do
			Token.constants
			Token.functions
	other:
		/^(.)(.*)/i
		1, 2
		list do
			Token.left-brackets
			Token.right-brackets
			Token.operators
			Token.separators

split = ([reg, head, tail, pool], string) -->
	parts = reg.exec string
	if parts?
		then [parts[head], parts[tail], pool]
		else null

take-from = (dicts, key) -->
	for dict in dicts
		if key of dict
			return dict[key]
	throw new Error 'invalid token'
	
export tokenize = (string) ->
	while string.length
		switch
		| split regex.space, string =>
			string = that.1
			void
		| split regex.number, string =>
			string = that.1
			new Token.Number parse-float that.0
		| split regex.word, string =>
			string = that.1
			take-from that.2, that.0
		| split regex.other, string =>
			string = that.1
			take-from that.2, that.0
>> compact

