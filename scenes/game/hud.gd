extends VBoxContainer

@export var name_label: Label
@export var animation_player: AnimationPlayer
@export var hud_animation: AnimationPlayer

func _ready() -> void:
	Global.fight_started.connect(fight_started)
	Global.enemy_died.connect(enemy_died)
	
func fight_started(new_name):
	name_label.text = new_name
	animation_player.play("slide_in", 1, 0.2)
	
	if (new_name != "Joy"):
		hud_animation.play_backwards("curtains")
	
func enemy_died():
	animation_player.play("slide_in", -1, -0.2, true)
	hud_animation.play("curtains")
