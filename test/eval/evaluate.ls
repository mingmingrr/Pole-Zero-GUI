require! chai
require! chai: {expect}
require! 'chai-deep-closeto': deep_closeto
chai.use deep_closeto

require! '../../scripts/eval/evaluate.js': Evaluate
require! '../../scripts/eval/token.js': Token
require! '../../scripts/util.js': {list, trace}

describe 'Reverse Polish evaluation', !->
	d = 1e-6

	specify 'Simple arithmetic', !->
		expect Evaluate.calc-rpn list do
			new Token.Number 1
			new Token.Number 2
			Token.operators.\+
		.to .be .deep .equal new Token.Number 3

	specify 'Complex arithmetic', !->
		expect Evaluate.calc-rpn list do
			new Token.Number 30
			new Token.Number 18
			new Token.Number 2
			Token.operators.\^
			Token.operators.\*
			new Token.Number 2
			Token.operators.\/
			new Token.Number 504
			Token.operators.\-
		.to .be .deep .equal new Token.Number 4356

	specify 'Functions and Constants', !->
		expect Evaluate.calc-rpn list do
			new Token.Number 2
			Token.constants.e
			new Token.Number 2
			Token.constants.j
			Token.operators.\*
			Token.constants.pi
			Token.operators.\*
			Token.operators.\^
			Token.functions.ln
			Token.operators.\+
		.to .be .deep .equal new Token.Number 2

	specify 'Random gibberish', !->
		expect !->
			Evaluate.calc-rpn list do
				new Token.Number 2
				new Token.Number 2
				Token.operators.\+
				new Token.Number 2
				Token.operators.\-
				Token.operators.\*
		.to .throw Error

describe 'Math string evaluation', !->
	specify 'Simple arithmetic', !->
		expect Evaluate.evaluate '1 + 2'
			.to .be .deep .equal [3, 0]

	specify 'Complex arithmetic', !->
		expect Evaluate.evaluate '(30 * 18^2)/2 - 504'
			.to .be .deep .equal [4356, 0]

	specify 'Functions and Constants', !->
		expect Evaluate.evaluate '2 + ln(e^(2j pi))'
			.to .be .deep .equal [2, 0]

	specify 'Random gibberish', !->
		expect !->
			Evaluate.evaluate 'ln 2(-2e'
		.to .throw Error

