extends VBoxContainer

const EVENT_NODE: PackedScene = preload("uid://bswn5h3q60jha")
const LABEL: PackedScene = preload("uid://x7vlwbgwhk54")

const FILE_PATH := "user://events.ical"

func _enter_tree() -> void:
	var error := Config.load_()
	print(error)
	
	var current_timestamp: int = Date.now().unix_timestamp
	var last_fetch: int = Config.get_last_fetch()
	
	if not FileAccess.file_exists(FILE_PATH) or current_timestamp - last_fetch >= 21600:
		var client: HTTPRequest = Net.fetch_ical(FILE_PATH)
		client.request_completed.connect(_request_completed.bind(client))
		add_child(client)
	else:
		_setup_tree()

func _parse() -> void:
	var parser := ICalParser2.new()
	parser.parse(FILE_PATH)

func _setup_tree() -> void:
	var container: VBoxContainer = $DesktopSmoothScroll/Container/VB
	var smoth_scroll: EventContainer = $DesktopSmoothScroll/Container
	var fixed_label: Label = $DesktopSmoothScroll/FixedLabel
	
	var current_timestamp: int = Date.utc_now().unix_timestamp
	var label_to_scroll_to: Label = null
	var label_index: int = 0
	
	var events: Dictionary[int, Array] = Config.get_events()
	print(events)
	var keys: Array = events.keys()
	
	var n: int = events.size()
	var index: int = 0
	
	while index < n:
		var date_stamp: int = keys[index]
		var date_events: Array = events[date_stamp]
		
		var label: BetterLabel = LABEL.instantiate()
		label.text = date_events[0].dt_start.to_human_date()
		label.index = label_index
		
		label_index += 1
		smoth_scroll.labels.append(label)
		container.add_child(label)
		
		for event: Event in date_events:
			var is_old_event: bool = (
				current_timestamp >= event.dt_start.unix_timestamp and not 
				current_timestamp <= event.dt_end.unix_timestamp
			)
			
			var event_node: EventNode = EVENT_NODE.instantiate()
			container.add_child(event_node)
			event_node.set_data(event, is_old_event)
		
		if date_stamp <= current_timestamp:
			label_to_scroll_to = label
		
		index += 1
	fixed_label.text = smoth_scroll.labels[0].text
	smoth_scroll.labels[0].modulate = Color.TRANSPARENT
	
	# One does not simply scroll to a child node on the same frame when it was added.
	for i: int in 2:
		await get_tree().process_frame
	
	smoth_scroll.scroll_vertical = int(label_to_scroll_to.position.y)

func _request_completed(_r: int, response_code: int, _h: PackedStringArray, _b: PackedByteArray, client: HTTPRequest) -> void:
	if response_code == 200:
		Config.set_last_fetch(Date.now().unix_timestamp)
		_parse()
		_setup_tree()

	client.queue_free()
