require! 'prelude-ls': {map, filter}

create-object = (element) ->
	document.create-element \object
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

