require! chai
require! chai: {expect}
require! 'chai-deep-closeto': deep_closeto
chai.use deep_closeto

require! '../scripts/token.js': Token

<-! describe 'Tokens'

specify 'Constants', !->
	expect Token.constants
		.to .be .an \object
		.and .contain .all .keys \e, \i, \pi

specify 'Brackets', !->
	expect Token.brackets
		.to .be .an \object
		.and .contain .all .keys \[, \}

specify 'Left brackets', !->
	expect Token.left-brackets
		.to .be .an \object
		.and .contain .all .keys \[, \(

specify 'Right brackets', !->
	expect Token.right-brackets
		.to .be .an \object
		.and .contain .all .keys \], \}

specify 'Operators', !->
	expect Token.operators
		.to .be .an \object
		.and .contain .all .keys \+, \/

specify 'Separators', !->
	expect Token.separators
		.to .be .an \object
		.and .contain .all .keys ','

specify 'Functions', !->
	expect Token.functions
		.to .be .an \object
		.and .contain .all .keys \log, \sin

