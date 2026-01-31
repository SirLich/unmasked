extends Node

var settings : JamSettings = load("res://resources/jam_settings.tres")

signal enemy_died
signal enemy_took_damage(new_health_percent)
signal fight_started(name : String)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("kill"):
		pass
		#Utils.get_first_of_type(Enemy).add_child(pas)
