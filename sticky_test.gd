extends Control

@onready var next_label: Label = $Control/VBoxContainer/Label2
@onready var main_label: Label = $Label5
@onready var scroll: ScrollContainer = $Control

func _ready() -> void:
	scroll.scroll_started.connect(func() -> void: set_process(true))
	scroll.scroll_ended.connect(func() -> void: set_process(false))

func _process(_delta: float) -> void:
	if next_label.global_position.y <= 0:
		main_label.text = next_label.text
		main_label.z_index = next_label.z_index + 1
		#next_label.visible = false
		
	#print(scroll.get_child(2, true).scrolling.connect(
		#func() -> void:
			#await get_tree().physics_frame
			#await get_tree().physics_frame
			#await get_tree().physics_frame
			#if next_label.get_global_rect().intersects(main_label.get_global_rect()):
				#print("Hello")
	#))
