extends Node2D

@export var health_component : HealthComponent
@export var hurt_animation: AnimationPlayer
@export var transition_audio : AudioStream
@export var death_animation: AnimationPlayer
@export var puddle_attack_animation: AnimationPlayer
@export var heal_timer: Timer
@export var tear_scene : PackedScene
@export var next_enemy : PackedScene
@export var num_raindrops = 30*2
@export var break_size = 5
@export var pre_ranged_attack_animation: AnimationPlayer

var is_dead = false

func _ready() -> void:
	await do_intro()
	health_component.died.connect(on_died)
	health_component.hurt.connect(on_hurt)
	await Utils.wait(2.9)

func on_heal():
	if is_healing:
		health_component.heal(1)
	
func do_intro():
	Global.fight_started.emit(Global.EnemyType.SADNESS)
	Utils.get_first_of_type(VoiceOverManager).play_music()
	
	await do_puddle_attack()
	
var is_healing = false
func do_puddle_attack():
	if is_dead:
		return
		
	is_healing = true
	puddle_attack_animation.play("attack")
	await puddle_attack_animation.animation_finished
	is_healing = false
	
	await do_cry_attack()

func do_cry_attack():
	if is_dead:
		return
		
	await Utils.wait(1.0)
	pre_ranged_attack_animation.play("attack")
	await pre_ranged_attack_animation.animation_finished
	
	#var pos_offscreen_left = Utils.get_player().global_position + Vector2(-1920/2, -1080/2)
	for i in range(num_raindrops):
		var pos = global_position
		var new_raindrop = tear_scene.instantiate() as Node2D
		add_sibling(new_raindrop)
		new_raindrop.global_position = pos + Vector2(0, -50)
		new_raindrop.rotation = TAU * 2 * float(i)/float(num_raindrops)
		await Utils.wait(0.1)

	
	await Utils.wait(4)
	await do_puddle_attack()
	
	
func on_hurt():
	hurt_animation.play("hurt")

func on_died():
	Global.enemy_died.emit()
	is_dead = true
	SoundManager.play_sound(transition_audio)
	await Utils.wait(7.9)
	death_animation.play("die")
	await death_animation.animation_finished
	var new_enemy = next_enemy.instantiate()
	new_enemy.global_position = global_position
	add_sibling(new_enemy)
	self.queue_free()
	


func _on_heal_timer_timeout() -> void:
	if is_healing:
		health_component.heal(1)
