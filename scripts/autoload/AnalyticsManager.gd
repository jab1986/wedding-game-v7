extends Node
## Analytics and Telemetry Manager for Wedding Game
## Provides optional, privacy-friendly analytics to track player behavior and identify difficulty spikes

signal analytics_event_logged(event_type: String, data: Dictionary)
signal difficulty_spike_detected(level: String, metric: String, spike_data: Dictionary)

# Privacy and consent settings
var analytics_enabled: bool = false
var user_consent_given: bool = false
var anonymous_mode: bool = true

# Session tracking
var session_id: String = ""
var session_start_time: float = 0.0
var current_level: String = ""
var player_character: String = ""

# Player behavior metrics
var player_actions: Array[Dictionary] = []
var level_completion_times: Dictionary = {}
var death_locations: Array[Dictionary] = []
var item_collection_data: Dictionary = {}
var dialogue_interaction_data: Dictionary = {}

# Difficulty spike detection
var difficulty_metrics: Dictionary = {
	"death_count": 0,
	"retry_count": 0,
	"stuck_time": 0.0,
	"help_requests": 0
}

# Analytics thresholds for difficulty detection
const DIFFICULTY_THRESHOLDS = {
	"max_deaths_per_level": 5,
	"max_retry_time": 300.0, # 5 minutes
	"max_stuck_time": 180.0, # 3 minutes
	"performance_fps_threshold": 30.0
}

# Data collection settings
var collect_performance_data: bool = true
var collect_player_paths: bool = false
var max_session_duration: float = 3600.0 # 1 hour

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Load user preferences
	_load_analytics_preferences()
	
	# Connect to existing systems
	_connect_to_existing_systems()
	
	# Start analytics session if enabled
	if analytics_enabled and user_consent_given:
		start_analytics_session()

## Load analytics preferences from user settings
func _load_analytics_preferences() -> void:
	var config = ConfigFile.new()
	var error = config.load("user://settings.cfg")
	
	if error == OK:
		analytics_enabled = config.get_value("analytics", "enabled", false)
		user_consent_given = config.get_value("analytics", "consent_given", false)
		anonymous_mode = config.get_value("analytics", "anonymous_mode", true)
		collect_performance_data = config.get_value("analytics", "performance_data", true)
		collect_player_paths = config.get_value("analytics", "player_paths", false)
	
	print("[AnalyticsManager] Loaded preferences - Enabled: %s, Consent: %s" % [analytics_enabled, user_consent_given])

## Save analytics preferences to user settings
func _save_analytics_preferences() -> void:
	var config = ConfigFile.new()
	config.set_value("analytics", "enabled", analytics_enabled)
	config.set_value("analytics", "consent_given", user_consent_given)
	config.set_value("analytics", "anonymous_mode", anonymous_mode)
	config.set_value("analytics", "performance_data", collect_performance_data)
	config.set_value("analytics", "player_paths", collect_player_paths)
	
	config.save("user://settings.cfg")

## Connect to existing performance and testing systems
func _connect_to_existing_systems() -> void:
	# Connect to PerformanceMonitor
	if has_node("/root/PerformanceMonitor"):
		var perf_monitor = get_node("/root/PerformanceMonitor")
		if perf_monitor.has_signal("performance_warning"):
			perf_monitor.performance_warning.connect(_on_performance_warning)
		if perf_monitor.has_signal("memory_leak_detected"):
			perf_monitor.memory_leak_detected.connect(_on_memory_leak_detected)
	
	# Connect to TestingManager
	if has_node("/root/TestingManager"):
		var test_manager = get_node("/root/TestingManager")
		if test_manager.has_signal("test_event_logged"):
			test_manager.test_event_logged.connect(_on_test_event_logged)

## Request analytics consent from user
func request_analytics_consent() -> bool:
	if user_consent_given:
		return true
	
	# This would typically show a consent dialog
	# For now, we'll create a simple consent mechanism
	print("[AnalyticsManager] Analytics consent required. Please enable in settings.")
	return false

## Enable analytics with user consent
func enable_analytics(consent: bool = true) -> void:
	user_consent_given = consent
	analytics_enabled = consent
	_save_analytics_preferences()
	
	if analytics_enabled:
		start_analytics_session()
		print("[AnalyticsManager] Analytics enabled with user consent")
	else:
		stop_analytics_session()
		print("[AnalyticsManager] Analytics disabled")

