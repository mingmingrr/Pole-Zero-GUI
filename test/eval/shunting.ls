require! chai
require! chai: {expect}
require! 'chai-deep-closeto': deep_closeto
chai.use deep_closeto

require! '../../scripts/eval/shunting.js': Shunting
require! '../../scripts/eval/token.js': Token
require! '../../scripts/util.js': {list, trace}

<-! describe 'Shunting yard'

describe 'Insert multiplication', !->
	specify 'Number number', !->
		expect Shunting.multiply do
			new Token.Number 1
			new Token.Number 2
		.to .be .false

	specify 'Number constant', !->
		expect Shunting.multiply do
			new Token.Number 1
			Token.constants.e
		.to .be .true

	specify 'Constant constant', !->
		expect Shunting.multiply do
			Token.constants.e
			Token.constants.pi
		.to .be .true

	specify 'Constant function', !->
		expect Shunting.multiply do
			Token.constants.pi
			Token.functions.log
		.to .be .true

	specify 'Function function', !->
		expect Shunting.multiply do
			Token.constants.log
			Token.constants.sin
		.to .be .false

	specify 'Number operator', !->
		expect Shunting.multiply do
			new Token.Number 2
			Token.operators.\+
		.to .be .false

describe 'Validate token stream multiplications', !->
	specify 'Simple arithmetic', !->
		expect Shunting.validate list do
			new Token.Number 3
			Token.constants.pi
		.to .be .deep .equal list do
			new Token.Number 3
			Token.operators.\*
			Token.constants.pi

	specify 'Negations', !->
		expect Shunting.validate list do
			Token.operators.\-
			Token.left-brackets.\(
			Token.operators.\-
			new Token.Number 3
			Token.right-brackets.\)
			Token.operators.\-
			Token.operators.\-
			Token.constants.pi
		.to .be .deep .equal list do
			new Token.Number 0
			Token.operators.\-
			Token.left-brackets.\(
			new Token.Number 0
			Token.operators.\-
			new Token.Number 3
			Token.right-brackets.\)
			Token.operators.\-
			new Token.Number 0
			Token.operators.\-
			Token.constants.pi

	specify 'Multiplications', !->
		expect Shunting.validate list do
			new Token.Number 3
			Token.constants.e
			Token.operators.\^
			Token.left-brackets.\(
			new Token.Number 2
			Token.constants.j
			Token.constants.pi
			Token.functions.ln
			Token.left-brackets.\(
			new Token.Number 2
			Token.right-brackets.\)
			Token.right-brackets.\)
		.to .be .deep .equal list do
			new Token.Number 3
			Token.operators.\*
			Token.constants.e
			Token.operators.\^
			Token.left-brackets.\(
			new Token.Number 2
			Token.operators.\*
			Token.constants.j
			Token.operators.\*
			Token.constants.pi
			Token.operators.\*
			Token.functions.ln
			Token.left-brackets.\(
			new Token.Number 2
			Token.right-brackets.\)
			Token.right-brackets.\)

describe 'Compare operator precedence', !->
	specify 'Left fixed', !->
		expect Shunting.compare-precedence do
			new Token.Operator null, 3, 'l'
			new Token.Operator null, 2, 'r'
		.to .be .false

		expect Shunting.compare-precedence do
			new Token.Operator null, 3, 'l'
			new Token.Operator null, 3, 'l'
		.to .be .true

		expect Shunting.compare-precedence do
			new Token.Operator null, 3, 'l'
			new Token.Operator null, 4, 'l'
		.to .be .true

	specify 'Right fixed', !->
		expect Shunting.compare-precedence do
			new Token.Operator null, 3, 'r'
			new Token.Operator null, 2, 'r'
		.to .be .false

		expect Shunting.compare-precedence do
			new Token.Operator null, 3, 'r'
			new Token.Operator null, 3, 'l'
		.to .be .false

		expect Shunting.compare-precedence do
			new Token.Operator null, 3, 'r'
			new Token.Operator null, 4, 'r'
		.to .be .true

describe 'Pop operator stack', !->
	stack = []

	before-each !->
		stack :=
			Token.operators.\^
			Token.functions.ln
			Token.left-brackets.\(
			Token.operators.\*
			Token.operators.\+

	specify 'No pop', !->
		expect [stack, Shunting.clear-stack stack]
		.to .be .deep .equal list do
			list do
				Token.operators.\^
				Token.functions.ln
				Token.left-brackets.\(
			list do
				Token.operators.\+
				Token.operators.\*

	specify 'Pop matching brackets', !->
		expect list do
			stack
			Shunting.clear-stack do
				stack
				Token.right-brackets.\)
		.to .be .deep .equal list do
			list do
				Token.operators.\^
			list do
				Token.operators.\+
				Token.operators.\*
				Token.functions.ln

	specify 'Pop mis-matching brackets', !->
		expect !->
			Shunting.clear-stack do
				stack
				Token.right-brackets.\]
		.to .throw Error

	specify 'No brackets', !->
		expect !->
			Shunting.clear-stack list do
				Token.operators.\*
				Token.operators.\+
		.to .throw Error

describe 'Shunting yard algorithm', !->
	specify 'Simple arithmetic', !->
		expect Shunting.shunting list do
			new Token.Number 1
			Token.operators.\+
			new Token.Number 2
		.to .be .deep .equal list do
			new Token.Number 1
			new Token.Number 2
			Token.operators.\+

	specify 'Complex arithmetic', !->
		expect Shunting.shunting list do
			Token.left-brackets.\(
			new Token.Number 30
			Token.operators.\*
			new Token.Number 18
			Token.operators.\^
			new Token.Number 2
			Token.right-brackets.\)
			Token.operators.\/
			new Token.Number 2
			Token.operators.\-
			new Token.Number 504
		.to .be .deep .equal list do
			new Token.Number 30
			new Token.Number 18
			new Token.Number 2
			Token.operators.\^
			Token.operators.\*
			new Token.Number 2
			Token.operators.\/
			new Token.Number 504
			Token.operators.\-

	specify 'Functions and Constants', !->
		expect Shunting.shunting list do
			new Token.Number 2
			Token.operators.\+
			Token.functions.ln
			Token.left-brackets.\(
			Token.constants.e
			Token.operators.\^
			Token.left-brackets.\(
			new Token.Number 2
			Token.constants.j
			Token.constants.pi
			Token.right-brackets.\)
			Token.right-brackets.\)
		.to .be .deep .equal list do
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

	specify 'Random gibberish', !->
		expect !->
			Shunting.shunting list do
				Token.functions.ln
				new Token.Number 2
				Token.left-brackets.\(
				Token.operators.\-
				new Token.Number 2
				Token.constants.e
		.to .throw Error

