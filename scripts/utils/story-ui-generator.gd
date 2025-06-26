extends Node
class_name StoryUIGenerator
## Generates UI elements based on wedding game story content
## Integrates with MCP servers for dynamic UI creation

signal ui_generated(ui_element: Control)
signal theme_applied(theme_name: String)

# Story-based UI themes
enum StoryTheme {
	ROMANTIC, # Amsterdam proposal scene
	CHAOTIC, # Glen's house disasters
	PEACEFUL, # Leo's cafe
	EPIC_BATTLE, # Boss fight with Acids Joe
	CELEBRATION # Wedding ceremony
}

# Character-specific UI styles
var character_ui_styles := {
	"mark": {
		"primary_color": Color("#8B4513"), # Brown for drummer
		"accent_color": Color("#FFD700"), # Gold for drumsticks
		"font_style": "bold",
		"ui_personality": "energetic"
	},
	"jenny": {
		"primary_color": Color("#FFB6C1"), # Pink for bride
		"accent_color": Color("#FFFFFF"), # White for dress
		"font_style": "elegant",
		"ui_personality": "graceful"
	},
	"glen": {
		"primary_color": Color("#90EE90"), # Green for confusion
		"accent_color": Color("#FFA500"), # Orange for chaos
		"font_style": "quirky",
		"ui_personality": "confused"
	},
	"acids_joe": {
		"primary_color": Color("#800080"), # Purple for psychedelic
		"accent_color": Color("#FF69B4"), # Hot pink for chaos
		"font_style": "wild",
		"ui_personality": "psychedelic"
	}
}

# Story moment UI configurations
var story_ui_configs := {
	"amsterdam_proposal": {
		"theme": StoryTheme.ROMANTIC,
		"mood": "romantic",
		"colors": ["#FFB6C1", "#FFFFFF", "#FFD700"],
		"ui_elements": ["heart_particles", "ring_indicator", "romantic_dialogue_box"]
	},
	"glen_disasters": {
		"theme": StoryTheme.CHAOTIC,
		"mood": "chaotic",
		"colors": ["#FF4500", "#FFA500", "#8B0000"],
		"ui_elements": ["disaster_meter", "chaos_indicator", "emergency_alerts"]
	},
	"boss_fight": {
		"theme": StoryTheme.EPIC_BATTLE,
		"mood": "intense",
		"colors": ["#800080", "#FF69B4", "#000000"],
		"ui_elements": ["boss_health_bar", "psychedelic_effects", "battle_ui"]
	},
	"wedding_ceremony": {
		"theme": StoryTheme.CELEBRATION,
		"mood": "joyful",
		"colors": ["#FFFFFF", "#FFB6C1", "#FFD700"],
		"ui_elements": ["confetti_effects", "ceremony_progress", "celebration_ui"]
	}
}

func _ready():
	print("Story UI Generator initialized for wedding game")

## Generate UI based on current story moment
func generate_story_ui(story_moment: String, character: String = "") -> Control:
	var ui_config = story_ui_configs.get(story_moment, {})
	var character_style = character_ui_styles.get(character, {})

	var ui_container = VBoxContainer.new()
	ui_container.name = "StoryUI_" + story_moment

	# Apply story-based theme
	_apply_story_theme(ui_container, ui_config)

	# Add character-specific elements
	if character != "":
		_add_character_elements(ui_container, character_style)

	# Generate story-specific UI elements
	_generate_story_elements(ui_container, ui_config)

	ui_generated.emit(ui_container)
	return ui_container

## Create dialogue UI based on wedding characters
func create_character_dialogue_ui(character: String, dialogue_text: String) -> Control:
	var character_style = character_ui_styles.get(character, {})

	var dialogue_panel = Panel.new()
	dialogue_panel.name = "DialoguePanel_" + character

	# Character-specific styling
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = character_style.get("primary_color", Color.WHITE)
	style_box.border_color = character_style.get("accent_color", Color.BLACK)
	style_box.border_width_left = 3
	style_box.border_width_right = 3
	style_box.border_width_top = 3
	style_box.border_width_bottom = 3
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10

	dialogue_panel.add_theme_stylebox_override("panel", style_box)

	# Character name label
	var name_label = Label.new()
	name_label.text = character.capitalize()
	name_label.add_theme_color_override("font_color", character_style.get("accent_color", Color.BLACK))

	# Dialogue text
	var dialogue_label = RichTextLabel.new()
	dialogue_label.bbcode_enabled = true
	dialogue_label.text = dialogue_text
	dialogue_label.fit_content = true

	# Add personality-based effects
	match character_style.get("ui_personality", "normal"):
		"confused":
			# Glen's confused animations
			var tween = create_tween()
			tween.set_loops()
			tween.tween_property(dialogue_panel, "rotation", 0.05, 0.5)
			tween.tween_property(dialogue_panel, "rotation", -0.05, 0.5)
		"psychedelic":
			# Acids Joe's wild effects
			var tween = create_tween()
			tween.set_loops()
			tween.tween_property(dialogue_panel, "modulate", Color.MAGENTA, 0.3)
			tween.tween_property(dialogue_panel, "modulate", Color.CYAN, 0.3)
		"energetic":
			# Mark's drummer energy
			var tween = create_tween()
			tween.set_loops()
			tween.tween_property(dialogue_panel, "scale", Vector2(1.05, 1.05), 0.2)
			tween.tween_property(dialogue_panel, "scale", Vector2(1.0, 1.0), 0.2)

	var vbox = VBoxContainer.new()
	vbox.add_child(name_label)
	vbox.add_child(dialogue_label)
	dialogue_panel.add_child(vbox)

	return dialogue_panel

