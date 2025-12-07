extends VBoxContainer

const EVENT_NODE: PackedScene = preload("uid://bswn5h3q60jha")
const LABEL: PackedScene = preload("uid://x7vlwbgwhk54")
@onready var v_box_container: VBoxContainer = $DesktopSmoothScroll/SmothScroll/VBoxContainer
@onready var smoth_scroll: Scroller = $DesktopSmoothScroll/SmothScroll
@onready var fixed_label: Label = $DesktopSmoothScroll/FixedLabel

const M := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
const W := ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

func _ready() -> void:
	var parser := ICalParser.new()
	parser.parse()
	
	var current_timestamp := Time.get_unix_time_from_system()
	var label_index: int = 0
	var current_date: String 
	var label_to_scroll_to: Label = null
	var found := false
	
	for event: ICalParser.Event in parser.events:
		var event_date := "%04d-%02d-%02d" % [
			event.dt_start.year, event.dt_start.month, event.dt_start.day
		]
		
		if not event_date == current_date:
			var label := LABEL.instantiate()
			
			label.text = "%s %02d %s %04d" % [
				event.dt_start.weekname(), event.dt_start.day, 
				event.dt_start.monthname(), event.dt_start.year
			]
			current_date = event_date
			label.index = label_index
			label_index += 1
			smoth_scroll.labels.append(label)
			v_box_container.add_child(label)
		
			if not found:
				label_to_scroll_to = label
			
		var is_old := current_timestamp >= event.dt_start.unix_timestamp
		if not is_old and not found:
			found = true
		
		var node := EVENT_NODE.instantiate()
		v_box_container.add_child(node)
		node.set_data(event, is_old)
		
	fixed_label.text = smoth_scroll.labels[0].text

	for i: int in 5:
		await get_tree().physics_frame

	smoth_scroll.scroll_vertical = label_to_scroll_to.global_position.y - smoth_scroll.get_parent().global_position.y
	
