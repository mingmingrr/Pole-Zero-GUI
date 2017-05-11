require! 'prelude-ls': {flip, each, map}

(flip each) (document.get-elements-by-class-name \draggable), (element) ->
	[target, x-diff, y-diff, x-lim, y-lim] = [null, 0, 0, 0, 0]

	mousemove = (event) !->
		target.style.left = (0 >? event.client-x - x-diff <? x-lim) + \px
		target.style.top  = (0 >? event.client-y - y-diff <? y-lim) + \px

	element.add-event-listener \mousedown, (event) !->
		target := if element.dragtarget?
			then element.dragtarget else element
		[target-rect, parent-rect] = map do
			(.get-bounding-client-rect!)
			[target, target.parent-element]
		[x-diff, y-diff] :=
			parse-int event.layer-x
			parse-int event.layer-y
		[x-lim, y-lim] :=
			(parse-int parent-rect.width) - (parse-int target-rect.width)
			(parse-int parent-rect.height) - (parse-int target-rect.height)
		element.style.cursor = \move
		document.add-event-listener \mousemove, mousemove

	element.add-event-listener \mouseup, (event) !->
		element.style.cursor = \default
		document.remove-event-listener \mousemove, mousemove

