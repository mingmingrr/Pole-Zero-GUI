require! chai
require! chai: {expect}
require! 'chai-deep-closeto': deep_closeto
chai.use deep_closeto

require! '../scripts/util.js': {list}
require! '../scripts/token.js': Token
require! '../scripts/tokenize.js': {tokenize}

<-! describe 'Tokenize'

specify 'Simple arirthmetic', !->
	expect tokenize '1 + 2'
		.to .be .deep .equal list do
			new Token.Number 1
			Token.operators.\+
			new Token.Number 2

specify 'Complex arithmetic', !->
	expect tokenize '(30 * 18^2)/2 - 504'
		.to .be .deep .equal list do
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

specify 'Functions and Constants', !->
	expect tokenize '2 + ln(e^(2j pi))'
		.to .be .deep .equal list do
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

