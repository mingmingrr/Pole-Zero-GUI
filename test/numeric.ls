require! chai
require! chai: {expect}
require! 'chai-deep-closeto': deep_closeto
chai.use deep_closeto

require! 'prelude-ls': {map, last}

require! '../scripts/complex.js': Complex
require! '../scripts/numeric.js': Numeric

<-! describe 'Polynomial Transformations'
r = [1, 3, -2]
p = map Complex.Complex, [6, -5, -2, 1]
q = map Complex.Complex, [3, -4, 1]

rc = [[-3, 1], [1, 2], [-2, 1]]
pc = [[-15, -5], [-4, -13], [4, -4], [1, 0]]
qc = [[-5, -5], [2, -3], [1, 0]]

d = 1e-6

describe 'Add root', !->
	specify 'Scaled polynomial', !->
		expect Numeric.add-root (map Complex.Complex, [-1, 3, 2]), 3
			.to .be .deep .closeTo (map Complex.Complex, [3, -10, -3, 2]), d

	describe 'Real root', !->
		specify 'Empty polynomial', !->
			expect Numeric.add-root [Complex.one], 2
				.to .be .deep .closeTo [(Complex.Complex -2), Complex.one], d

		specify 'General polynomial', !->
			expect Numeric.add-root q, (last r)
				.to .be .deep .closeTo p, d

	describe 'Complex root', !->
		specify 'Empty polynomial', !->
			expect Numeric.add-root [Complex.one], [-2, 1]
				.to .be .deep .closeTo [(Complex.Complex 2, -1), Complex.one], d

		specify 'General polynomial', !->
			expect Numeric.add-root qc, (last rc)
				.to .be .deep .closeTo pc, d

describe 'Roots to polynomial', !->
	specify 'Empty roots', !->
		expect Numeric.to-polynomial []
			.to .be .deep .closeTo [Complex.one], d

	specify 'Real roots', !->
		expect Numeric.to-polynomial r
			.to .be .deep .closeTo p, d

	specify 'Complex roots', !->
		expect Numeric.to-polynomial rc
			.to .be .deep .closeTo pc, d
