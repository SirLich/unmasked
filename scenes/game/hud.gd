extends VBoxContainer

@export var name_label: Label
@export var animation_player: AnimationPlayer
@export var hud_animation: AnimationPlayer

func _ready() -> void:
	Global.fight_started.connect(fight_started)
	Global.enemy_died.connect(enemy_died)
	
func fight_started(new_enemy : Global.EnemyType):
	var text = ""
	
	if new_enemy == Global.EnemyType.JOY:
		text = "Joy"
	if new_enemy == Global.EnemyType.ANGER:
		text = "Anger"
	if new_enemy == Global.EnemyType.SADNESS:
		text = "Sadness"
	if new_enemy == Global.EnemyType.APATHY:
		text = "Apathy"
	name_label.text = text
	animation_player.play("slide_in", 1, 0.2)
	
	if (new_enemy != Global.EnemyType.JOY):
		hud_animation.play_backwards("curtains")
	
func enemy_died():
	animation_player.play("slide_in", -1, -0.2, true)
	hud_animation.play("curtains")