## Generate wedding-themed progress indicators
func create_wedding_progress_ui(progress_type: String, current_value: float, max_value: float) -> Control:
	var progress_container = HBoxContainer.new()

	match progress_type:
		"ceremony_progress":
			# Wedding ceremony completion
			var progress_bar = ProgressBar.new()
			progress_bar.min_value = 0
			progress_bar.max_value = max_value
			progress_bar.value = current_value

			# Wedding-themed styling
			var style_box = StyleBoxFlat.new()
			style_box.bg_color = Color("#FFB6C1") # Pink background
			progress_bar.add_theme_stylebox_override("background", style_box)

			var fill_style = StyleBoxFlat.new()
			fill_style.bg_color = Color("#FFD700") # Gold fill
			progress_bar.add_theme_stylebox_override("fill", fill_style)

			# Add wedding icons
			var heart_icon = Label.new()
			heart_icon.text = "💖"
			var ring_icon = Label.new()
			ring_icon.text = "💍"

			progress_container.add_child(heart_icon)
			progress_container.add_child(progress_bar)
			progress_container.add_child(ring_icon)

		"disaster_meter":
			# Glen's chaos level
			var chaos_meter = ProgressBar.new()
			chaos_meter.min_value = 0
			chaos_meter.max_value = max_value
			chaos_meter.value = current_value

			# Disaster-themed styling
			var bg_style = StyleBoxFlat.new()
			bg_style.bg_color = Color("#90EE90") # Green background
			chaos_meter.add_theme_stylebox_override("background", bg_style)

			var fill_style = StyleBoxFlat.new()
			# Color changes based on chaos level
			if current_value < max_value * 0.3:
				fill_style.bg_color = Color("#90EE90") # Green - calm
			elif current_value < max_value * 0.7:
				fill_style.bg_color = Color("#FFA500") # Orange - getting chaotic
			else:
				fill_style.bg_color = Color("#FF4500") # Red - full chaos

			chaos_meter.add_theme_stylebox_override("fill", fill_style)

			var chaos_label = Label.new()
			chaos_label.text = "Glen's Confusion Level"

			var vbox = VBoxContainer.new()
			vbox.add_child(chaos_label)
			vbox.add_child(chaos_meter)
			progress_container.add_child(vbox)

	return progress_container

## Apply story theme to UI container
func _apply_story_theme(container: Control, config: Dictionary):
	var theme_name = config.get("theme", StoryTheme.ROMANTIC)

	match theme_name:
		StoryTheme.ROMANTIC:
			container.modulate = Color("#FFE4E1") # Misty rose
		StoryTheme.CHAOTIC:
			container.modulate = Color("#FFA07A") # Light salmon
		StoryTheme.PEACEFUL:
			container.modulate = Color("#F0F8FF") # Alice blue
		StoryTheme.EPIC_BATTLE:
			container.modulate = Color("#DDA0DD") # Plum
		StoryTheme.CELEBRATION:
			container.modulate = Color("#FFFACD") # Lemon chiffon

	theme_applied.emit(str(theme_name))

## Add character-specific UI elements
func _add_character_elements(container: Control, character_style: Dictionary):
	var personality = character_style.get("ui_personality", "normal")

	# Add personality-based decorative elements
	match personality:
		"confused":
			var question_mark = Label.new()
			question_mark.text = "???"
			question_mark.add_theme_color_override("font_color", Color("#90EE90"))
			container.add_child(question_mark)
		"psychedelic":
			var trippy_effect = ColorRect.new()
			trippy_effect.color = Color("#800080", 0.3)
			trippy_effect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			trippy_effect.custom_minimum_size = Vector2(0, 5)
			container.add_child(trippy_effect)
		"energetic":
			var energy_indicator = Label.new()
			energy_indicator.text = "🥁 ENERGY 🥁"
			energy_indicator.add_theme_color_override("font_color", Color("#FFD700"))
			container.add_child(energy_indicator)

## Generate story-specific UI elements
func _generate_story_elements(container: Control, config: Dictionary):
	var ui_elements = config.get("ui_elements", [])

	for element in ui_elements:
		match element:
			"heart_particles":
				var heart_label = Label.new()
				heart_label.text = "💕💖💕"
				container.add_child(heart_label)
			"disaster_meter":
				var disaster_ui = create_wedding_progress_ui("disaster_meter", 50, 100)
				container.add_child(disaster_ui)
			"confetti_effects":
				var confetti_label = Label.new()
				confetti_label.text = "🎉✨🎊✨🎉"
				container.add_child(confetti_label)

## MCP Server Integration Functions
func request_mcp_ui_generation(story_data: Dictionary) -> void:
	# This would integrate with actual MCP servers
	print("Requesting MCP UI generation for story data: ", story_data)

	# Example of what could be sent to MCP servers:
	var mcp_request = {
		"story_context": story_data,
		"characters": character_ui_styles.keys(),
		"themes": story_ui_configs.keys(),
		"ui_requirements": "wedding game SNES style with South Park humor"
	}

	# Future: Send to MCP UI Generator server
	_simulate_mcp_response(mcp_request)

func _simulate_mcp_response(request: Dictionary):
	# Simulate MCP server response
	print("MCP Server would generate UI based on: ", request)
	print("Generated wedding-themed UI components!")
