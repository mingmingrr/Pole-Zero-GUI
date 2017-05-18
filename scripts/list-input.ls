require! 'prelude-ls': {flip, each, id, flatten}

require! './util.js': {list}

(container) <-! (flip each) do
	document.query-selector-all \ul.list-input

validate = container.validate
validate ?= id

create-input = (item, init=null) ->
	input = document.create-element \input
	input.value = init if init?
	input.type = \type
	removed = false
	listener = (event) !->
		event.stop-propagation!
		return if removed
		if (value = validate input.value)?
			removed := true
			if value == ''
				if init?
					item.remove!
			else
				input.remove!
				item.text-content = value
				unless (item.next-element-sibling)?
					container.append-child create-item!
	input.add-event-listener \click, (!-> it.stop-propagation!)
	input.add-event-listener \blur, listener
	input.add-event-listener \keydown, (event) !->
		return unless event.key-code == 13
		listener ...
	return input

create-item = ->
	item = document.create-element \li
	item.append-child create-input item
	item.add-event-listener \click, (event) !->
		input = create-input item, item.text-content
		item.text-content = ''
		item.append-child input
		input.focus!
	return item

container.append-child create-item!

