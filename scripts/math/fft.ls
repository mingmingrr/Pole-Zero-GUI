require! 'prelude-ls': {map, zipWith, maximum, id, negate}

require! './complex.js': Complex

export fft = (length, array) -->
	length = [length, array.length]
		|> maximum |> Math.log2 |> Math.ceil |> (2^)
	array = (map Complex.Complex, array) ++
		[Complex.zero] * (length - array.length)
	fft_impl negate, array

export ifft = (length, array) -->
	length = [length, array.length]
		|> maximum |> Math.log2 |> Math.ceil |> (2^)
	array = (map Complex.Complex, array) ++
		[Complex.zero] * (length - array.length)
	map (([x, y]) -> [x/length, y/length]), (fft_impl id, array)

fft_impl = (wheel, array) -->
	return array if (n = array.length / 2) < 1
	array = (fft_impl wheel, array[0 til array.length by 2]) ++
		(zipWith Complex.mul, (fft_impl wheel, array[1 til array.length by 2]),
			([Complex.iexp wheel Math.PI*i/n for i til n]))
	for i til n
		[l, r] = [array[i], array[i+n]]
		array[i] = Complex.add l, r
		array[i+n] = Complex.sub l, r
	return array

