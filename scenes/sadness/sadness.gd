extends Node2D

@export var sad_music : AudioStream
@export var health_component : HealthComponent
@export var hurt_animation: AnimationPlayer
@export var transition_audio : AudioStream
@export var death_animation: AnimationPlayer

@export var next_enemy : PackedScene

var is_dead = false

func _ready() -> void:
	await do_intro()
	health_component.died.connect(on_died)
	health_component.hurt.connect(on_hurt)
	
	await Utils.wait(2.9)
	
func do_intro():
	Global.fight_started.emit(Global.EnemyType.SADNESS)
	SoundManager.play_music(sad_music)
	
func on_hurt():
	hurt_animation.play("hurt")

func on_died():
	Global.enemy_died.emit()
	is_dead = true
	#play_audio(transition_audio)
	await Utils.wait(7.9)
	death_animation.play("die")
	await death_animation.animation_finished
	var new_enemy = next_enemy.instantiate()
	new_enemy.global_position = global_position
	add_sibling(new_enemy)
	self.queue_free()
	
