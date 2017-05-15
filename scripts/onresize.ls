require! 'prelude-ls': {map, filter}

create-object = (element) ->
	document.create-element \object
		..style
			..position = \absolute
			..display  = \block
			..top      = 0
			..left     = 0
			..height   = \100%
			..width    = \100%
			..overflow = \hidden
			..z-index  = -1
			..pointer-events = \none
		..type = \text/html
		..data = \about:blank
		..class-list
			..add \resize-trigger
		..add-event-listener \load, !->
			@content-document.default-view
				.add-event-listener \resize, !->
					element.dispatch-event new Event \resize

get-objects = (.child-nodes)
	>> (filter (.node-type == 1))
	>> (filter (.class-list.contains \resize-trigger))

export attach-resize-listener = (element) !->
	unless get-objects element .length
		element.append-child create-object element

