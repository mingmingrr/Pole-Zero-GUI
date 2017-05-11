require! 'prelude-ls': {map, zipWith}

require! './complex.js': Complex

export fft = (length, array) -->
	length = length |> Math.log2 |> Math.ceil |> (2^)
	array = (map Complex.Complex, array) ++
		[Complex.zero] * (length - array.length)
	fft_impl array

fft_impl = (array) ->
	return array if (n = array.length / 2) < 1
	array = (fft_impl array[0 til array.length by 2]) ++
		(zipWith Complex.mul, (fft_impl array[1 til array.length by 2]),
			([Complex.iexp -Math.PI*i/n for i til n]))
	for i til n
		[l, r] = [array[i], array[i+n]]
		array[i] = Complex.add l, r
		array[i+n] = Complex.sub l, r
	return array

export ifft = (length, array) -->
	length = length |> Math.log2 |> Math.ceil |> (2^)
	array = (map Complex.Complex, array) ++
		[Complex.zero] * (length - array.length)
	map (([x, y]) -> [x/length, y/length]), (ifft_impl array)

ifft_impl = (array) ->
	return array if (n = array.length / 2) < 1
	array = (fft_impl array[0 til array.length by 2]) ++
		(zipWith Complex.mul, (fft_impl array[1 til array.length by 2]),
			([Complex.iexp Math.PI*i/n for i til n]))
	for i til n
		[l, r] = [array[i], array[i+n]]
		array[i] = Complex.add l, r
		array[i+n] = Complex.sub l, r
	return array

