extends VBoxContainer

@export var name_label: Label
@export var animation_player: AnimationPlayer

func _ready() -> void:
	Global.fight_started.connect(fight_started)
	Global.enemy_died.connect(enemy_died)
	
func fight_started(new_name):
	name_label.text = new_name
	animation_player.play("slide_in", 1, 0.2)
	
func enemy_died():
	animation_player.play("slide_in", -1, -0.2, true)
