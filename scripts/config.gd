class_name Config
extends Object

#static var o_events: Dictionary[int, Array]
#static var last_fetch: int

const CONFIG_PATH := "user://data.cfg"

static var cfg := ConfigFile.new()

static func load_() -> Error:
	if not FileAccess.file_exists(CONFIG_PATH):
		var file := FileAccess.open(CONFIG_PATH, FileAccess.WRITE_READ)
		file.close()
	
	return cfg.load(CONFIG_PATH)

static func save_() -> void:
	return cfg.save(CONFIG_PATH)


static func set_last_fetch(value: int) -> void: 
	cfg.set_value("data", "last_fetch", value)
	
static func get_last_fetch() -> int: 
	return cfg.get_value("data", "last_fetch", -1)


static func set_events(value: Dictionary[int, Array]) -> void: 
	cfg.set_value("data", "o_events", value)

static func get_events() -> Dictionary[int, Array]: 
	return cfg.get_value("data", "o_events", Dictionary(
			{}, TYPE_INT, "", null, TYPE_ARRAY, "", null)
	)
