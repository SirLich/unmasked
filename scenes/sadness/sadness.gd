extends Node2D

@export var health_component : HealthComponent
@export var hurt_animation: AnimationPlayer
@export var transition_audio : AudioStream
@export var death_animation: AnimationPlayer
@export var puddle_attack_animation: AnimationPlayer
@export var heal_timer: Timer

@export var next_enemy : PackedScene

var is_dead = false

func _ready() -> void:
	await do_intro()
	health_component.died.connect(on_died)
	health_component.hurt.connect(on_hurt)
	heal_timer.timeout.connect(on_heal)
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
		
	var is_healing = true
	puddle_attack_animation.play("attack")
	await puddle_attack_animation.animation_finished
	is_healing = false
	
	await Utils.wait(1.0)
	await do_puddle_attack()

func do_cry_attack():
	pass
	
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
	
