require! webpack

export
	entry:
		app: './scripts/app.js'
		vendor:
			'd3'
			'prelude-ls'
	output:
		path: __dirname
		filename: 'app.js'
	plugins:
		new webpack.optimize.CommonsChunkPlugin _=
			name:'vendor'
			filename:'vendor.js'
		...
		# [new webpack.optimize.UglifyJsPlugin]
