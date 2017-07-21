require! 'prelude-ls': {flip, each, map}

(element) <-! (flip each) do
	document.get-elements-by-class-name \draggable

[target, x-diff, y-diff, x-lim, y-lim] = [null, 0, 0, 0, 0]

mousemove = (event) !->
	event.stop-propagation!
	window.get-selection!.remove-all-ranges!
	target.style.left = (0 >? event.client-x - x-diff <? x-lim) + \px
	target.style.top  = (0 >? event.client-y - y-diff <? y-lim) + \px

mouseup = (event) !->
	element.style.cursor = \default
	document.remove-event-listener \mousemove, mousemove
	document.remove-event-listener \mouseup, mouseup

element.add-event-listener \mousedown, (event) !->
	target := if (element.get-attribute \dragtarget)?
		then document.query-selector element.get-attribute \dragtarget
		else element
	[target-rect, parent-rect] = map do
		(.get-bounding-client-rect!)
		[target, target.parent-element]
	[x-diff, y-diff] :=
		(parse-int event.client-x) - (parse-int target-rect.left)
		(parse-int event.client-y) - (parse-int target-rect.top)
	[x-lim, y-lim] :=
		(parse-int parent-rect.width) - (parse-int target-rect.width)
		(parse-int parent-rect.height) - (parse-int target-rect.height)
	element.style.cursor = \move
	document.add-event-listener \mousemove, mousemove
	document.add-event-listener \mouseup, mouseup

