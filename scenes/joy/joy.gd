extends Node2D
class_name Joy

@export var move_speed = 200
@export var damage_marker_prototype : PackedScene
@export var spike_prototype : PackedScene
@export var small_jump_distance = 200
@export var small_jump_delay = 0.5
@export var big_jump_delay = 0.5
@export var num_small_jump_min = 4
@export var num_small_jumps_max = 6
@export var idle_time_min = 4
@export var idle_time_max = 8
@export var num_spikes_min = 10
@export var num_spikes_max = 15
@export var num_time_between_spikes = 0.1

@export_group("Audio")
@export var intro_audio : AudioStream

@export_group("Components")
@export var jump_projectile: ProjectileComponent
@export var health_component: HealthComponent
@export var animation_player: AnimationPlayer
@export var attack_animations: AnimationPlayer

func _ready() -> void:
	do_intro()
	
func do_intro():
	health_component.invulnerable =  true
	animation_player.play("idle")
	await Utils.wait(0.75)
	SoundManager.play_sound(intro_audio)
	await Utils.wait(intro_audio.get_length())
	health_component.invulnerable = false

	do_small_jumps()

func do_idle():
	await get_tree().process_frame
	print("do_idle")
	animation_player.play("idle")
	var nav = Utils.get_first_of_type(Nav) as Nav
	for i in range(randi_range(num_spikes_min, num_spikes_max)):
		var new_spike = spike_prototype.instantiate()
		new_spike.global_position = Utils.Triangle.get_random_point_in_polygon(nav.polygon)
		add_sibling(new_spike)
		await Utils.wait(num_time_between_spikes)
		
	await Utils.wait(randf_range(idle_time_min, idle_time_max))
	if randf() > 0.2:
		do_big_jump()
	else:
		do_small_jumps()

func do_small_jumps():
	await get_tree().process_frame
	print("do_small_jumps")
	
	animation_player.play("big_jump_prep", 0.2, 2.0)
	await animation_player.animation_finished
	for i in range(randi_range(num_small_jump_min, num_small_jumps_max)):
		await do_small_jump()
	if randf() > 0.3:
		do_idle()
	else:
		do_big_jump()
	
func do_small_jump():
	var dir = self.global_position.direction_to(Utils.get_player().global_position)
	var pos = self.global_position + (dir * small_jump_distance)
	jump_projectile.configure(pos)
	jump_projectile.fire()
	await jump_projectile.on_hit_ground
	#attack_animations.play("small_jump_attack")
	animation_player.play("big_jump_prep", 0.2, 2.0)
	await animation_player.animation_finished
	animation_player.play("big_jump_prep", 0.2, -2.0, true)
	await animation_player.animation_finished


func do_big_jump():
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

	jump_projectile.fire()
	
	new_damage_marker.queue_free()
	
	await jump_projectile.on_hit_ground
	animation_player.play("big_jump_attack")
	await Utils.wait(big_jump_delay)

	if randf() > 0.8:
		do_idle()
	else:
		do_small_jumps()
	
	
		
		
