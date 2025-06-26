extends Node
## Automated Test Runner for Wedding Game
## Provides basic regression testing and system validation

signal test_completed(test_name: String, result: bool, details: Dictionary)
signal all_tests_completed(passed: int, failed: int, results: Array)

var test_results: Array[Dictionary] = []
var current_test_index: int = 0
var is_running_tests: bool = false

# Test configurations
var test_suite: Array[Dictionary] = [
	{
		"name": "System Initialization",
		"function": "_test_system_initialization",
		"timeout": 5.0,
		"critical": true
	},
	{
		"name": "Audio System",
		"function": "_test_audio_system",
		"timeout": 3.0,
		"critical": true
	},
	{
		"name": "Analytics Integration",
		"function": "_test_analytics_integration",
		"timeout": 2.0,
		"critical": false
	},
	{
		"name": "Performance Monitoring",
		"function": "_test_performance_monitoring",
		"timeout": 3.0,
		"critical": false
	},
	{
		"name": "Scene Transition System",
		"function": "_test_scene_transition",
		"timeout": 4.0,
		"critical": true
	},
	{
		"name": "Memory Management",
		"function": "_test_memory_management",
		"timeout": 5.0,
		"critical": false
	}
]

func _ready() -> void:
	print("[AutomatedTestRunner] Ready - %d tests configured" % test_suite.size())

## Run all automated tests
func run_all_tests() -> void:
	if is_running_tests:
		print("[AutomatedTestRunner] Tests already running")
		return
	
	print("[AutomatedTestRunner] Starting automated test suite...")
	is_running_tests = true
	test_results.clear()
	current_test_index = 0
	
	_run_next_test()

## Run specific test by name
func run_test(test_name: String) -> void:
	var test_config = null
	for config in test_suite:
		if config.name == test_name:
			test_config = config
			break
	
	if not test_config:
		print("[AutomatedTestRunner] Test not found: %s" % test_name)
		return
	
	print("[AutomatedTestRunner] Running single test: %s" % test_name)
	_execute_test(test_config)

## Get test results summary
func get_test_summary() -> Dictionary:
	var passed = 0
	var failed = 0
	var critical_failed = 0
	
	for result in test_results:
		if result.passed:
			passed += 1
		else:
			failed += 1
			if result.critical:
				critical_failed += 1
	
	return {
		"total_tests": test_results.size(),
		"passed": passed,
		"failed": failed,
		"critical_failed": critical_failed,
		"success_rate": (passed * 100.0) / max(test_results.size(), 1),
		"results": test_results
	}

## Internal test execution
func _run_next_test() -> void:
	if current_test_index >= test_suite.size():
		_complete_test_run()
		return
	
	var test_config = test_suite[current_test_index]
	await _execute_test(test_config)
	
	current_test_index += 1
	_run_next_test()

func _execute_test(test_config: Dictionary) -> void:
	print("[AutomatedTestRunner] Running: %s" % test_config.name)
	
	var start_time = Time.get_ticks_msec()
	var result = {
		"name": test_config.name,
		"passed": false,
		"critical": test_config.get("critical", false),
		"duration_ms": 0,
		"details": {},
		"error_message": ""
	}
	
	# Set up timeout
	var timeout_timer = Timer.new()
	timeout_timer.wait_time = test_config.get("timeout", 5.0)
	timeout_timer.one_shot = true
	add_child(timeout_timer)
	
	var timed_out = false
	timeout_timer.timeout.connect(func(): timed_out = true)
	timeout_timer.start()
	
	# Execute test function
	try:
		if has_method(test_config.function):
			var test_result = await call(test_config.function)
			if not timed_out:
				result.passed = test_result.get("passed", false)
				result.details = test_result.get("details", {})
				result.error_message = test_result.get("error", "")
		else:
			result.error_message = "Test function not found: %s" % test_config.function
	except:
		result.error_message = "Test execution failed with exception"
	
	if timed_out:
		result.passed = false
		result.error_message = "Test timed out after %.1f seconds" % test_config.timeout
	
	timeout_timer.queue_free()
	
	result.duration_ms = Time.get_ticks_msec() - start_time
	test_results.append(result)
	
	var status = "PASSED" if result.passed else "FAILED"
	print("[AutomatedTestRunner] %s: %s (%.0f ms)" % [test_config.name, status, result.duration_ms])
	
	if not result.passed and result.error_message:
		print("  Error: %s" % result.error_message)
	
	test_completed.emit(test_config.name, result.passed, result.details)

func _complete_test_run() -> void:
	is_running_tests = false
	var summary = get_test_summary()
	
	print("[AutomatedTestRunner] Test run completed:")
	print("  Total: %d, Passed: %d, Failed: %d" % [summary.total_tests, summary.passed, summary.failed])
	print("  Success Rate: %.1f%%" % summary.success_rate)
	
	if summary.critical_failed > 0:
		print("  WARNING: %d critical tests failed!" % summary.critical_failed)
	
	all_tests_completed.emit(summary.passed, summary.failed, test_results)

## Test Functions

func _test_system_initialization() -> Dictionary:
	var details = {}
	
	# Check autoload singletons
	var required_singletons = ["GameManager", "AudioManager", "PerformanceMonitor", "AnalyticsManager"]
	var missing_singletons = []
	
	for singleton_name in required_singletons:
		if not has_node("/root/" + singleton_name):
			missing_singletons.append(singleton_name)
		else:
			details[singleton_name + "_loaded"] = true
	
	return {
		"passed": missing_singletons.is_empty(),
		"details": details,
		"error": "Missing singletons: %s" % str(missing_singletons) if not missing_singletons.is_empty() else ""
	}

