require! webpack

prod = if process.env.NODE_ENV == \production
	then _=
		new webpack.optimize.DedupePlugin!
		new webpack.optimize.OccurenceOrderPlugin!
		new webpack.optimize.UglifyJsPlugin do
			mangle    : false
			sourcemap : false
	else []

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
		prod ++ new webpack.optimize.CommonsChunkPlugin do
			name:'vendor'
			filename:'vendor.js'

