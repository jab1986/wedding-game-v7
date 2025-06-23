extends Node
## AudioManager - Centralized audio management system
## Handles music, sound effects, and audio settings

signal music_changed(track_name: String)
signal volume_changed(bus_name: String, volume: float)

# Audio buses
const MASTER_BUS := "Master"
const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const VOICE_BUS := "Voice"

# Audio file paths
const AUDIO_PATH := "res://assets/audio/"
const MUSIC_PATH := AUDIO_PATH + "music/"
const SFX_PATH := AUDIO_PATH + "sfx/"

# Music tracks - loaded dynamically to avoid missing file errors
var music_tracks := {}

# Sound effects - loaded dynamically to avoid missing file errors
var sound_effects := {}

# Audio players
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var voice_player: AudioStreamPlayer

# Settings
var master_volume: float = 1.0:
	set(value):
		master_volume = clamp(value, 0.0, 1.0)
		_set_bus_volume(MASTER_BUS, master_volume)

var music_volume: float = 0.8:
	set(value):
		music_volume = clamp(value, 0.0, 1.0)
		_set_bus_volume(MUSIC_BUS, music_volume)

var sfx_volume: float = 1.0:
	set(value):
		sfx_volume = clamp(value, 0.0, 1.0)
		_set_bus_volume(SFX_BUS, sfx_volume)

var voice_volume: float = 1.0:
	set(value):
		voice_volume = clamp(value, 0.0, 1.0)
		_set_bus_volume(VOICE_BUS, voice_volume)

# State
var current_music: String = ""
var music_paused: bool = false
var sfx_pool_size: int = 10

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Create audio players
	_create_audio_players()
	
	# Load audio files (if they exist)
	_load_audio_files()
	
	# Load saved settings
	_load_audio_settings()
	
	print("AudioManager initialized")

func _create_audio_players() -> void:
	# Music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = MUSIC_BUS
	add_child(music_player)
	
	# SFX player pool
	for i in range(sfx_pool_size):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = SFX_BUS
		add_child(sfx_player)
		sfx_players.append(sfx_player)
	
	# Voice player
	voice_player = AudioStreamPlayer.new()
	voice_player.bus = VOICE_BUS
	add_child(voice_player)

func _load_audio_files() -> void:
	# Define audio files to try loading
	var music_files := {
		"menu_theme": "menu_theme.ogg",
		"amsterdam_romantic": "amsterdam_romantic.ogg", 
		"disaster_theme": "disaster_theme.ogg",
		"glen_bingo": "glen_bingo.ogg",
		"cafe_ambient": "cafe_ambient.ogg",
		"boss_battle": "boss_battle.ogg",
		"wedding_march": "wedding_march.ogg",
		"agent_elf_midi": "agent_elf_midi.ogg"
	}
	
	var sfx_files := {
		"menu_select": "menu_select.wav",
		"menu_back": "menu_back.wav", 
		"drumstick_throw": "drumstick_throw.wav",
		"camera_flash": "camera_flash.wav",
		"explosion": "explosion.wav",
		"alien_death": "alien_death.wav",
		"pickup": "pickup.wav",
		"damage": "damage.wav",
		"jump": "jump.wav",
		"land": "land.wav",
		"glen_confused": "glen_confused.wav",
		"fire_crackle": "fire_crackle.wav",
		"water_splash": "water_splash.wav",
		# SNES-style wedding sound effects
		"wedding_bell_chime": "wedding_bell_chime.wav",
		"success_chime": "success_chime.wav",
		"menu_select_snes": "menu_select_snes.wav",
		"menu_confirm_snes": "menu_confirm_snes.wav",
		"celebration_fanfare": "celebration_fanfare.wav",
		"disaster_alarm": "disaster_alarm.wav",
		"bingo_correct": "bingo_correct.wav",
		"bingo_wrong": "bingo_wrong.wav"
	}
	
	# Load music files if they exist
	for track_name in music_files:
		var path = MUSIC_PATH + music_files[track_name]
		if FileAccess.file_exists(path):
			var stream = load(path)
			if stream:
				music_tracks[track_name] = stream
				print("Loaded music: " + track_name)
		else:
			print("Music file not found: " + path + " (skipping)")
	
	# Load SFX files if they exist  
	for sfx_name in sfx_files:
		var path = SFX_PATH + sfx_files[sfx_name]
		if FileAccess.file_exists(path):
			var stream = load(path)
			if stream:
				sound_effects[sfx_name] = stream
				print("Loaded SFX: " + sfx_name)
		else:
			print("SFX file not found: " + path + " (skipping)")
	
	print("Audio loading complete. Music tracks: %d, SFX: %d" % [music_tracks.size(), sound_effects.size()])

