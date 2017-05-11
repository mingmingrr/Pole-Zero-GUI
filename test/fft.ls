require! chai
require! chai: {expect}
require! 'chai-deep-closeto': deep_closeto
chai.use deep_closeto

require! '../scripts/complex.js': Complex
require! '../scripts/fft.js': Fft

<-! describe 'Fast fourier transform'
a = [[3, 2], [-1, 0], [-2, 1]]
b = [[0, 3], [5, 2], [2, 3], [5, 0]] 

d = 1e-6

specify 'Forward FFT', !->
	expect (Fft.fft 4) a
		.to .be .deep .closeTo b, d

specify 'Inverse FFT', !->
	expect (Fft.ifft 4) b
		.to .be .deep .closeTo (a ++ [Complex.zero]), d


