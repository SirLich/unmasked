extends ProgressBar

func _ready() -> void:
	Global.enemy_took_damage.connect(enemy_damage)
	
func enemy_damage(new_percent):
	value = new_percent
