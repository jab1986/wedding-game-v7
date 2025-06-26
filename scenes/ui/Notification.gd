extends Control
class_name Notification
## Pooled UI notification for displaying temporary messages

signal notification_finished()

@onready var label: Label = $Label
@onready var background: NinePatchRect = $Background
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_pooled: bool = false
var pool_name: String = ""
var notification_duration: float = 3.0

func _ready() -> void:
	# Check if this is a pooled object
	if has_meta("is_pooled"):
		is_pooled = get_meta("is_pooled", false)
		pool_name = get_meta("pool_name", "")
	
	# Initially hide
	modulate.a = 0.0
	visible = false

## Show notification with message
func show_notification(message: String, duration: float = 3.0, color: Color = Color.WHITE) -> void:
	label.text = message
	modulate = color
	notification_duration = duration
	visible = true
	
	# Animate in
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
	# Auto-hide after duration
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(_on_notification_timeout)
	add_child(timer)
	timer.start()

## Hide notification
func hide_notification() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(_on_hide_complete)

## Reset notification state
func reset_ui() -> void:
	label.text = ""
	modulate = Color.WHITE
	modulate.a = 0.0
	visible = false

## Activate from pool
func activate() -> void:
	reset_ui()

## Deactivate and return to pool
func deactivate() -> void:
	hide_notification()

func _on_notification_timeout() -> void:
	hide_notification()

func _on_hide_complete() -> void:
	visible = false
	notification_finished.emit()
	
	if is_pooled:
		# Will be handled by ObjectPool's signal connection
		pass