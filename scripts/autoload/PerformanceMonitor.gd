extends Node
## Performance monitoring and optimization system for the wedding game
## Tracks frame rate, memory usage, and provides real-time performance metrics

signal performance_warning(metric: String, value: float, threshold: float)
signal memory_leak_detected(current_usage: int, peak_usage: int)

# Performance thresholds
const MIN_FPS_THRESHOLD := 30.0
const MAX_MEMORY_THRESHOLD := 512 * 1024 * 1024 # 512 MB
const MAX_DRAW_CALLS_THRESHOLD := 1000
const MEMORY_LEAK_THRESHOLD := 100 * 1024 * 1024 # 100 MB increase

# Monitoring configuration
var monitoring_enabled: bool = true
var detailed_logging: bool = false
var update_interval: float = 1.0
var history_length: int = 60 # Keep 60 seconds of history

# Performance metrics storage
var fps_history: Array[float] = []
var memory_history: Array[int] = []
var draw_calls_history: Array[int] = []
var frame_time_history: Array[float] = []

# Current metrics
var current_fps: float = 0.0
var current_memory: int = 0
var current_draw_calls: int = 0
var current_frame_time: float = 0.0
var peak_memory_usage: int = 0
var baseline_memory: int = 0

# Timing utilities
var last_update_time: float = 0.0
var frame_count: int = 0

# Performance warnings
var warning_cooldown: Dictionary = {}
const WARNING_COOLDOWN_TIME := 5.0 # 5 seconds between same warnings

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(monitoring_enabled)

	# Establish baseline memory usage
	await get_tree().process_frame
	baseline_memory = OS.get_static_memory_usage()
	peak_memory_usage = baseline_memory

	print("PerformanceMonitor initialized - Baseline memory: %d bytes" % baseline_memory)

func _process(_delta: float) -> void:
	if not monitoring_enabled:
		return

	var current_time = Time.get_ticks_msec() / 1000.0

	if current_time - last_update_time >= update_interval:
		_update_metrics()
		_check_performance_warnings()
		last_update_time = current_time

## Update all performance metrics
func _update_metrics() -> void:
	# FPS measurement
	current_fps = Engine.get_frames_per_second()
	_add_to_history(fps_history, current_fps)

	# Memory measurement
	current_memory = OS.get_static_memory_usage()
	if current_memory > peak_memory_usage:
		peak_memory_usage = current_memory
	_add_to_history(memory_history, current_memory)

	# Frame time measurement
	current_frame_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0 # Convert to ms
	_add_to_history(frame_time_history, current_frame_time)

	# Draw calls measurement
	current_draw_calls = int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	_add_to_history(draw_calls_history, current_draw_calls)

	if detailed_logging:
		_log_detailed_metrics()

## Add value to history array and maintain size limit
func _add_to_history(history: Array, value) -> void:
	history.append(value)
	if history.size() > history_length:
		history.pop_front()

## Check for performance issues and emit warnings
func _check_performance_warnings() -> void:
	# FPS warning
	if current_fps < MIN_FPS_THRESHOLD:
		_emit_warning("low_fps", current_fps, MIN_FPS_THRESHOLD)

	# Memory warning
	if current_memory > MAX_MEMORY_THRESHOLD:
		_emit_warning("high_memory", current_memory, MAX_MEMORY_THRESHOLD)

	# Memory leak detection
	var memory_growth = current_memory - baseline_memory
	if memory_growth > MEMORY_LEAK_THRESHOLD:
		_emit_memory_leak_warning()

	# Draw calls warning
	if current_draw_calls > MAX_DRAW_CALLS_THRESHOLD:
		_emit_warning("high_draw_calls", current_draw_calls, MAX_DRAW_CALLS_THRESHOLD)

## Emit performance warning with cooldown
func _emit_warning(warning_type: String, value: float, threshold: float) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0

	if warning_type in warning_cooldown:
		if current_time - warning_cooldown[warning_type] < WARNING_COOLDOWN_TIME:
			return

	warning_cooldown[warning_type] = current_time
	performance_warning.emit(warning_type, value, threshold)

	if detailed_logging:
		print("Performance Warning: %s - Value: %.2f, Threshold: %.2f" % [warning_type, value, threshold])

## Emit memory leak warning
func _emit_memory_leak_warning() -> void:
	memory_leak_detected.emit(current_memory, peak_memory_usage)
	if detailed_logging:
		print("Memory Leak Detected: Current: %d bytes, Peak: %d bytes, Growth: %d bytes" %
			[current_memory, peak_memory_usage, current_memory - baseline_memory])

## Log detailed performance metrics
func _log_detailed_metrics() -> void:
	print("Performance Metrics:")
	print("  FPS: %.1f (avg: %.1f)" % [current_fps, _get_average(fps_history)])
	print("  Memory: %s (peak: %s)" % [_format_bytes(current_memory), _format_bytes(peak_memory_usage)])
	print("  Frame Time: %.1f ms" % current_frame_time)
	print("  Draw Calls: %d" % current_draw_calls)
	print("  GPU Memory: %s" % _format_bytes(int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))))

