extends Node2D

# This is an example of how to use Phantom Camera in the boss fight scene

@onready var player = $Player
@onready var boss = $AcidsJoe
@onready var phantom_camera = $PhantomCamera2D
@onready var intro_camera_position = $IntroCameraPosition
@onready var phase2_camera_position = $Phase2CameraPosition

func _ready():
    # Connect to boss signals
    boss.phase_changed.connect(_on_boss_phase_changed)
    
    # Set up initial camera to follow player
    phantom_camera.set_follow_target(player)
    phantom_camera.set_follow_mode(PhantomCamera2D.FollowMode.FOLLOW)
    phantom_camera.set_follow_smoothing(0.5)

func start_boss_intro():
    # Tween camera to intro position for dramatic effect
    phantom_camera.set_follow_target(intro_camera_position)
    phantom_camera.set_tween_duration(2.0)
    phantom_camera.set_tween_transition(Tween.TRANS_SINE)
    phantom_camera.set_tween_ease(Tween.EASE_IN_OUT)
    
    # After intro, return to player
    await get_tree().create_timer(3.0).timeout
    phantom_camera.set_follow_target(player)

func _on_boss_phase_changed(new_phase):
    if new_phase == 2:
        # For phase 2, use a wider camera view with some shake
        phantom_camera.set_follow_target(phase2_camera_position)
        phantom_camera.set_zoom(Vector2(0.8, 0.8))  # Zoom out
        phantom_camera.add_trauma(0.6)  # Add camera shake
        
        # After transition, return to following player but with wider view
        await get_tree().create_timer(1.5).timeout
        phantom_camera.set_follow_target(player)
        
func _on_boss_special_attack():
    # Add camera shake during special attacks
    phantom_camera.add_trauma(0.4)