func _test_audio_system() -> Dictionary:
	var details = {}
	
	if not has_node("/root/AudioManager"):
		return {"passed": false, "error": "AudioManager not found"}
	
	var audio_manager = get_node("/root/AudioManager")
	
	# Test music loading
	var music_count = 0
	var sfx_count = 0
	
	if audio_manager.has_method("get_loaded_music_count"):
		music_count = audio_manager.call("get_loaded_music_count")
	
	if audio_manager.has_method("get_loaded_sfx_count"):
		sfx_count = audio_manager.call("get_loaded_sfx_count")
	
	details["music_tracks_loaded"] = music_count
	details["sfx_files_loaded"] = sfx_count
	
	# Basic functionality test
	var can_play_music = audio_manager.has_method("play_music")
	var can_play_sfx = audio_manager.has_method("play_sfx")
	
	return {
		"passed": music_count > 0 and sfx_count > 0 and can_play_music and can_play_sfx,
		"details": details,
		"error": "Audio system not properly configured" if music_count == 0 or sfx_count == 0 else ""
	}

func _test_analytics_integration() -> Dictionary:
	var details = {}
	
	if not has_node("/root/AnalyticsManager"):
		return {"passed": false, "error": "AnalyticsManager not found"}
	
	var analytics = get_node("/root/AnalyticsManager")
	
	# Test basic functionality
	var has_tracking = analytics.has_method("track_player_action")
	var has_summary = analytics.has_method("get_analytics_summary")
	
	details["tracking_available"] = has_tracking
	details["summary_available"] = has_summary
	
	if has_summary:
		var summary = analytics.call("get_analytics_summary")
		details["analytics_enabled"] = summary.get("enabled", false)
	
	return {
		"passed": has_tracking and has_summary,
		"details": details,
		"error": "Analytics methods missing" if not (has_tracking and has_summary) else ""
	}

func _test_performance_monitoring() -> Dictionary:
	var details = {}
	
	if not has_node("/root/PerformanceMonitor"):
		return {"passed": false, "error": "PerformanceMonitor not found"}
	
	var perf_monitor = get_node("/root/PerformanceMonitor")
	
	# Test basic monitoring
	var has_summary = perf_monitor.has_method("get_performance_summary")
	
	if has_summary:
		var summary = perf_monitor.call("get_performance_summary")
		details["fps_tracking"] = summary.has("fps")
		details["memory_tracking"] = summary.has("memory")
		details["current_fps"] = summary.get("fps", {}).get("current", 0)
		details["current_memory_mb"] = summary.get("memory", {}).get("current", 0) / (1024.0 * 1024.0)
	
	return {
		"passed": has_summary and details.get("fps_tracking", false) and details.get("memory_tracking", false),
		"details": details,
		"error": "Performance monitoring not functional" if not has_summary else ""
	}

func _test_scene_transition() -> Dictionary:
	var details = {}
	
	if not has_node("/root/SceneTransition"):
		return {"passed": false, "error": "SceneTransition not found"}
	
	var scene_transition = get_node("/root/SceneTransition")
	
	# Test animation system
	var animation_player = scene_transition.get_node_or_null("AnimationPlayer")
	if animation_player:
		var library = animation_player.get_animation_library("")
		if library:
			details["fade_to_black_exists"] = library.has_animation("fade_to_black")
			details["fade_from_black_exists"] = library.has_animation("fade_from_black")
		
		details["animation_library_loaded"] = library != null
	
	details["has_animation_player"] = animation_player != null
	
	return {
		"passed": animation_player != null and details.get("animation_library_loaded", false),
		"details": details,
		"error": "Scene transition animations missing" if not details.get("animation_library_loaded", false) else ""
	}

func _test_memory_management() -> Dictionary:
	var details = {}
	
	# Get baseline memory
	var initial_memory = OS.get_static_memory_usage()
	details["initial_memory_mb"] = initial_memory / (1024.0 * 1024.0)
	
	# Create and destroy some objects to test memory management
	var test_objects = []
	for i in range(100):
		test_objects.append(Node.new())
	
	var peak_memory = OS.get_static_memory_usage()
	details["peak_memory_mb"] = peak_memory / (1024.0 * 1024.0)
	
	# Clean up
	for obj in test_objects:
		obj.queue_free()
	test_objects.clear()
	
	# Wait for cleanup
	await get_tree().process_frame
	await get_tree().process_frame
	
	var final_memory = OS.get_static_memory_usage()
	details["final_memory_mb"] = final_memory / (1024.0 * 1024.0)
	details["memory_freed_mb"] = (peak_memory - final_memory) / (1024.0 * 1024.0)
	
	# Memory should have decreased or stayed similar
	var memory_growth = final_memory - initial_memory
	var reasonable_growth = memory_growth < (10 * 1024 * 1024) # Less than 10MB growth
	
	return {
		"passed": reasonable_growth,
		"details": details,
		"error": "Excessive memory growth detected: %.1f MB" % (memory_growth / (1024.0 * 1024.0)) if not reasonable_growth else ""
	}

## Public API for integration with testing systems
func export_test_results(file_path: String = "user://test_results.json") -> void:
	var summary = get_test_summary()
	summary["timestamp"] = Time.get_datetime_string_from_system()
	summary["game_version"] = ProjectSettings.get_setting("application/config/version", "1.0")
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(summary, "\t"))
		file.close()
		print("[AutomatedTestRunner] Test results exported to: %s" % file_path)
	else:
		print("[AutomatedTestRunner] Failed to export test results to: %s" % file_path)