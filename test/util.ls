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

specify 'Peek zip', !->
	expect Util.peek 3, [1 to 5]
		.to .be .deep .equal [[1, 2, 3], [2, 3, 4], [3, 4, 5]]

describe 'Index of edit with distance of 1', !->
	specify 'Deletion', !->
		expect Util.find-edit (==), [0, 1, 2, 3, 4], [0, 2, 3, 4]
			.to .be .deep .equal [1, \deletion]

	specify 'Substitution', !->
		expect Util.find-edit (==), [0, 1, 2, 3, 4], [0, 5, 2, 3, 4]
			.to .be .deep .equal [1, \substitution]

	specify 'Insertion', !->
		expect Util.find-edit (==), [0, 1, 2, 3, 4], [0, 1, 5, 2, 3, 4]
			.to .be .deep .equal [2, \insertion]

	specify 'No change', !->
		expect Util.find-edit (==), [0, 1, 2, 3, 4], [0, 1, 2, 3, 4]
			.to .be .undefined

	specify 'Equivalence function', !->
		expect Util.find-edit (in), <[a b c d]>, <[ab ab cd cd]>
			.to .be .undefined

	specify 'More than 1 change', !->
		expect Util.find-edit (==), \abcde, \acfe
			.to .be .null
