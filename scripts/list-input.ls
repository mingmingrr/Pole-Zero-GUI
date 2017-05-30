require! 'prelude-ls': {flip, each, id, flatten}

require! './util.js': {list, trace}

validators = {}
validators[null] = validators[undefined] = validators[void] =
	-> {value: it, content: it}

export create-input = (init=null) ->
	input = document.create-element \input
	input.value = init if init?
	input.type = \text
	listener = (event) !->
		event.stop-propagation!
		remove-input input
	input.add-event-listener \click, (!-> it.stop-propagation!)
	input.add-event-listener \blur, listener
	input.add-event-listener \keydown, (event) !->
		return unless event.key-code == 13
		listener ...
	return input

export remove-input = (input, append=true) !->
	return unless (item = input.parent-node)?
	return if append and not (container = item.parent-node)?
	return unless (valid = if input.value == ''
		then {value:'', content:''}
		else validators[container] input.value)?
	{value, content} = valid
	if content == '' or valid == ''
		return remove-item item
	item.set-attribute \value, JSON.stringify value
	item.text-content = valid.content
	input.remove!
	if append and not item.next-sibling?
		container.append-child (new-item = create-item!)
		new-item.focus!
	item.dispatch-event new Event \change
	item.parent-node.dispatch-event new Event \change

export create-item = (init=null) ->
	item = document.create-element \li
	item.append-child (input = create-input init)
	item.add-event-listener \click, (event) !->
		event.stop-propagation!
		input = create-input item.text-content
		item.text-content = ''
		item.append-child input
		input.focus!
	return item

export remove-item = (item) !->
	return unless (container = item.parent-node)?
	unless item.next-sibling?
		container.append-child (new-item = create-item!)
		new-item.focus!
	try
		item.remove!
	container.dispatch-event new Event \change

export append-item = (container, init=null) !->
	container.append-child (item = create-item init)
	if (input = item.query-selector ':scope > input')?
		if (valid = validators[container] init)?
			remove-input input, false
			item.set-attribute \value, JSON.stringify valid.value
			item.text-content = valid.content
		else
			input.focus!

export attach-validator = (container, validator=null) !-->
	validator ?= ->
		{value: it, content: it}
	validators[container] = validator
	unless (container.query-selector ':scope > li')?
		container.append-child create-item!

