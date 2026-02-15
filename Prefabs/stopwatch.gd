class_name Stopwatch extends Node

var running: bool = false
var time: float = 0  # in seconds


func _process(delta: float) -> void:
	if !running:
		return
	time += delta


func stop() -> void:
	running = false


func start() -> void:
	running = true


func restart() -> void:
	running = true
	time = 0


func reset() -> void:
	time = 0


func get_time_string() -> String:
	return format_time(time)


static func format_time(total: float) -> String:
	var msecs: int = int(int(total*100) % 100)
	var secs: int = int(total) % 60
	var minutes: int = int(total/60) % 60
	var hours: int = int(total/(60*60))
	
	if hours > 0:
		return format_time_num(hours) + ":" + format_time_num(minutes) + ":" + \
		format_time_num(secs) + "." + format_time_num(msecs)
	
	return format_time_num(minutes) + ":" + format_time_num(secs) + "." + format_time_num(msecs)


static func format_time_num(num: int) -> String:
	if num < 10:
		return "0" + str(num)
	return str(num)
