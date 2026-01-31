extends Node2D
class_name Anger

@export var health_component: HealthComponent
@export var angry_music : AudioStream

func _ready() -> void:
	do_intro()
	health_component.died.connect(on_died)
	health_component.hurt.connect(on_hurt)
	
func do_intro():
	Global.fight_started.emit("Anger")
	SoundManager.play_music(angry_music)
	
func on_hurt():
	pass

func on_died():
	pass