## Get performance summary as dictionary
func get_performance_summary() -> Dictionary:
	return {
		"fps": {
			"current": current_fps,
			"average": _get_average(fps_history),
			"min": _get_minimum(fps_history),
			"history": fps_history.duplicate()
		},
		"memory": {
			"current": current_memory,
			"peak": peak_memory_usage,
			"baseline": baseline_memory,
			"growth": current_memory - baseline_memory,
			"history": memory_history.duplicate()
		},
		"frame_time": {
			"current": current_frame_time,
			"average": _get_average(frame_time_history),
			"max": _get_maximum(frame_time_history),
			"history": frame_time_history.duplicate()
		},
		"draw_calls": {
			"current": current_draw_calls,
			"average": _get_average(draw_calls_history),
			"max": _get_maximum(draw_calls_history),
			"history": draw_calls_history.duplicate()
		},
		"gpu_memory": int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)),
		"timestamp": Time.get_unix_time_from_system()
	}

## Start performance profiling for a specific function
func start_profiling(function_name: String) -> Dictionary:
	return {
		"name": function_name,
		"start_time": Time.get_ticks_usec(),
		"start_memory": OS.get_static_memory_usage()
	}

## End performance profiling and return results
func end_profiling(profile_data: Dictionary) -> Dictionary:
	var end_time = Time.get_ticks_usec()
	var end_memory = OS.get_static_memory_usage()

	var result = {
		"name": profile_data.name,
		"duration_us": end_time - profile_data.start_time,
		"duration_ms": (end_time - profile_data.start_time) / 1000.0,
		"memory_delta": end_memory - profile_data.start_memory,
		"start_memory": profile_data.start_memory,
		"end_memory": end_memory
	}

	if detailed_logging:
		print("Profile: %s took %.2f ms, memory delta: %s" %
			[result.name, result.duration_ms, _format_bytes(result.memory_delta)])

	return result

## Monitor a callable function's performance
func profile_function(callable: Callable, function_name: String = "") -> Dictionary:
	var name = function_name if function_name != "" else str(callable)
	var profile = start_profiling(name)

	callable.call()

	return end_profiling(profile)

## Force garbage collection and measure memory freed
func force_garbage_collection() -> Dictionary:
	var before_memory = OS.get_static_memory_usage()

	# Force GC in different ways
	var temp_objects = []
	for i in range(100):
		temp_objects.append(RefCounted.new())
	temp_objects.clear()

	# Wait for cleanup
	await get_tree().process_frame
	await get_tree().process_frame

	var after_memory = OS.get_static_memory_usage()
	var freed_memory = before_memory - after_memory

	var result = {
		"before_memory": before_memory,
		"after_memory": after_memory,
		"freed_memory": freed_memory,
		"timestamp": Time.get_unix_time_from_system()
	}

	if detailed_logging:
		print("Garbage Collection: Freed %s" % _format_bytes(freed_memory))

	return result

## Get system memory information
func get_system_memory_info() -> Dictionary:
	var memory_info = OS.get_memory_info()
	memory_info["static_usage"] = OS.get_static_memory_usage()
	memory_info["static_peak"] = OS.get_static_memory_peak_usage()
	return memory_info

## Set monitoring configuration
func configure_monitoring(enabled: bool, detailed: bool = false, interval: float = 1.0) -> void:
	monitoring_enabled = enabled
	detailed_logging = detailed
	update_interval = interval
	set_process(monitoring_enabled)

## Reset performance history
func reset_history() -> void:
	fps_history.clear()
	memory_history.clear()
	draw_calls_history.clear()
	frame_time_history.clear()
	baseline_memory = OS.get_static_memory_usage()
	peak_memory_usage = baseline_memory
	warning_cooldown.clear()

## Export performance data to file
func export_performance_data(file_path: String = "user://performance_log.json") -> void:
	var data = get_performance_summary()
	data["export_timestamp"] = Time.get_datetime_string_from_system()
	data["system_memory"] = get_system_memory_info()

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		print("Performance data exported to: %s" % file_path)
	else:
		print("Failed to export performance data to: %s" % file_path)

## Utility functions
func _get_average(array: Array) -> float:
	if array.is_empty():
		return 0.0
	var total = 0.0
	for value in array:
		total += value
	return total / array.size()

func _get_minimum(array: Array) -> float:
	if array.is_empty():
		return 0.0
	var minimum = array[0]
	for value in array:
		if value < minimum:
			minimum = value
	return minimum

func _get_maximum(array: Array) -> float:
	if array.is_empty():
		return 0.0
	var maximum = array[0]
	for value in array:
		if value > maximum:
			maximum = value
	return maximum

func _format_bytes(bytes: int) -> String:
	if bytes < 1024:
		return "%d B" % bytes
	elif bytes < 1024 * 1024:
		return "%.1f KB" % (bytes / 1024.0)
	elif bytes < 1024 * 1024 * 1024:
		return "%.1f MB" % (bytes / (1024.0 * 1024.0))
	else:
		return "%.1f GB" % (bytes / (1024.0 * 1024.0 * 1024.0))
