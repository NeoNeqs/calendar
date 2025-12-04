extends Label
class_name BetterLabel

@onready var fixed_label: Label = $"../../../FixedLabel"
@onready var scroll: Scroller = get_parent().get_parent()

var index: int

func _process(_delta: float) -> void:
	#and scroll.scroll_direction >= 0
	if self.global_position.y <= 0 :
		if self.index - 1 == scroll.active_index:
			fixed_label.text = self.text
			scroll.active_index = self.index
			scroll.labels[self.index].z_index = 0
	#and scroll.scroll_direction <= 0
	if self.global_position.y > 0 :
		if self.index == scroll.active_index:
			scroll.active_index = clampi(self.index - 1, 0, scroll.labels.size())
			fixed_label.text = scroll.labels[scroll.active_index].text
			scroll.labels[self.index].z_index = 1
	