## Play music track
func play_music(track_name: String, fade_in: bool = true) -> void:
	if track_name == current_music and music_player.playing:
		return
	
	if not track_name in music_tracks:
		print("Music track not available: " + track_name + " (audio file missing)")
		return
	
	# Stop current music
	if music_player.playing and fade_in:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, 0.5)
		await tween.finished
		music_player.stop()
	else:
		music_player.stop()
	
	# Play new music
	music_player.stream = music_tracks[track_name]
	music_player.volume_db = -80.0 if fade_in else 0.0
	music_player.play()
	
	if fade_in:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", 0.0, 0.5)
	
	current_music = track_name
	music_changed.emit(track_name)

## Stop music
func stop_music(fade_out: bool = true) -> void:
	if not music_player.playing:
		return
	
	if fade_out:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, 0.5)
		await tween.finished
	
	music_player.stop()
	current_music = ""

## Pause/resume music
func pause_music() -> void:
	music_paused = true
	music_player.stream_paused = true

func resume_music() -> void:
	music_paused = false
	music_player.stream_paused = false

## Play sound effect
func play_sfx(sfx_name: String, volume_offset: float = 0.0, pitch: float = 1.0) -> AudioStreamPlayer:
	if not sfx_name in sound_effects:
		print("Sound effect not available: " + sfx_name + " (audio file missing)")
		return null
	
	var player = _get_available_sfx_player()
	if player:
		player.stream = sound_effects[sfx_name]
		player.volume_db = volume_offset
		player.pitch_scale = pitch
		player.play()
		return player
	
	return null

## Play sound effect with AudioStream
func play_sfx_stream(stream: AudioStream, volume_offset: float = 0.0, pitch: float = 1.0) -> AudioStreamPlayer:
	var player = _get_available_sfx_player()
	if player:
		player.stream = stream
		player.volume_db = volume_offset
		player.pitch_scale = pitch
		player.play()
		return player
	
	return null

## Play voice/dialogue
func play_voice(voice_stream: AudioStream) -> void:
	voice_player.stream = voice_stream
	voice_player.play()

func stop_voice() -> void:
	voice_player.stop()

## Get available SFX player from pool
func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	
	# All players busy, use the first one
	push_warning("All SFX players busy, reusing first player")
	return sfx_players[0]

## Set bus volume
func _set_bus_volume(bus_name: String, linear_volume: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		var db_volume = linear_to_db(linear_volume)
		AudioServer.set_bus_volume_db(bus_idx, db_volume)
		volume_changed.emit(bus_name, linear_volume)

## Mute/unmute
func set_muted(muted: bool) -> void:
	var master_idx = AudioServer.get_bus_index(MASTER_BUS)
	AudioServer.set_bus_mute(master_idx, muted)

func is_muted() -> bool:
	var master_idx = AudioServer.get_bus_index(MASTER_BUS)
	return AudioServer.is_bus_mute(master_idx)

## Save/load audio settings
func save_audio_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "voice_volume", voice_volume)
	config.save("user://audio_settings.cfg")

func _load_audio_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://audio_settings.cfg") == OK:
		master_volume = config.get_value("audio", "master_volume", 1.0)
		music_volume = config.get_value("audio", "music_volume", 0.8)
		sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
		voice_volume = config.get_value("audio", "voice_volume", 1.0)

## Utility functions
func linear_to_db(linear: float) -> float:
	if linear <= 0.0:
		return -80.0
	return 20.0 * log(linear) / log(10.0)

func db_to_linear(db: float) -> float:
	return pow(10.0, db / 20.0)

## Play random pitch variation
func play_sfx_varied(sfx_name: String, pitch_variation: float = 0.1) -> void:
	var pitch = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
	play_sfx(sfx_name, 0.0, pitch)

## Play sound at position (for 2D positional audio)
func play_sfx_2d(sfx_name: String, _global_pos: Vector2) -> void:
	# This would create an AudioStreamPlayer2D at the position
	# For now, just play normally
	play_sfx(sfx_name)
