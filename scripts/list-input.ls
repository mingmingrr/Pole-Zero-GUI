require! 'prelude-ls': {flip, each, id, flatten}

require! './util.js': {list, trace}

(container) <-! (flip each) do
	document.query-selector-all \ul.list-input

validate = (value) ->
	func = container.validate
	func ?= ->
		result: it
		value: it
	func value

create-input = (item, init=null) ->
	input = document.create-element \input
	input.value = init if init?
	input.type = \text
	removed = false
	listener = (event) !->
		event.stop-propagation!
		return if removed
		if input.value == '' and init?
			removed := true
			item.remove!
			container.dispatch-event new Event \change
		else if (valid = validate input.value)?
			removed := true
			{result, value} = valid
			item.set-attribute \value, JSON.stringify result
			item.dispatch-event new Event \change
			container.dispatch-event new Event \change
			if value == ''
				if init?
					item.remove!
			else
				input.remove!
				item.text-content = value
				unless (item.next-element-sibling)?
					container.append-child (new-item = create-item!)
					new-item.query-selector \input .focus!
	input.add-event-listener \click, (!-> it.stop-propagation!)
	input.add-event-listener \change, (!-> it.stop-propagation!)
	input.add-event-listener \blur, listener
	input.add-event-listener \keydown, (event) !->
		return unless event.key-code == 13
		listener ...
	return input

create-item = (init=null) ->
	item = document.create-element \li
	if init? and (valid = validate init)?
		item.set-attribute \value, JSON.stringify valid.result
		item.text-content = valid.value
	else
		item.append-child create-input item, init
	item.add-event-listener \click, (event) !->
		input = create-input item, item.text-content
		item.text-content = ''
		item.append-child input
		input.focus!
	return item

container.append-child create-item!

container.create-item = ->
	container.append-child create-item it

