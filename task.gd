extends Node

var _tasks: Array = []


func create(f: Callable, args: Array, per_frame: int) -> void:
	var min_task_count := int(args.size() / float(per_frame))

	var i := 0
	while i < min_task_count:
		_tasks.append([f, args.slice(i * per_frame, (i + 1) * per_frame)])
		i += 1
	_tasks.append([f, args.slice(i * per_frame)])
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not _tasks == null:
		pass
	
	for task: Array in _tasks:
		task[0].call(task[1])