## Start new analytics session
func start_analytics_session() -> void:
	if not analytics_enabled or not user_consent_given:
		return
	
	session_id = _generate_session_id()
	session_start_time = Time.get_ticks_msec() / 1000.0
	
	# Reset session data
	player_actions.clear()
	level_completion_times.clear()
	death_locations.clear()
	item_collection_data.clear()
	dialogue_interaction_data.clear()
	difficulty_metrics = {
		"death_count": 0,
		"retry_count": 0,
		"stuck_time": 0.0,
		"help_requests": 0
	}
	
	# Log session start
	log_analytics_event("session_start", {
		"session_id": session_id,
		"timestamp": Time.get_datetime_string_from_system(),
		"anonymous_mode": anonymous_mode,
		"game_version": ProjectSettings.get_setting("application/config/version", "1.0")
	})

## Stop analytics session and export data
func stop_analytics_session() -> void:
	if session_id.is_empty():
		return
	
	var session_duration = (Time.get_ticks_msec() / 1000.0) - session_start_time
	
	log_analytics_event("session_end", {
		"session_id": session_id,
		"duration": session_duration,
		"total_actions": player_actions.size(),
		"levels_completed": level_completion_times.keys().size(),
		"total_deaths": difficulty_metrics.death_count
	})
	
	# Export session data
	_export_session_data()
	
	print("[AnalyticsManager] Session ended - Duration: %.1f seconds" % session_duration)

## Log analytics event
func log_analytics_event(event_type: String, data: Dictionary) -> void:
	if not analytics_enabled or not user_consent_given:
		return
	
	var event_data = {
		"session_id": session_id,
		"timestamp": Time.get_ticks_msec() / 1000.0,
		"event_type": event_type,
		"level": current_level,
		"character": player_character,
		"data": data
	}
	
	# Remove personally identifiable information if in anonymous mode
	if anonymous_mode:
		event_data = _anonymize_data(event_data)
	
	analytics_event_logged.emit(event_type, event_data)

## Track player action for behavior analysis
func track_player_action(action: String, context: Dictionary = {}) -> void:
	if not analytics_enabled:
		return
	
	var action_data = {
		"action": action,
		"timestamp": Time.get_ticks_msec() / 1000.0,
		"level": current_level,
		"context": context
	}
	
	player_actions.append(action_data)
	
	# Check for difficulty spikes based on actions
	_analyze_difficulty_from_action(action, context)
	
	log_analytics_event("player_action", action_data)

## Track level progression
func track_level_start(level_name: String) -> void:
	current_level = level_name
	track_player_action("level_start", {"level": level_name})

func track_level_complete(level_name: String, completion_time: float) -> void:
	level_completion_times[level_name] = completion_time
	track_player_action("level_complete", {
		"level": level_name,
		"completion_time": completion_time
	})
	
	# Check if completion time indicates difficulty
	_analyze_level_difficulty(level_name, completion_time)

func track_player_death(location: Vector2, cause: String = "") -> void:
	difficulty_metrics.death_count += 1
	
	var death_data = {
		"location": {"x": location.x, "y": location.y},
		"cause": cause,
		"level": current_level,
		"death_number": difficulty_metrics.death_count
	}
	
	death_locations.append(death_data)
	track_player_action("player_death", death_data)
	
	# Check for death clustering (difficulty spike)
	_check_death_clustering()

## Track item interactions
func track_item_collected(item_name: String, location: Vector2) -> void:
	if not item_collection_data.has(item_name):
		item_collection_data[item_name] = 0
	item_collection_data[item_name] += 1
	
	track_player_action("item_collected", {
		"item": item_name,
		"location": {"x": location.x, "y": location.y},
		"total_collected": item_collection_data[item_name]
	})

## Track dialogue interactions
func track_dialogue_interaction(character: String, dialogue_id: String, choice: String = "") -> void:
	if not dialogue_interaction_data.has(character):
		dialogue_interaction_data[character] = []
	
	var dialogue_data = {
		"dialogue_id": dialogue_id,
		"choice": choice,
		"timestamp": Time.get_ticks_msec() / 1000.0
	}
	
	dialogue_interaction_data[character].append(dialogue_data)
	track_player_action("dialogue_interaction", {
		"character": character,
		"dialogue_id": dialogue_id,
		"choice": choice
	})

## Set player character for tracking
func set_player_character(character_name: String) -> void:
	player_character = character_name
	track_player_action("character_selected", {"character": character_name})

## Difficulty spike detection methods
func _analyze_difficulty_from_action(action: String, _context: Dictionary) -> void:
	match action:
		"player_death":
			if difficulty_metrics.death_count >= DIFFICULTY_THRESHOLDS.max_deaths_per_level:
				_trigger_difficulty_spike("excessive_deaths", {
					"death_count": difficulty_metrics.death_count,
					"level": current_level
				})
		
		"level_retry":
			difficulty_metrics.retry_count += 1
		
		"help_request":
			difficulty_metrics.help_requests += 1

