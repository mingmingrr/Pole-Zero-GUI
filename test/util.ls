require! chai
require! chai: {expect}
require! 'chai-deep-closeto': deep_closeto
chai.use deep_closeto

require! '../scripts/util.js': Util

<-! describe 'Utility'

specify 'Argument list', !->
	expect Util.list 1, 2, 3
		.to .be .deep .equal [1, 2, 3]

specify 'Enumerate', !->
	expect Util.enumerate <[a b c]>
		.to .be .deep .equal [[0, \a], [1, \b], [2, \c]]

specify 'Enumerate with', !->
	expect Util.enumerate-with (+), <[a b c]>
		.to .be .deep .equal [\0a, \1b, \2c]

