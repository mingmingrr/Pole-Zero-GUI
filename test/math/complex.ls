require! chai
require! chai: {expect}
require! 'chai-deep-closeto': deep_closeto
chai.use deep_closeto

require! '../../scripts/math/complex.js': Complex

<-! describe 'Complex numbers'
a = [-3, 4]
b = [2, 1]
p = [5, 2.21429744]

d = 1e-5

describe 'Properties', !->
	specify 'Real part', !->
		expect Complex.real a
			.to .equal -3

	specify 'Imaginary part', !->
		expect Complex.imag a
			.to .equal 4

	specify 'Negation', !->
		expect Complex.negate a
			.to .be .deep .equal [3, -4]

	specify 'Modulus', !->
		expect Complex.abs a
			.to .equal p[0]

	specify 'Square modulus', !->
		expect Complex.abs2 a
			.to .equal p[0]^2

	specify 'Argument', !->
		expect Complex.angle a
			.to .be .closeTo p[1], d

	specify 'Conjugate', !->
		expect Complex.conj a
			.to .be .deep .equal [-3, -4]

	specify 'Conjugate pairs', !->
		expect Complex.pair a
			.to .be .deep .equal [a, [-3, -4]]

	describe 'Real or Complex', !->
		specify 'Real', !->
			expect Complex.is-real [2, 0]
				.to .be .true

		specify 'Complex', !->
			expect Complex.is-real a
				.to .be .false

describe 'Transformations', !->
	specify 'From numeric', !->
		expect Complex.Complex -3
			.to .be .deep .equal [-3, 0]

	specify 'From array', !->
		expect Complex.Complex a
			.to .be .deep .equal a

	specify 'To polar form', !->
		expect Complex.polar a
			.to .be .deep .closeTo p, d

	specify 'To complex form', !->
		expect Complex.rect p
			.to .be .deep .closeTo a, d

	describe 'To string', !->
		specify 'Zero zero', !->
			expect Complex.to-string [0, 0]
				.to .equal \0

		specify 'Real only', !->
			expect Complex.to-string [2, 0]
				.to .equal \2

		specify 'Complex only', !->
			expect Complex.to-string [0, 2]
				.to .equal \2i

		specify 'Positive positive', !->
			expect Complex.to-string [2, 2]
				.to .equal \2+2i

		specify 'Positive negative', !->
			expect Complex.to-string [2, -2]
				.to .equal \2-2i

		specify 'Negative zero', !->
			expect Complex.to-string [-2, 0]
				.to .equal \-2

describe 'Operations', !->
	specify 'Addition', !->
		expect Complex.add a, b
			.to .deep .equal [-1, 5]

	specify 'Subtraction', !->
		expect Complex.sub a, b
			.to .deep .equal [-5, 3]

	specify 'Multiplication', !->
		expect Complex.mul a, b
			.to .deep .equal [-10, 5]

	specify 'Division', !->
		expect Complex.div a, b
			.to .be .deep .closeTo [-0.4, 2.2], d

	describe 'Power', !->
		specify 'real complex', !->
			expect Complex.pow [2, 0], a
				.to .be .deep .closeTo [-0.11658588, 0.04508582], d

		specify 'complex real', !->
			expect Complex.pow a, [-1.5, 0]
				.to .be .deep .closeTo [-0.088, 0.016], d

		specify 'complex complex', !->
			expect Complex.pow a, b
				.to .be .deep .closeTo [2.64910698, -0.66276612], d

	specify 'Exponential', !->
		expect Complex.exp a
			.to .be .deep .closeTo [-0.03254299, -0.03767897], d

	specify 'Complex exponential', !->
		expect Complex.iexp Math.PI/2
			.to .be .deep .closeTo [0, 1], d