func _analyze_level_difficulty(level_name: String, completion_time: float) -> void:
	# Check if completion time is unusually long
	if completion_time > DIFFICULTY_THRESHOLDS.max_retry_time:
		_trigger_difficulty_spike("long_completion_time", {
			"level": level_name,
			"completion_time": completion_time,
			"threshold": DIFFICULTY_THRESHOLDS.max_retry_time
		})

func _check_death_clustering() -> void:
	# Check if recent deaths are clustered in the same area
	if death_locations.size() < 3:
		return
	
	var recent_deaths = death_locations.slice(-3) # Last 3 deaths
	var locations = []
	for death in recent_deaths:
		locations.append(Vector2(death.location.x, death.location.y))
	
	# Calculate average distance between death locations
	var total_distance = 0.0
	var comparisons = 0
	for i in range(locations.size()):
		for j in range(i + 1, locations.size()):
			total_distance += locations[i].distance_to(locations[j])
			comparisons += 1
	
	if comparisons > 0:
		var average_distance = total_distance / comparisons
		if average_distance < 100.0: # Deaths are clustered within 100 units
			_trigger_difficulty_spike("death_clustering", {
				"cluster_location": locations[0],
				"death_count": recent_deaths.size(),
				"average_distance": average_distance
			})

func _trigger_difficulty_spike(spike_type: String, data: Dictionary) -> void:
	var spike_data = {
		"type": spike_type,
		"level": current_level,
		"timestamp": Time.get_ticks_msec() / 1000.0,
		"data": data
	}
	
	difficulty_spike_detected.emit(current_level, spike_type, spike_data)
	log_analytics_event("difficulty_spike", spike_data)
	
	print("[AnalyticsManager] Difficulty spike detected: %s in %s" % [spike_type, current_level])

## Performance event handlers
func _on_performance_warning(metric: String, value: float, threshold: float) -> void:
	if collect_performance_data:
		track_player_action("performance_warning", {
			"metric": metric,
			"value": value,
			"threshold": threshold
		})

func _on_memory_leak_detected(current_usage: int, peak_usage: int) -> void:
	if collect_performance_data:
		track_player_action("memory_leak", {
			"current_usage": current_usage,
			"peak_usage": peak_usage
		})

func _on_test_event_logged(_event_data: Dictionary) -> void:
	# Forward relevant test events to analytics
	if _event_data.has("type") and _event_data.type in ["user_action", "performance_metric"]:
		log_analytics_event("test_event", _event_data)

## Data privacy and export
func _anonymize_data(data: Dictionary) -> Dictionary:
	var anonymized = data.duplicate(true)
	
	# Remove or hash potentially identifying information
	if anonymized.has("session_id"):
		anonymized.session_id = str(anonymized.session_id.hash())
	
	# Remove precise timestamps, keep relative timing
	if anonymized.has("timestamp") and session_start_time > 0:
		anonymized.relative_time = anonymized.timestamp - session_start_time
		anonymized.erase("timestamp")
	
	return anonymized

func _export_session_data(file_path: String = "") -> void:
	if file_path.is_empty():
		file_path = "user://analytics/session_%s.json" % session_id
	
	var analytics_data = {
		"session_info": {
			"session_id": session_id if not anonymous_mode else str(session_id.hash()),
			"start_time": session_start_time,
			"duration": (Time.get_ticks_msec() / 1000.0) - session_start_time,
			"anonymous_mode": anonymous_mode
		},
		"player_behavior": {
			"total_actions": player_actions.size(),
			"level_completions": level_completion_times,
			"death_count": difficulty_metrics.death_count,
			"items_collected": item_collection_data,
			"dialogue_interactions": dialogue_interaction_data.keys().size()
		},
		"difficulty_analysis": difficulty_metrics,
		"performance_data": _get_performance_summary() if collect_performance_data else {}
	}
	
	# Create analytics directory
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("analytics"):
		dir.make_dir("analytics")
	
	# Save data
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(analytics_data, "\t"))
		file.close()
		print("[AnalyticsManager] Session data exported to: %s" % file_path)

func _get_performance_summary() -> Dictionary:
	if has_node("/root/PerformanceMonitor"):
		var perf_monitor = get_node("/root/PerformanceMonitor")
		if perf_monitor.has_method("get_performance_summary"):
			return perf_monitor.get_performance_summary()
	return {}

func _generate_session_id() -> String:
	var timestamp = Time.get_unix_time_from_system()
	var random_suffix = str(randi() % 10000).pad_zeros(4)
	return "session_%d_%s" % [timestamp, random_suffix]

## Public API for game integration
func get_analytics_summary() -> Dictionary:
	return {
		"enabled": analytics_enabled,
		"consent_given": user_consent_given,
		"session_active": not session_id.is_empty(),
		"total_events": player_actions.size(),
		"current_level": current_level,
		"difficulty_metrics": difficulty_metrics
	}

func is_analytics_enabled() -> bool:
	return analytics_enabled and user_consent_given