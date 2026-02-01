extends Node2D
class_name Joy

@export var move_speed = 200
@export var damage_marker_prototype : PackedScene
@export var next_enemy : PackedScene
@export var spike_prototype : PackedScene
@export var small_jump_distance = 200
@export var small_jump_delay = 0.5
@export var big_jump_delay = 0.5
@export var num_small_jump_min = 2
@export var num_small_jumps_max = 4
@export var idle_time_min = 1
@export var idle_time_max = 1
@export var num_spikes_min = 30
@export var num_spikes_max = 40
@export var num_time_between_spikes = 0.01

@export_group("Audio")
@export var intro_audio : AudioStream
@export var transition_audio : AudioStream
var audio_index = 0
@export var small_jump_land_sound : AudioStream
@export var large_jump_land_sound : AudioStream

@export_group("Components")
@export var jump_projectile: ProjectileComponent
@export var health_component: HealthComponent
@export var animation_player: AnimationPlayer
@export var attack_animations: AnimationPlayer
@export var clap_animation: AnimationPlayer
@export var hurt_animation: AnimationPlayer
@export var death_animation: AnimationPlayer

var is_dead = false

func _ready() -> void:
	do_intro()
	health_component.died.connect(on_died)
	health_component.hurt.connect(on_hurt)
	

func on_hurt():
	hurt_animation.play("hurt")

func on_died():
	Global.enemy_died.emit()
	is_dead = true
	animation_player.play("idle")
	play_audio(transition_audio)
	await Utils.wait(7.9)
	death_animation.play("die")
	await death_animation.animation_finished
	var new_enemy = next_enemy.instantiate()
	new_enemy.global_position = global_position
	add_sibling(new_enemy)
	self.queue_free()

	
func play_audio(audio):
	if Global.settings.skip_audio:
		return
	
	
	var new_audio = SoundManager.play_sound_with_pitch(audio, Global.settings.audio_speed)
	await Utils.wait(intro_audio.get_length() / Global.settings.audio_speed)

func stop_audio():
	pass
	
	
func do_intro():
	SoundManager.stop_music(1)
	health_component.invulnerable =  true
	animation_player.play("idle")
	await Utils.wait(0.75)
	await play_audio(intro_audio)
	Global.fight_started.emit(Global.EnemyType.JOY)
	Utils.get_first_of_type(VoiceOverManager).play_music()
	health_component.invulnerable = false

	do_small_jumps()

func do_idle():
	if is_dead:
		return 
		
	await get_tree().process_frame
	print("do_idle")
	clap_animation.play("clap")
	await clap_animation.animation_finished
	animation_player.play("idle")
	var nav = Utils.get_first_of_type(Nav) as Nav
	
	for i in range(randi_range(num_spikes_min, num_spikes_max)):
		var new_spike = spike_prototype.instantiate()
		new_spike.global_position = Utils.Triangle.get_random_point_in_polygon(nav.polygon) + global_position - Vector2(1920/2,1080/2)
		add_sibling(new_spike)
		await Utils.wait(num_time_between_spikes)
		
	await Utils.wait(randf_range(idle_time_min, idle_time_max))
	if randf() > 0.2:
		do_big_jump()
	else:
		do_small_jumps()

func do_small_jumps():
	if is_dead:
		return 
		
	await get_tree().process_frame
	print("do_small_jumps")
	
	for i in range(randi_range(num_small_jump_min, num_small_jumps_max)):
		await do_small_jump()
	if randf() > 0.4:
		do_idle()
	else:
		do_big_jump()
	
func do_small_jump():
	if is_dead:
		return 
		
	animation_player.play("big_jump_prep", 0.2, 2.0)
	await animation_player.animation_finished
	animation_player.play("big_jump_prep", 0.2, -2.0, true)
	await animation_player.animation_finished
	
	var dir = self.global_position.direction_to(Utils.get_player().global_position)
	var pos = self.global_position + (dir * small_jump_distance)
	jump_projectile.configure(pos)
	jump_projectile.fire()
	await jump_projectile.on_hit_ground
	SoundManager.play_sound(small_jump_land_sound)
	attack_animations.play("small_jump_attack")


func do_big_jump():
	if is_dead:
		return 
	
	await get_tree().process_frame
	var attack_pos = Utils.get_player().global_position
	animation_player.play("big_jump_prep", 0.2)
	var new_damage_marker = damage_marker_prototype.instantiate() as Node2D
	new_damage_marker.scale *= 0.6
	add_sibling(new_damage_marker)
	new_damage_marker.global_position = attack_pos
	
	await Utils.wait(2.0)
	jump_projectile.configure(attack_pos)
	animation_player.play_backwards("big_jump_prep", 0.2)

	health_component.invulnerable = true
	jump_projectile.fire()
	
	new_damage_marker.queue_free()
	
	await jump_projectile.on_hit_ground
	SoundManager.play_sound(large_jump_land_sound)
	health_component.invulnerable = false
	animation_player.play("big_jump_attack")
	await Utils.wait(big_jump_delay)

	if randf() > 0.6:
		do_idle()
	else:
		do_small_jumps()
	
	
		
		
