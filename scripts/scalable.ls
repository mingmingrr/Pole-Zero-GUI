require! 'prelude-ls': {flip, each, map}

(element) <-! (flip each) do
	document.get-elements-by-class-name \scalable

corner = document.create-element \div
corner.class-list.add \scalable-corner
element.append-child corner

[x-diff, y-diff, x-lim, y-lim] = [0, 0, 0, 0]

mousemove = (event) !->
	event.stop-propagation!
	window.get-selection!.remove-all-ranges!
	element.style.width  = (0 >? event.client-x - x-diff <? x-lim) + \px
	element.style.height = (0 >? event.client-y - y-diff <? y-lim) + \px

mouseup = (event) !->
	document.remove-event-listener \mousemove, mousemove
	document.remove-event-listener \mouseup, mouseup

corner.add-event-listener \mousedown, (event) !->
	event.stop-propagation!
	[corner-rect, element-rect, parent-rect] = map do
		(.get-bounding-client-rect!)
		[corner, element, element.parent-element]
	[x-diff, y-diff] :=
		(parse-int element-rect.left) - (parse-int parent-rect.left) - do
			(parse-int corner-rect.width) - (parse-int event.layer-x)
		(parse-int element-rect.top) - (parse-int parent-rect.top) - do
			(parse-int corner-rect.height) - (parse-int event.layer-y)
	[x-lim, y-lim] :=
		(parse-int parent-rect.width) - (parse-int element-rect.left)
		(parse-int parent-rect.height) - (parse-int element-rect.top)
	document.add-event-listener \mousemove, mousemove
	document.add-event-listener \mouseup, mouseup

