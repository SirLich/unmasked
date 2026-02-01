extends Node2D
class_name HealthComponent

@export var enemy_hit_sound: AudioStream

@export var max_health = 100
@export var do_shake = true
@onready var health = max_health
@export var do_broadcast = true

signal died
signal hurt

## How long the player is invincible, in seconds
@export var invincibility_time = 0.5
var i_frames = 0
var invulnerable = false

func is_invincible():
	return i_frames > 0 or invulnerable or health <= 0
	
func _physics_process(delta: float) -> void:
	if is_invincible():
		i_frames -= delta

func heal(num):
	health = min(max_health, health+num)
	Global.enemy_took_damage.emit(health/max_health)

func heal_full():
	health = max_health
	if not get_parent() is Player:
		pass
		#Global.enemy_took_damage.emit(health/max_health)
	else:
		Global.player_health_changed.emit(health, max_health)
	
func take_damage(damage : float) -> void:
	if is_invincible():
		return
	
	hurt.emit()
		
	health -= damage
	i_frames = invincibility_time

	if do_broadcast:
		if not get_parent() is Player:
			Global.enemy_took_damage.emit(health/max_health)
			SoundManager.play_sound(enemy_hit_sound)
		else:
			Global.player_health_changed.emit(health, max_health)
		
	if do_shake:
		Utils.get_camera().start_shake(15.0, 0.2, 20)
	
	if health <= 0:
		died.emit()
		
		### TODO: Configure player death animation or scene
		#get_parent().queue_free()
		
