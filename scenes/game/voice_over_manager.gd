extends Node2D
class_name VoiceOverManager

@export var joy_voices : Array[AudioStream]
@export var anger_voices : Array[AudioStream]
@export var sadness_voices : Array[AudioStream]
@export var apathy_voices : Array[AudioStream]
@export var timer: RandomTimer

@export var music_map : Dictionary[Global.EnemyType, AudioStream]

@onready var active_voice_lines = joy_voices
var index = 0

@export var audio_stream_player: AudioStreamPlayer

var voices_active = false

var current_phase = Global.EnemyType.JOY

func play_music():
	SoundManager.play_music(music_map[current_phase])
	
func _ready() -> void:
	Global.enemy_died.connect(enemy_died)
	Global.fight_started.connect(fight_started)
	timer.timeout.connect(try_play_voice_line)
	Global.player_dead.connect(player_died)

func player_died():
	voices_active = false
	audio_stream_player.stop()
	await Utils.wait(6)
	voices_active = true

func enemy_died():
	voices_active = false
	audio_stream_player.stop()
	
func fight_started(new_enemy : Global.EnemyType):
	current_phase = new_enemy
	voices_active = true
	
	if new_enemy == Global.EnemyType.ANGER:
		active_voice_lines = anger_voices
	if new_enemy == Global.EnemyType.SADNESS:
		active_voice_lines = sadness_voices
	if new_enemy == Global.EnemyType.APATHY:
		active_voice_lines = apathy_voices
	
func try_play_voice_line():
	if voices_active and not audio_stream_player.playing:
		var desired_index = min(index, len(active_voice_lines)-1)
		var voice_over_steam = active_voice_lines[desired_index]
		index += 1
		
		audio_stream_player.stream = voice_over_steam
		audio_stream_player.play()
	
