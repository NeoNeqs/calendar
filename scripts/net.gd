class_name Net
extends RefCounted

static func fetch_ical(file_path: String) -> HTTPRequest:
	var client := HTTPRequest.new()
	client.download_file = file_path
	client.ready.connect(func() -> void:
		var error: Error = client.request(
			"https://apollotocal.uek.krakow.pl/calendar/group/259421", 
		)
		
		if not error == OK:
			# Toast notifications
			return
	)
	
	return client
