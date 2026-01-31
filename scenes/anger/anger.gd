extends Node2D
class_name Anger

@export var health_component: HealthComponent
@export var angry_music : AudioStream
@export var fire_scene :PackedScene
@export var num_fires = 10
@export var dash_distance = 700
@export var fire_pause = 0.1
@export var dash_speed = 0.4

func _ready() -> void:
	do_intro()
	health_component.died.connect(on_died)
	health_component.hurt.connect(on_hurt)
	
	await Utils.wait(2.9)
	do_dash()
	
func do_intro():
	Global.fight_started.emit("Anger")
	SoundManager.play_music(angry_music)
	
func on_hurt():
	pass

func on_died():
	pass
	
func do_dash():
	var dir = Utils.get_direction_to_player(self)
	var pos = global_position + (dir * dash_distance)
	
	for i in range(num_fires):
		var fire_pos = lerp(global_position, pos, float(i)/float(num_fires))
		var new_fire = fire_scene.instantiate()
		new_fire.global_position = fire_pos
		add_sibling(new_fire)
		await Utils.wait(fire_pause)
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", pos, dash_speed)
	await tween.finished
	
	do_dash()
		
		
