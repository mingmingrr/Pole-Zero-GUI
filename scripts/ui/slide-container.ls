require! 'prelude-ls': {flip, each, map, intersection, filter, find-index}

(container) <-! (flip each) do
	document.get-elements-by-class-name \slide-container

[prev-target, next-target, title-target] =
	[\prevtarget, \nexttarget, \titletarget]
	|> map (-> container.get-attribute it)
	|> map (-> if it? then document.query-selector it else null)

titled = title-target?

get-slides = (.child-nodes)
	>> (filter (.node-type == 1))
	>> (filter (.class-list.contains \slide-item))

find-active = find-index (.class-list.contains \active)

let slides = get-slides container
	active = find-active slides
	unless active?
		active := 0
		slides.0.class-list.add \active
	active = slides[active]
	if titled and (title = active.query-selector \.slide-title)?
		title-target.append-child title

shift-active = (shamt, event) -->
	event.stop-propagation!
	slides = get-slides container
	index = find-active slides
	active-source = slides[index]
	active-target = slides[(index + shamt) %% slides.length]
	active-source.class-list.remove \active
	active-target.class-list.add \active
	if titled
		active-source.append-child title-target.query-selector \.slide-title
		title-target.append-child active-target.query-selector \.slide-title
	active-target.dispatch-event new Event \resize

if prev-target?
	prev-target.add-event-listener \click, shift-active (-1)

if next-target?
	next-target.add-event-listener \click, shift-active 1

