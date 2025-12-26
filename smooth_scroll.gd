extends ScrollContainer
class_name EventContainer

static var labels: Array[Label]

var active_index := 0:
	get(): return active_index
	set(v): 
		active_index = v;
		for i: int in labels.size():
			labels[i].set_process(i == active_index or i == active_index + 1)
