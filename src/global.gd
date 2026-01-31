extends Node

var settings : JamSettings = load("res://resources/jam_settings.tres")

signal enemy_took_damage(new_health_percent)
signal fight_started(name : String)
